// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

// Author: @andrewkimjoseph

/**
 * @notice Smart contract for managing a task completion system with ERC20 token rewards
 * @dev Inherits from Ownable for TaskManager access control, Pausable for emergency stops,
 *      and EIP712 for typed structured data signing.
 *      This contract handles the complete lifecycle of tasks: participantProxy screening,
 *      signature verification using EIP-712 typed data, and reward distribution to PaxAccount contracts.
 *      
 *      The contract implements EIP-712 for secure, structured, and human-readable message signing, which, generally speaking:
 *      - Improves security by preventing signature replay across different domains and contracts
 *      - Enhances UX by allowing wallet providers to display human-readable data for signing
 *      - Follows industry standards for message signing in dApps
 *      
 *      Note: ParticipantProxies in this system are smart account wallets rather than
 *      non-custodial EOAs, which abstracts the custody experience from end users.
 *      Rewards are sent to PaxAccount contract addresses, not directly to end-users.
 */
contract TaskManagerV1 is Ownable, Pausable, EIP712 {
    using ECDSA for bytes32;

    /**
     * @notice Reference to the ERC20 token contract used for rewards
     * @dev Marked as immutable to save gas and prevent changes after deployment
     */
    IERC20 private immutable rewardToken;

    /**
     * @notice Reference to the signer used to verify screening and reward claiming signatures
     * @dev Marked as immutable to save gas and prevent changes after deployment
     */
    address private immutable signer;

    // keccak256("ScreeningRequest(address participant,string taskId,uint256 nonce)")
    bytes32 private constant SCREENING_REQUEST_TYPEHASH = 
        keccak256("ScreeningRequest(address participant,string taskId,uint256 nonce)");
        
    // keccak256("RewardClaimRequest(address participant,string rewardId,uint256 nonce)")
    bytes32 private constant REWARD_CLAIM_REQUEST_TYPEHASH = 
        keccak256("RewardClaimRequest(address participant,string rewardId,uint256 nonce)");

    /**
     * @notice Mapping to track participantProxies who have received rewards
     * @dev Used to prevent double-claiming of rewards
     */
    mapping(address => bool) private rewardedParticipantProxies;

    /**
     * @notice Mapping to track participantProxies who have been screened for the task
     * @dev Screening is a prerequisite for reward claiming
     */
    mapping(address => bool) private participantProxiesScreenedForTask;

    /**
     * @notice Mapping to track which signatures have been used for screening participantProxies
     * @dev Prevents replay attacks by ensuring each signature is only used once
     */
    mapping(bytes => bool) private signaturesUsedForScreening;

    /**
     * @notice Mapping to track which signatures have been used for claiming rewards
     * @dev Prevents replay attacks by ensuring each signature is only used once
     */
    mapping(bytes => bool) private signaturesUsedForClaiming;

    /**
     * @notice Amount of the reward token to reward each task completion
     * @dev Stored in the token's smallest unit (wei equivalent)
     */
    uint256 private rewardAmountPerParticipantProxyInWei;

    /**
     * @notice Maximum number of participantProxies allowed in the task
     * @dev Used to limit the total number of rewards that can be distributed
     */
    uint256 private targetNumberOfParticipantProxies;

    /**
     * @notice Counter for number of participantProxies who have been rewarded
     * @dev Used to track progress toward the target number of participantProxies
     */
    uint256 private numberOfRewardedParticipantProxies;

    /**
     * @notice Counter for number of rewards that have been claimed
     * @dev Should match numberOfRewardedParticipantProxies but tracked separately for verification
     */
    uint256 private numberOfClaimedRewards;

    /**
     * @notice Counter for number of participantProxies who have been screened
     * @dev Tracks the total number of successful screenings
     */
    uint256 private numberOfScreenedParticipantProxies;

    /**
     * @notice Counter for number of screening signatures that have been used
     * @dev For monitoring signature usage and preventing replay attacks
     */
    uint256 private numberOfUsedScreeningSignatures;

    /**
     * @notice Counter for number of claiming signatures that have been used
     * @dev For monitoring signature usage and preventing replay attacks
     */
    uint256 private numberOfUsedClaimingSignatures;

    /**
     * @notice Emitted when a new TaskManager is created
     * @param taskManager The address of the newly created TaskManager
     * @param taskMaster The address of the taskMaster (owner) of the newly created TaskManager
     * @param signer The address of the signer of the newly created TaskManager
     
     * @dev Used for off-chain tracking and verification of contract deployment
     */
    event TaskManagerCreated(
        address indexed taskManager,
        address indexed taskMaster,
        address indexed signer
    );

    /**
     * @notice Emitted when a participantProxy completes the screening process
     * @param participantProxy The address of the screened participantProxy
     * @dev Used for off-chain tracking and verification of the screening process
     */
    event ParticipantProxyScreened(address participantProxy);

    /**
     * @notice Emitted when rewards are successfully sent to a PaxAccount
     * @param paxAccountContractAddress The address of the PaxAccount contract that received the rewards
     * @param rewardAmount The amount of reward token sent in wei
     * @dev Provides transparency for successful reward distributions
     */
    event PaxAccountRewarded(
        address paxAccountContractAddress,
        uint256 rewardAmount
    );

    /**
     * @notice Emitted when a signature is used to screen a participantProxy
     * @param signature The signature that was used
     * @param participantProxy The address of the participantProxy who used the signature
     * @dev Helps track signature usage for audit and debugging purposes
     */
    event ScreeningSignatureUsed(bytes signature, address participantProxy);

    /**
     * @notice Emitted when a signature is used to claim a reward
     * @param signature The signature that was used
     * @param participantProxy The address of the participantProxy who used the signature
     * @dev Helps track signature usage for audit and debugging purposes
     */
    event ClaimingSignatureUsed(bytes signature, address participantProxy);

    /**
     * @notice Emitted when a participantProxy is marked as having received their reward
     * @param participantProxy The address of the participantProxy marked as rewarded
     * @param paxAccountContractAddress The contract address that received the reward
     * @dev Used for tracking the internal state change separate from the token transfer
     */
    event ParticipantProxyMarkedAsRewarded(
        address participantProxy,
        address paxAccountContractAddress
    );

    /**
     * @notice Emitted when reward funds are withdrawn by the taskMaster
     * @param taskMaster The address of the taskMaster who withdrew the funds
     * @param rewardAmount The amount of reward token withdrawn in wei
     * @dev Provides transparency for fund withdrawals by the taskMaster
     */
    event RewardTokenWithdrawn(address taskMaster, uint256 rewardAmount);

    /**
     * @notice Emitted when a given token is withdrawn by the taskMaster
     * @param taskMaster The address of the taskMaster who withdrew the funds
     * @param tokenAddress The address of the given token withdrawn
     * @param rewardAmount The amount of the given token withdrawn in wei
     * @dev Allows withdrawal of any ERC20 tokens accidentally sent to the contract
     */
    event GivenTokenWithdrawn(
        address taskMaster,
        IERC20 tokenAddress,
        uint256 rewardAmount
    );

    /**
     * @notice Emitted when the reward amount per participantProxy is updated
     * @param oldRewardTokenRewardAmountPerParticipantProxyInWei The previous reward amount
     * @param newRewardTokenRewardAmountPerParticipantProxyInWei The new reward amount
     * @dev Provides transparency for configuration changes by the taskMaster
     */
    event RewardAmountUpdated(
        uint256 oldRewardTokenRewardAmountPerParticipantProxyInWei,
        uint256 newRewardTokenRewardAmountPerParticipantProxyInWei
    );

    /**
     * @notice Emitted when the target number of participantProxies is updated
     * @param oldTargetNumberOfParticipantProxies The previous target number
     * @param newTargetNumberOfParticipantProxies The new target number
     * @dev Provides transparency for configuration changes by the taskMaster
     */
    event TargetNumberOfParticipantProxiesUpdated(
        uint256 oldTargetNumberOfParticipantProxies,
        uint256 newTargetNumberOfParticipantProxies
    );

    /**
     * @notice Verifies that the screening signature is valid and was signed by the contract owner
     * @dev Used to validate signer-approved screening attempts
     * @param participantProxy The wallet address of the participantProxy being screened
     * @param taskId Unique identifier for this task instance
     * @param nonce Unique number to prevent replay attacks
     * @param signature Cryptographic signature generated by the contract owner
     */
    modifier onlyIfGivenScreeningSignatureIsValid(
        address participantProxy,
        string memory taskId,
        uint256 nonce,
        bytes memory signature
    ) {
        require(
            verifySignatureForParticipantProxyScreening(
                participantProxy,
                taskId,
                nonce,
                signature
            ),
            "Invalid signature"
        );
        _;
    }

    /**
     * @notice Verifies that the claiming signature is valid and was signed by the contract owner
     * @dev Used to validate signer-approved reward claims
     * @param participantProxy The wallet address of the participantProxy claiming the reward
     * @param rewardId Unique identifier for this reward claim
     * @param nonce Unique number to prevent replay attacks
     * @param signature Cryptographic signature generated by the contract owner
     */
    modifier onlyIfGivenClaimingSignatureIsValid(
        address participantProxy,
        string memory rewardId,
        uint256 nonce,
        bytes memory signature
    ) {
        require(
            verifySignatureForRewardClaiming(
                participantProxy,
                rewardId,
                nonce,
                signature
            ),
            "Invalid signature"
        );
        _;
    }

    /**
     * @notice Ensures a screening signature hasn't been used before
     * @dev Prevents replay attacks by checking signature uniqueness
     * @param signature The cryptographic signature to check
     */
    modifier onlyIfGivenScreeningSignatureIsUnused(bytes memory signature) {
        require(
            !signaturesUsedForScreening[signature],
            "Signature already used"
        );
        _;
    }

    /**
     * @notice Ensures a claiming signature hasn't been used before
     * @dev Prevents replay attacks by checking signature uniqueness
     * @param signature The cryptographic signature to check
     */
    modifier onlyIfGivenClaimingSignatureIsUnused(bytes memory signature) {
        require(
            !signaturesUsedForClaiming[signature],
            "Signature already used"
        );
        _;
    }

    /**
     * @notice Ensures participantProxy hasn't been screened yet
     * @dev Prevents duplicate screenings for the same participantProxy
     * @param participantProxy Address of the participantProxy to check
     */
    modifier onlyUnscreenedParticipantProxy(address participantProxy) {
        require(
            !participantProxiesScreenedForTask[participantProxy],
            "Only unscreened address"
        );
        _;
    }

    /**
     * @notice Ensures the participantProxy has been screened before proceeding
     * @dev Enforces the proper sequence of operations (screen first, then claim)
     * @param participantProxy Address of the participantProxy to check
     */
    modifier mustBeScreened(address participantProxy) {
        require(
            participantProxiesScreenedForTask[participantProxy],
            "Must be screened"
        );
        _;
    }

    /**
     * @notice Ensures participantProxy hasn't already claimed a reward
     * @dev Prevents double rewards for the same participantProxy
     * @param participantProxy Address of the participantProxy to check
     */
    modifier onlyUnrewardedParticipantProxy(address participantProxy) {
        require(
            !rewardedParticipantProxies[participantProxy],
            "ParticipantProxy already rewarded"
        );
        _;
    }

    /**
     * @notice Ensures the function caller is the specified participantProxy
     * @dev Prevents unauthorized calls on behalf of other participantProxies
     * @param participantProxy Address that should match msg.sender
     */
    modifier onlyIfSenderIsGivenParticipantProxy(address participantProxy) {
        require(msg.sender == participantProxy, "Only valid sender");
        _;
    }

    /**
     * @notice Ensures the contract has sufficient reward tokens for one reward
     * @dev Prevents failed token transfers due to insufficient balance
     */
    modifier onlyIfContractHasEnoughRewardTokens() {
        require(
            rewardToken.balanceOf(address(this)) >=
                rewardAmountPerParticipantProxyInWei,
            "Contract does not have enough of the reward token"
        );
        _;
    }

    /**
     * @notice Ensures the contract has at least some reward tokens
     * @dev Used for withdrawal functions to prevent zero-value transfers
     */
    modifier onlyIfContractHasAnyRewardTokens() {
        require(
            rewardToken.balanceOf(address(this)) > 0,
            "Contract does not have any reward tokens"
        );
        _;
    }

    /**
     * @notice Ensures the contract has at least some of the specified token
     * @dev Used for withdrawal of any token to prevent zero-value transfers
     * @param token The ERC20 token contract to check balance for
     */
    modifier onlyIfContractHasAnyGivenToken(IERC20 token) {
        require(
            token.balanceOf(address(this)) > 0,
            "Contract does not have any of the given token"
        );
        _;
    }

    /**
     * @notice Ensures the number of screened participants hasn't reached the target
     * @dev Prevents screening more participants than the target number
     */
    modifier onlyWhenTargetNumberOfParticipantProxiesNotIsNotReached() {
        require(
            numberOfScreenedParticipantProxies < targetNumberOfParticipantProxies,
            "Maximum number of participantProxies have been screened"
        );
        _;
    }

    /**
     * @notice Ensures the target number of participantProxies hasn't been reached
     * @dev Controls the total number of rewards that can be distributed
     */
    modifier onlyWhenAllParticipantProxiesHaveNotBeenRewarded() {
        require(
            numberOfRewardedParticipantProxies <
                targetNumberOfParticipantProxies,
            "All participantProxies have been rewarded"
        );
        _;
    }

    /**
     * @notice Ensures the contract has sufficient reward tokens for all potential rewards
     * @dev Prevents screening when there are insufficient funds for all potential rewards
     * @dev The check verifies that the contract's token balance is greater than or equal to:
     *      (reward amount per participant) * (remaining available slots)
     *      where remaining slots = target number - already screened number
     * @dev This ensures that if all remaining participants complete the task,
     *      there will be enough tokens to reward them all
     */
    modifier onlyIfContractHasEnoughRewardTokensForAllPotentialRewards() {
        require(
            rewardToken.balanceOf(address(this)) >=
                rewardAmountPerParticipantProxyInWei *
                    (targetNumberOfParticipantProxies -
                        numberOfScreenedParticipantProxies),
            "Contract does not have enough reward tokens for all potential rewards"
        );
        _;
    }

    /**
     * @notice Initializes the task management contract with initial parameters
     * @dev Sets up the contract with taskMaster address, signer address, reward amount, participantProxy target, and reward token
     *      Emits a TaskManagerCreated event to record the deployment on-chain
     * @param _signer Address of the signer who will verify screening and reward claiming signatures (server wallet, owner of taskMaster)
     * @param taskMaster Address of the taskMaster who will own and manage the contract (smart account wallet, owned by the _signer)
     * @param _rewardAmountPerParticipantProxyInWei Amount in wei to reward each participantProxy
     * @param _targetNumberOfParticipantProxies Maximum number of participantProxies for the task
     * @param _rewardToken Address of the ERC20 token contract used for rewards
     */
    constructor(
        address _signer,
        address taskMaster,
        uint256 _rewardAmountPerParticipantProxyInWei,
        uint256 _targetNumberOfParticipantProxies,
        address _rewardToken
    ) Ownable(taskMaster) EIP712("TaskManager", "1") {
        require(
            _rewardToken != address(0),
            "Zero address given for reward Token"
        );

        require(taskMaster != address(0), "Zero address given for taskMaster");

        require(_signer != address(0), "Zero address given for _signer");

        require(
            _rewardAmountPerParticipantProxyInWei > 0,
            "Invalid reward amount"
        );

        require(
            _targetNumberOfParticipantProxies > 0,
            "Invalid number of target participantProxies"
        );

        rewardToken = IERC20(_rewardToken);

        signer = _signer;

        rewardAmountPerParticipantProxyInWei = _rewardAmountPerParticipantProxyInWei;
        targetNumberOfParticipantProxies = _targetNumberOfParticipantProxies;

        emit TaskManagerCreated(address(this), taskMaster, _signer);
    }

    /**
     * @notice Registers a participantProxy as screened for the task
     * @dev Marks the participantProxy as eligible to claim rewards if they pass screening
     * @param participantProxy Address of the participantProxy to screen (server-managed wallet)
     * @param taskId Unique identifier for this task instance
     * @param nonce Unique number to prevent replay attacks
     * @param signature Cryptographic signature from the contract owner
     */
    function screenParticipantProxy(
        address participantProxy,
        string memory taskId,
        uint256 nonce,
        bytes memory signature
    )
        external
        whenNotPaused
        onlyIfSenderIsGivenParticipantProxy(participantProxy)
        onlyWhenAllParticipantProxiesHaveNotBeenRewarded
        onlyUnscreenedParticipantProxy(participantProxy)
        onlyUnrewardedParticipantProxy(participantProxy)
        onlyIfGivenScreeningSignatureIsValid(
            participantProxy,
            taskId,
            nonce,
            signature
        )
        onlyIfGivenScreeningSignatureIsUnused(signature)
        onlyIfContractHasEnoughRewardTokensForAllPotentialRewards
        onlyWhenTargetNumberOfParticipantProxiesNotIsNotReached
    {
        require(participantProxy != address(0), "Zero address passed");

        participantProxiesScreenedForTask[participantProxy] = true;

        unchecked {
            ++numberOfScreenedParticipantProxies;
        }

        markScreeningSignatureAsHavingBeenUsed(signature, participantProxy);

        emit ParticipantProxyScreened(participantProxy);
    }

    /**
     * @notice Creates a hash for screening signature verification using EIP-712
     * @dev Combines contract-specific data with participantProxy info
     * @param participantProxy The wallet address of the participantProxy being screened
     * @param taskId A unique identifier for this specific task
     * @param nonce Unique number to prevent replay attacks
     * @return bytes32 The EIP-712 typed data hash
     */
    function getMessageHashForParticipantProxyScreening(
        address participantProxy,
        string memory taskId,
        uint256 nonce
    ) private view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
            SCREENING_REQUEST_TYPEHASH,
            participantProxy,
            keccak256(bytes(taskId)),
            nonce
        )));
    }

    /**
     * @notice Creates a hash for reward claiming signature verification using EIP-712
     * @dev Combines contract-specific data with participantProxy info
     * @param participantProxy The wallet address of the participantProxy claiming the reward
     * @param rewardId A unique identifier for this specific reward claim
     * @param nonce Unique number to prevent replay attacks
     * @return bytes32 The EIP-712 typed data hash
     */
    function getMessageHashForRewardClaiming(
        address participantProxy,
        string memory rewardId,
        uint256 nonce
    ) private view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
            REWARD_CLAIM_REQUEST_TYPEHASH,
            participantProxy,
            keccak256(bytes(rewardId)),
            nonce
        )));
    }

    /**
     * @notice Verifies that a signature is valid for participantProxy screening using EIP-712
     * @dev Recovers the signer from the signature and compares with contract signer
     * @param participantProxy Address of the participantProxy being screened
     * @param taskId Unique identifier for this screening
     * @param nonce Unique number to prevent replay attacks
     * @param signature Cryptographic signature to verify
     * @return bool True if signature was signed by the contract signer, false otherwise
     */
    function verifySignatureForParticipantProxyScreening(
        address participantProxy,
        string memory taskId,
        uint256 nonce,
        bytes memory signature
    ) private view returns (bool) {
        bytes32 hash = getMessageHashForParticipantProxyScreening(
            participantProxy,
            taskId,
            nonce
        );
        address recoveredSigner = ECDSA.recover(hash, signature);
        return recoveredSigner == signer;
    }

    /**
     * @notice Verifies that a signature is valid for reward claiming using EIP-712
     * @dev Recovers the signer from the signature and compares with contract signer
     * @param participantProxy Address of the participantProxy claiming the reward
     * @param rewardId Unique identifier for this reward claim
     * @param nonce Unique number to prevent replay attacks
     * @param signature Cryptographic signature to verify
     * @return bool True if signature was signed by the contract signer, false otherwise
     */
    function verifySignatureForRewardClaiming(
        address participantProxy,
        string memory rewardId,
        uint256 nonce,
        bytes memory signature
    ) private view returns (bool) {
        bytes32 hash = getMessageHashForRewardClaiming(
            participantProxy,
            rewardId,
            nonce
        );
        address recoveredSigner = ECDSA.recover(hash, signature);
        return recoveredSigner == signer;
    }

    /**
     * @notice Processes a participantProxy's reward claim with signature verification
     * @dev Handles the entire reward claim workflow with multiple security checks
     *      Transfers tokens to a PaxAccount contract address, not directly to end users
     * @param participantProxy Address of the server wallet claiming the reward
     * @param paxAccountContractAddress Contract address where the reward should be sent
     * @param rewardId Unique identifier for this reward claim
     * @param nonce Unique number to prevent replay attacks
     * @param signature Cryptographic signature from the contract owner
     */
    function processRewardClaimByParticipantProxy(
        address participantProxy,
        address paxAccountContractAddress,
        string memory rewardId,
        uint256 nonce,
        bytes memory signature
    )
        external
        whenNotPaused
        onlyIfSenderIsGivenParticipantProxy(participantProxy)
        onlyWhenAllParticipantProxiesHaveNotBeenRewarded
        onlyUnrewardedParticipantProxy(participantProxy)
        mustBeScreened(participantProxy)
        onlyIfGivenClaimingSignatureIsValid(
            participantProxy,
            rewardId,
            nonce,
            signature
        )
        onlyIfGivenClaimingSignatureIsUnused(signature)
        onlyIfContractHasEnoughRewardTokens
    {
        require(paxAccountContractAddress != address(0), "Zero address passed");

        bool rewardTransferIsSuccesful = transferRewardToPaxAccount(
            paxAccountContractAddress
        );

        if (rewardTransferIsSuccesful) {
            markClaimingSignatureAsHavingBeenUsed(signature, participantProxy);
            markParticipantProxyAsHavingClaimedReward(
                participantProxy,
                paxAccountContractAddress
            );
        }
    }

    /**
     * @notice Transfers reward tokens to a PaxAccount contract
     * @dev Internal function to handle the actual token transfer
     * @param paxAccountContractAddress Address of the PaxAccount contract to receive the reward
     * @return bool True if the token transfer was successful
     */
    function transferRewardToPaxAccount(address paxAccountContractAddress)
        private
        returns (bool)
    {
        bool rewardTransferIsSuccesful = rewardToken.transfer(
            paxAccountContractAddress,
            rewardAmountPerParticipantProxyInWei
        );

        if (rewardTransferIsSuccesful) {
            unchecked {
                ++numberOfRewardedParticipantProxies;
            }
            emit PaxAccountRewarded(
                paxAccountContractAddress,
                rewardAmountPerParticipantProxyInWei
            );
        }

        return rewardTransferIsSuccesful;
    }

    /**
     * @notice Updates internal state to mark a participantProxy as having claimed their reward
     * @dev Called after successful token transfer to update tracking data
     * @param participantProxy The address of the server wallet that initiated the claim
     * @param paxAccountContractAddress The PaxAccount contract address that received the reward
     */
    function markParticipantProxyAsHavingClaimedReward(
        address participantProxy,
        address paxAccountContractAddress
    ) private {
        rewardedParticipantProxies[participantProxy] = true;

        unchecked {
            ++numberOfClaimedRewards;
        }
        emit ParticipantProxyMarkedAsRewarded(
            participantProxy,
            paxAccountContractAddress
        );
    }

    /**
     * @notice Updates internal state to mark a screening signature as used
     * @dev Prevents signature reuse in future task screenings
     * @param signature The signature to mark as used
     * @param participantProxy The address of the participantProxy who used the signature
     */
    function markScreeningSignatureAsHavingBeenUsed(
        bytes memory signature,
        address participantProxy
    ) private {
        signaturesUsedForScreening[signature] = true;
        unchecked {
            ++numberOfUsedScreeningSignatures;
        }
        emit ScreeningSignatureUsed(signature, participantProxy);
    }

    /**
     * @notice Updates internal state to mark a claiming signature as used
     * @dev Prevents signature reuse in future reward claims
     * @param signature The signature to mark as used
     * @param participantProxy The address of the participantProxy who used the signature
     */
    function markClaimingSignatureAsHavingBeenUsed(
        bytes memory signature,
        address participantProxy
    ) private {
        signaturesUsedForClaiming[signature] = true;

        unchecked {
            ++numberOfUsedClaimingSignatures;
        }
        emit ClaimingSignatureUsed(signature, participantProxy);
    }

    /**
     * @notice Allows the taskMaster to withdraw all remaining reward tokens
     * @dev Transfers the entire contract balance of reward tokens to the owner
     */
    function withdrawAllRewardTokenToTaskMaster()
        external
        onlyOwner
        whenNotPaused
        onlyIfContractHasAnyRewardTokens
    {
        uint256 balance = rewardToken.balanceOf(address(this));
        bool transferIsSuccessful = rewardToken.transfer(owner(), balance);

        if (transferIsSuccessful) {
            emit RewardTokenWithdrawn(owner(), balance);
        }
    }

    /**
     * @notice Allows the taskMaster to withdraw any ERC20 token from the contract
     * @dev Useful for recovering tokens accidentally sent to the contract
     * @param token The ERC20 token contract to withdraw tokens from
     */
    function withdrawAllGivenTokenToTaskMaster(IERC20 token)
        external
        onlyOwner
        whenNotPaused
        onlyIfContractHasAnyGivenToken(token)
    {
        uint256 balance = token.balanceOf(address(this));
        bool transferIsSuccessful = token.transfer(owner(), balance);

        if (transferIsSuccessful) {
            emit GivenTokenWithdrawn(owner(), token, balance);
        }
    }

    /**
     * @notice Updates the reward amount given for each task completion
     * @dev Can be adjusted by the taskMaster to respond to token price changes
     * @param _newRewardAmountPerParticipantProxyInWei New reward amount in token's smallest unit (wei)
     */
    function updateRewardAmountPerParticipantProxy(
        uint256 _newRewardAmountPerParticipantProxyInWei
    ) external onlyOwner {
        require(
            _newRewardAmountPerParticipantProxyInWei != 0,
            "Zero reward amount given"
        );

        uint256 oldRewardAmountPerParticipantProxyInWei = rewardAmountPerParticipantProxyInWei;

        uint256 newRewardAmountPerParticipantProxyInWei = _newRewardAmountPerParticipantProxyInWei;
        rewardAmountPerParticipantProxyInWei = newRewardAmountPerParticipantProxyInWei;

        emit RewardAmountUpdated(
            oldRewardAmountPerParticipantProxyInWei,
            newRewardAmountPerParticipantProxyInWei
        );
    }

    /**
     * @notice Updates the maximum number of participantProxies allowed in the task
     * @dev Can only increase the target number, never decrease it
     * @param _newTargetNumberOfParticipantProxies New maximum number of participantProxies
     */
    function updateTargetNumberOfParticipantProxies(
        uint256 _newTargetNumberOfParticipantProxies
    ) external onlyOwner {
        require(
            _newTargetNumberOfParticipantProxies != 0,
            "Zero number of target participantProxies given"
        );

        require(
            _newTargetNumberOfParticipantProxies >=
                targetNumberOfParticipantProxies,
            "New number of target participantProxies given is less than current number (of target participantProxies)"
        );

        uint256 oldTargetNumberOfParticipantProxies = targetNumberOfParticipantProxies;

        uint256 newTargetNumberOfParticipantProxies = _newTargetNumberOfParticipantProxies;

        targetNumberOfParticipantProxies = newTargetNumberOfParticipantProxies;

        emit TargetNumberOfParticipantProxiesUpdated(
            oldTargetNumberOfParticipantProxies,
            newTargetNumberOfParticipantProxies
        );
    }

    /**
     * @notice Temporarily halts all task operations including screening and reward claims
     * @dev Used in emergency situations or when issues are detected
     */
    function pauseTask() external onlyOwner {
        _pause();
    }

    /**
     * @notice Resumes normal task operations after a pause
     * @dev Enables screening and reward claims to proceed again
     */
    function unpauseTask() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Checks if a participantProxy has completed the screening process
     * @dev Public view function for off-chain status checks
     * @param participantProxy Address of the participantProxy to check
     * @return bool True if the participantProxy has been screened
     */
    function checkIfParticipantProxyIsScreened(address participantProxy)
        external
        view
        returns (bool)
    {
        return participantProxiesScreenedForTask[participantProxy];
    }

    /**
     * @notice Checks if a participantProxy has received their reward
     * @dev Public view function for off-chain status checks
     * @param participantProxy Address of the participantProxy to check
     * @return bool True if the participantProxy has been rewarded
     */
    function checkIfParticipantProxyIsRewarded(address participantProxy)
        external
        view
        returns (bool)
    {
        return rewardedParticipantProxies[participantProxy];
    }

    /**
     * @notice Checks if a signature has been used for claiming a reward
     * @dev Public view function for signature validation
     * @param signature Cryptographic signature to check
     * @return bool True if the signature has already been used
     */
    function checkIfClaimingSignatureIsUsed(bytes memory signature)
        external
        view
        returns (bool)
    {
        return signaturesUsedForClaiming[signature];
    }

    /**
     * @notice Checks if a signature has been used for screening a participantProxy
     * @dev Public view function for signature validation
     * @param signature Cryptographic signature to check
     * @return bool True if the signature has already been used
     */
    function checkIfScreeningSignatureIsUsed(bytes memory signature)
        external
        view
        returns (bool)
    {
        return signaturesUsedForScreening[signature];
    }

    /**
     * @notice Checks if the contract is currently paused
     * @dev Used to determine if task operations are currently halted
     * @return bool True if the contract is paused, false otherwise
     */
    function checkIfContractIsPaused() external view returns (bool) {
        return paused();
    }

    /**
     * @notice Gets the current balance of reward tokens in the contract
     * @dev Indicates how many more rewards can be distributed
     * @return uint256 The current reward token balance in wei
     */
    function getRewardTokenContractBalanceAmount()
        external
        view
        returns (uint256)
    {
        return rewardToken.balanceOf(address(this));
    }

    /**
     * @notice Gets the contract address of the reward token
     * @dev Returns the ERC20 token interface used for rewards
     * @return IERC20Metadata The ERC20 interface of the reward token
     */
    function getRewardTokenContractAddress()
        external
        view
        returns (IERC20)
    {
        return rewardToken;
    }

    /**
     * @notice Gets the current reward amount per participantProxy
     * @dev Returns the exact amount each PaxAccount will receive per task completion
     * @return uint256 The reward amount in token's smallest unit (wei)
     */
    function getRewardAmountPerParticipantProxyInWei()
        external
        view
        returns (uint256)
    {
        return rewardAmountPerParticipantProxyInWei;
    }

    /**
     * @notice Gets the current count of rewarded participantProxies
     * @dev Used to track progress toward the target
     * @return uint256 The number of participantProxies who have received rewards
     */
    function getNumberOfRewardedParticipantProxies()
        external
        view
        returns (uint256)
    {
        return numberOfRewardedParticipantProxies;
    }

    /**
     * @notice Gets the maximum number of participantProxies for the task
     * @dev Used to determine when the task is complete
     * @return uint256 The target number of participantProxies
     */
    function getTargetNumberOfParticipantProxies()
        external
        view
        returns (uint256)
    {
        return targetNumberOfParticipantProxies;
    }

    /**
     * @notice Gets the number of participantProxies who have completed screening
     * @dev Indicates how many participantProxies are eligible to claim rewards
     * @return uint256 The count of screened participantProxies
     */
    function getNumberOfScreenedParticipantProxies()
        external
        view
        returns (uint256)
    {
        return numberOfScreenedParticipantProxies;
    }

    /**
     * @notice Gets the number of screening signatures that have been used
     * @dev Used for tracking and auditing signature usage
     * @return uint256 The count of used screening signatures
     */
    function getNumberOfUsedScreeningSignatures()
        external
        view
        returns (uint256)
    {
        return numberOfUsedScreeningSignatures;
    }

    /**
     * @notice Gets the number of claiming signatures that have been used
     * @dev Used for tracking and auditing signature usage
     * @return uint256 The count of used claiming signatures
     */
    function getNumberOfUsedClaimingSignatures()
        external
        view
        returns (uint256)
    {
        return numberOfUsedClaimingSignatures;
    }

    /**
     * @notice Gets the count of rewards that have been successfully claimed
     * @dev Should match numberOfRewardedParticipantProxies if all operations are successful
     * @return uint256 The number of claimed rewards
     */
    function getNumberOfClaimedRewards() external view returns (uint256) {
        return numberOfClaimedRewards;
    }

    /**
     * @notice Gets the address of the contract owner (taskMaster)
     * @dev The owner has special permissions to manage the task
     * @return address The taskMaster's address
     */
    function getOwner() external view returns (address) {
        return owner();
    }

    /**
     * @notice Gets the address of the signer
     * @dev The signer verifies screening and reward claiming signatures
     * @return address The signer address
     */
    function getSigner() external view returns (address) {
        return signer;
    }
}

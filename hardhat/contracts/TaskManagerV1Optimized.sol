// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

/**
 * @notice Gas-optimized smart contract for managing a task completion system with ERC20 token rewards
 * @dev Inherits from Ownable for taskManager access control and Pausable for emergency stops
 */
contract TaskManagerV1Optimized is Ownable, Pausable {
    using ECDSA for bytes32;

    // Constants for bit positions in participant flags
    uint256 private constant SCREENED_FLAG = 1;
    uint256 private constant REWARDED_FLAG = 2;

    // Immutable variables
    IERC20Metadata private immutable rewardToken;

    // Storage optimization: Pack related storage variables
    struct ParticipantState {
        uint256 flags; // Bit 0: screened, Bit 1: rewarded
    }

    // Maps participant address to their state
    mapping(address => ParticipantState) private participantProxyStates;
    
    // Maps signatures to usage state (true if used)
    mapping(bytes32 => bool) private usedSignatureHashes;

    // Configuration
    uint256 private rewardAmountPerParticipantProxyInWei;
    uint256 private targetNumberOfParticipantProxies;

    // Counters
    uint256 private numberOfRewardedParticipantProxies;
    uint256 private numberOfClaimedRewards;
    uint256 private numberOfScreenedParticipantProxies;
    uint256 private numberOfUsedScreeningSignatures;
    uint256 private numberOfUsedClaimingSignatures;

    // Events - Consolidated for gas efficiency
    event ParticipantProxyScreened(
        address indexed participantProxy,
        bytes32 indexed signatureHash
    );
    
    event PaxAccountRewarded(
        address indexed participantProxy,
        address indexed paxAccountContractAddress,
        uint256 rewardAmount,
        bytes32 indexed signatureHash
    );
    
    event ConfigurationUpdated(
        uint256 oldValue,
        uint256 newValue,
        uint8 updateType
    );
    
    event TokenWithdrawn(
        address indexed tokenAddress,
        uint256 amount
    );

    /**
     * @notice Initializes the task management contract with initial parameters
     */
    constructor(
        address taskManager,
        uint256 _rewardAmountPerParticipantProxyInWei,
        uint256 _targetNumberOfParticipantProxies,
        address _rewardToken
    ) Ownable(taskManager) {
        require(_rewardToken != address(0), "Zero address given for reward Token");
        require(taskManager != address(0), "Zero address given for taskManager");
        require(_rewardAmountPerParticipantProxyInWei > 0, "Invalid reward amount");
        require(_targetNumberOfParticipantProxies > 0, "Invalid number of target participantProxies");

        rewardToken = IERC20Metadata(_rewardToken);
        rewardAmountPerParticipantProxyInWei = _rewardAmountPerParticipantProxyInWei;
        targetNumberOfParticipantProxies = _targetNumberOfParticipantProxies;
    }

    /**
     * @notice Registers a participantProxy as screened for the task
     */
    function screenParticipantProxy(
        address participantProxy,
        string calldata taskId,
        uint256 nonce,
        bytes calldata signature
    ) external whenNotPaused {
        // Validate participant and signature
        _validateParticipantForScreening(participantProxy);
        _validateAndMarkSignature(
            _hashScreeningMessage(participantProxy, taskId, nonce),
            signature,
            true
        );

        // Update participant state
        ParticipantState storage state = participantProxyStates[participantProxy];
        state.flags |= SCREENED_FLAG;

        // Update counters
        unchecked {
            ++numberOfScreenedParticipantProxies;
            ++numberOfUsedScreeningSignatures;
        }

        // Emit event
        emit ParticipantProxyScreened(
            participantProxy,
            keccak256(signature)
        );
    }

    /**
     * @notice Processes a participantProxy's reward claim with signature verification
     */
    function processRewardClaimByParticipantProxy(
        address participantProxy,
        address paxAccountContractAddress,
        string calldata rewardId,
        uint256 nonce,
        bytes calldata signature
    ) external whenNotPaused {
        // Validate participant, signature, and contract state
        _validateParticipantForRewarding(participantProxy, paxAccountContractAddress);
        _validateAndMarkSignature(
            _hashClaimingMessage(participantProxy, rewardId, nonce),
            signature,
            false
        );
        require(
            rewardToken.balanceOf(address(this)) >= rewardAmountPerParticipantProxyInWei,
            "Contract does not have enough of the reward token"
        );

        // Transfer reward
        bool rewardTransferIsSuccesful = rewardToken.transfer(
            paxAccountContractAddress,
            rewardAmountPerParticipantProxyInWei
        );

        // Update state if transfer successful
        if (rewardTransferIsSuccesful) {
            // Mark participantProxy as rewarded
            ParticipantState storage state = participantProxyStates[participantProxy];
            state.flags |= REWARDED_FLAG;

            // Update counters
            unchecked {
                ++numberOfRewardedParticipantProxies;
                ++numberOfClaimedRewards;
                ++numberOfUsedClaimingSignatures;
            }

            // Emit event
            emit PaxAccountRewarded(
                participantProxy,
                paxAccountContractAddress,
                rewardAmountPerParticipantProxyInWei,
                keccak256(signature)
            );
        }
    }

    /**
     * @notice Validates participant for screening operation
     */
    function _validateParticipantForScreening(address participantProxy) internal view {
        require(msg.sender == participantProxy, "Only valid sender");
        require(participantProxy != address(0), "Zero address passed");
        require(
            numberOfRewardedParticipantProxies < targetNumberOfParticipantProxies,
            "All participantProxies have been rewarded"
        );
        
        ParticipantState storage state = participantProxyStates[participantProxy];
        require((state.flags & SCREENED_FLAG) == 0, "Only unscreened address");
        require((state.flags & REWARDED_FLAG) == 0, "ParticipantProxy already rewarded");
    }

    /**
     * @notice Validates participant for reward claiming operation
     */
    function _validateParticipantForRewarding(
        address participantProxy, 
        address paxAccountContractAddress
    ) internal view {
        require(msg.sender == participantProxy, "Only valid sender");
        require(paxAccountContractAddress != address(0), "Zero address passed");
        require(
            numberOfRewardedParticipantProxies < targetNumberOfParticipantProxies,
            "All participantProxies have been rewarded"
        );
        
        ParticipantState storage state = participantProxyStates[participantProxy];
        require((state.flags & SCREENED_FLAG) != 0, "Must be screened");
        require((state.flags & REWARDED_FLAG) == 0, "ParticipantProxy already rewarded");
    }

    /**
     * @notice Validates signature and marks it as used
     */
    function _validateAndMarkSignature(
        bytes32 messageHash,
        bytes calldata signature,
        bool /* isScreening */ // Removed unused parameter
    ) internal {
        // Create Ethereum signed message hash
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(messageHash);
        
        // Verify signature was signed by owner
        require(ethSignedMessageHash.recover(signature) == owner(), "Invalid signature");

        // Compute hash of signature for storage efficiency
        bytes32 signatureHash = keccak256(signature);
        
        // Ensure signature hasn't been used before
        require(!usedSignatureHashes[signatureHash], "Signature already used");
        
        // Mark signature as used
        usedSignatureHashes[signatureHash] = true;
    }

    /**
     * @notice Creates a hash for screening signature verification
     */
    function _hashScreeningMessage(
        address participantProxy,
        string calldata taskId,
        uint256 nonce
    ) internal view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                address(this),
                block.chainid,
                participantProxy,
                taskId,
                nonce
            )
        );
    }

    /**
     * @notice Creates a hash for reward claiming signature verification
     */
    function _hashClaimingMessage(
        address participantProxy,
        string calldata rewardId,
        uint256 nonce
    ) internal view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                address(this),
                block.chainid,
                participantProxy,
                rewardId,
                nonce
            )
        );
    }

    /**
     * @notice Allows the taskManager to withdraw all remaining reward tokens
     */
    function withdrawAllRewardTokenToTaskManager() external onlyOwner whenNotPaused {
        uint256 balance = rewardToken.balanceOf(address(this));
        require(balance > 0, "Contract does not have any reward tokens");
        
        bool transferIsSuccessful = rewardToken.transfer(owner(), balance);
        
        if (transferIsSuccessful) {
            emit TokenWithdrawn(address(rewardToken), balance);
        }
    }

    /**
     * @notice Allows the taskManager to withdraw any ERC20 token from the contract
     */
    function withdrawAllGivenTokenTotaskManager(IERC20Metadata token) external onlyOwner whenNotPaused {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "Contract does not have any of the given token");
        
        bool transferIsSuccessful = token.transfer(owner(), balance);
        
        if (transferIsSuccessful) {
            emit TokenWithdrawn(address(token), balance);
        }
    }

    /**
     * @notice Updates the reward amount given for each task completion
     */
    function updateRewardAmountPerParticipantProxy(
        uint256 _newRewardAmountPerParticipantProxyInWei
    ) external onlyOwner {
        require(_newRewardAmountPerParticipantProxyInWei != 0, "Zero reward amount given");

        uint256 oldValue = rewardAmountPerParticipantProxyInWei;
        rewardAmountPerParticipantProxyInWei = _newRewardAmountPerParticipantProxyInWei;

        emit ConfigurationUpdated(oldValue, _newRewardAmountPerParticipantProxyInWei, 0);
    }

    /**
     * @notice Updates the maximum number of participantProxies allowed in the task
     */
    function updateTargetNumberOfParticipantProxies(
        uint256 _newTargetNumberOfParticipantProxies
    ) external onlyOwner {
        require(_newTargetNumberOfParticipantProxies != 0, "Zero number of target participantProxies given");
        require(
            _newTargetNumberOfParticipantProxies >= targetNumberOfParticipantProxies,
            "New target must be >= current target"
        );

        uint256 oldValue = targetNumberOfParticipantProxies;
        targetNumberOfParticipantProxies = _newTargetNumberOfParticipantProxies;

        emit ConfigurationUpdated(oldValue, _newTargetNumberOfParticipantProxies, 1);
    }

    /**
     * @notice Pauses and unpauses contract functions
     */
    function pausetask() external onlyOwner { _pause(); }
    function unpausetask() external onlyOwner { _unpause(); }

    /**
     * @notice View functions for contract state
     */
    function checkIfParticipantProxyIsScreened(address participantProxy) external view returns (bool) {
        return (participantProxyStates[participantProxy].flags & SCREENED_FLAG) != 0;
    }

    function checkIfParticipantProxyIsRewarded(address participantProxy) external view returns (bool) {
        return (participantProxyStates[participantProxy].flags & REWARDED_FLAG) != 0;
    }

    function checkIfSignatureIsUsed(bytes calldata signature) external view returns (bool) {
        return usedSignatureHashes[keccak256(signature)];
    }

    function checkIfContractIsPaused() external view returns (bool) {
        return paused();
    }

    function getRewardTokenContractBalanceAmount() external view returns (uint256) {
        return rewardToken.balanceOf(address(this));
    }

    function getRewardTokenContractAddress() external view returns (IERC20Metadata) {
        return rewardToken;
    }

    function getRewardAmountPerParticipantProxyInWei() external view returns (uint256) {
        return rewardAmountPerParticipantProxyInWei;
    }

    function getNumberOfRewardedParticipantProxies() external view returns (uint256) {
        return numberOfRewardedParticipantProxies;
    }

    function getTargetNumberOfParticipantProxies() external view returns (uint256) {
        return targetNumberOfParticipantProxies;
    }

    function getNumberOfScreenedParticipantProxies() external view returns (uint256) {
        return numberOfScreenedParticipantProxies;
    }

    function getNumberOfUsedScreeningSignatures() external view returns (uint256) {
        return numberOfUsedScreeningSignatures;
    }

    function getNumberOfUsedClaimingSignatures() external view returns (uint256) {
        return numberOfUsedClaimingSignatures;
    }

    function getNumberOfClaimedRewards() external view returns (uint256) {
        return numberOfClaimedRewards;
    }

    function getOwner() external view returns (address) {
        return owner();
    }
}
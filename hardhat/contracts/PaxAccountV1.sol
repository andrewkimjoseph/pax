// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/**
 * @title PaxAccountV1
 * @notice Smart contract for managing payment methods and token withdrawals with upgrade capability
 * @dev Implements the UUPS (Universal Upgradeable Proxy Standard) pattern
 *      This contract is upgradeable, allowing for future improvements while preserving state and address
 *      Inherits from Initializable for proxy-compatibility, OwnableUpgradeable for access control,
 *      and UUPSUpgradeable for upgrade functionality
 */
contract PaxAccountV1 is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    /**
     * @notice Structure representing a payment method with its ID and address
     * @dev Used for returning paired payment method data
     */
    struct PaymentMethod {
        uint256 id;
        address paymentAddress;
    }

    /**
     * @notice Structure representing a token's balance
     * @dev Pairs a token address with its corresponding balance
     */
    struct TokenBalance {
        address tokenAddress;
        uint256 balance;
    }

    /**
     * @notice Address of the primary payment method
     * @dev Cannot use immutable in upgradeable contracts; stored as a regular state variable
     *      This address serves as the default destination for token operations
     */
    address private primaryPaymentMethod;

    /**
     * @notice Tracks historical withdrawal amounts for each token
     * @dev Maps token addresses to cumulative withdrawal amounts in wei
     *      Used for auditing and tracking total withdrawals per token
     */
    mapping(address => uint256) public historicalTokenWithdrawalAmounts;

    /**
     * @notice Storage for registered payment methods
     * @dev Maps hash keys to payment method addresses
     *      The key is keccak256(abi.encodePacked(paymentMethodId))
     */
    mapping(bytes32 => address) public paymentMethods;

    /**
     * @notice Counter for the total number of registered payment methods
     * @dev Incremented whenever a new payment method is added
     *      Used to track and iterate through payment methods
     */
    uint256 public numberOfPaymentMethods;

    /**
     * @notice Emitted when tokens are withdrawn to a payment method
     * @param paymentMethod The address of the payment method that received the tokens
     * @param amountRequested The amount of tokens withdrawn
     * @param currencySymbol The token currency name
     * @dev Provides transparency for token movement out of the contract
     */
    event TokenWithdrawn(
        address paymentMethod,
        uint256 amountRequested,
        bytes32 currencySymbol
    );

    /**
     * @notice Emitted when a new payment method is registered
     * @param paymentMethodId The ID assigned to the new payment method
     * @param paymentMethod The address of the payment method
     * @dev Used for off-chain tracking and verification of payment method additions
     */
    event PaymentMethodAdded(uint256 paymentMethodId, address paymentMethod);

    /**
     * @notice Emitted when a new PaxAccount proxy is created
     * @param paxAccount The address of the newly created PaxAccount proxy
     * @dev Provides transparency for tracking new account deployments
     */
    event PaxAccountCreated(address indexed paxAccount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the contract instead of using a constructor
     * @dev Sets up the contract with initial owner and primary payment method
     *      Adds the primary payment method as the first registered payment method (ID 0)
     * @param _owner The address that will become the contract owner
     * @param _primaryPaymentMethod The address of the initial primary payment method
     */
    function initialize(
        address _owner,
        address _primaryPaymentMethod
    ) public initializer {
        require(
            _primaryPaymentMethod != address(0),
            "Primary payment method cannot be zero address"
        );

        __Ownable_init(_owner);
        __UUPSUpgradeable_init();

        primaryPaymentMethod = _primaryPaymentMethod;

        // Add the primary payment method as the first payment method
        bytes32 key = keccak256(abi.encodePacked(uint256(0)));
        paymentMethods[key] = _primaryPaymentMethod;
        numberOfPaymentMethods = 1;

        emit PaymentMethodAdded(0, _primaryPaymentMethod);
        emit PaxAccountCreated(address(this));
    }

    /**
     * @notice Withdraw tokens to a specified payment method
     * @dev Transfers tokens from the contract to a registered payment method
     *      Updates historical withdrawal tracking for the token
     * @param paymentMethodId The ID of the payment method to withdraw to
     * @param amountRequested The amount of tokens to withdraw in smallest units (wei)
     * @param currency The token to withdraw, specified as an ERC20 interface
     */
    function withdrawToPaymentMethod(
        uint256 paymentMethodId,
        uint256 amountRequested,
        ERC20Upgradeable currency
    ) external onlyOwner {
        bytes32 key = keccak256(abi.encodePacked(paymentMethodId));
        address paymentMethod = paymentMethods[key];

        require(paymentMethod != address(0), "Payment method not found");
        require(amountRequested > 0, "Amount must be greater than zero");
        require(
            currency.balanceOf(address(this)) >= amountRequested,
            "Insufficient balance"
        );

        // Transfer tokens to the payment method
        bool success = currency.transfer(paymentMethod, amountRequested);
        require(success, "Token transfer failed");

        // Update historical withdrawal amount
        historicalTokenWithdrawalAmounts[address(currency)] += amountRequested;

        emit TokenWithdrawn(paymentMethod, amountRequested, bytes32(bytes(currency.symbol())));
    }

    /**
     * @notice Add a new payment method to the system
     * @dev Registers a new address as a valid payment destination
     *      Ensures uniqueness of payment method IDs and prevents zero addresses
     * @param paymentMethodId The ID for the new payment method
     * @param paymentMethod The address of the payment method
     */
    function addPaymentMethod(uint256 paymentMethodId, address paymentMethod)
        external
        onlyOwner
    {
        require(
            paymentMethod != address(0),
            "Payment method cannot be zero address"
        );
        require(
            paymentMethodId != 0,
            "ID 0 is reserved for primary payment method"
        );

        bytes32 key = keccak256(abi.encodePacked(paymentMethodId));
        require(
            paymentMethods[key] == address(0),
            "Payment method ID already exists"
        );

        // Add the payment method
        paymentMethods[key] = paymentMethod;
        numberOfPaymentMethods++;

        emit PaymentMethodAdded(paymentMethodId, paymentMethod);
    }

    /**
     * @notice Retrieve all registered payment methods
     * @dev Returns an array of tuples containing payment method IDs and corresponding addresses
     *      Iterates through potential IDs to find all registered payment methods
     * @return Array of PaymentMethod structs where each contains an ID and address
     */
    function getPaymentMethods()
        external
        view
        returns (PaymentMethod[] memory)
    {
        PaymentMethod[] memory result = new PaymentMethod[](
            numberOfPaymentMethods
        );

        uint256 counter = 0;
        for (uint256 i = 0; i < numberOfPaymentMethods + 10; i++) {
            // +10 to allow for gaps in IDs
            bytes32 key = keccak256(abi.encodePacked(i));
            if (paymentMethods[key] != address(0)) {
                result[counter] = PaymentMethod(i, paymentMethods[key]);
                counter++;

                if (counter >= numberOfPaymentMethods) {
                    break;
                }
            }
        }

        return result;
    }

    /**
     * @notice Get the balances of multiple tokens held by the contract
     * @dev Returns an array of TokenBalance structs with token addresses and their corresponding balances
     * @param tokens Array of token addresses to check balances for
     * @return Array of TokenBalance structs containing token addresses and balances
     */
    function getTokenBalances(ERC20Upgradeable[] calldata tokens)
        external
        view
        returns (TokenBalance[] memory)
    {
        TokenBalance[] memory balances = new TokenBalance[](tokens.length);

        for (uint256 i = 0; i < tokens.length; i++) {
            balances[i] = TokenBalance({
                tokenAddress: address(tokens[i]),
                balance: tokens[i].balanceOf(address(this))
            });
        }

        return balances;
    }

    /**
     * @notice Add a new non-primary payment method to the system
     * @dev Additional validation to ensure the address is not the primary payment method
     *      Prevents accidental duplication of the primary payment method
     * @param paymentMethodId The ID for the new payment method
     * @param newPaymentMethod The address of the payment method
     */
    function addNonPrimaryPaymentMethod(
        uint256 paymentMethodId,
        address newPaymentMethod
    ) external onlyOwner {
        require(
            newPaymentMethod != address(0),
            "Payment method cannot be zero address"
        );
        require(
            newPaymentMethod != primaryPaymentMethod,
            "Cannot add primary payment method as non-primary"
        );
        require(
            paymentMethodId != 0,
            "ID 0 is reserved for primary payment method"
        );

        bytes32 key = keccak256(abi.encodePacked(paymentMethodId));
        require(
            paymentMethods[key] == address(0),
            "Payment method ID already exists"
        );

        // Add the payment method
        paymentMethods[key] = newPaymentMethod;
        numberOfPaymentMethods++;

        emit PaymentMethodAdded(paymentMethodId, newPaymentMethod);
    }

    /**
     * @notice Get the primary payment method address
     * @dev Provides read access to the primary payment method
     * @return The address of the primary payment method
     */
    function getPrimaryPaymentMethod() external view returns (address) {
        return primaryPaymentMethod;
    }

    /**
     * @notice Function that authorizes upgrades to the implementation
     * @dev Required override for UUPSUpgradeable
     *      Only the contract owner can upgrade the implementation
     *      This controls who can initiate contract upgrades
     * @param newImplementation Address of the new implementation contract
     */
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     * The gap size is set to 50 to accommodate potential future state variables
     */
    uint256[50] private __gap;
}
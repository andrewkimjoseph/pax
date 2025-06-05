# Pax Smart Contracts

This directory contains the Solidity smart contracts that power the Pax platform's blockchain functionality on the Celo network. The contracts implement upgradeable, gas-optimized solutions for account abstraction, task management, and cryptocurrency reward distribution using the UUPS proxy pattern.

## Smart Contract Architecture

### PaxAccountV1.sol
The core user account contract implementing account abstraction and multi-currency wallet functionality:

- **Account Management**: Individual smart contract wallets for each user with upgradeable architecture
- **Multi-Currency Support**: Native support for CUSD, Good Dollar, USDT, and USDC tokens
- **Withdrawal Processing**: Secure withdrawal to linked payment methods (bank accounts, mobile money)
- **EIP-712 Signatures**: Cryptographic verification of withdrawal requests from the mobile app
- **Gas Abstraction**: Gasless transactions through ERC-4337 account abstraction
- **Reward Reception**: Automated receiving and tracking of task completion rewards

### TaskManagerV1.sol  
The task lifecycle management contract handling all task-related operations:

- **Task Creation**: Deploy and configure micro-tasks with token reward allocations
- **Participant Screening**: Cryptographic verification of participant eligibility using EIP-712
- **Task Completion**: Secure validation and processing of completed tasks
- **Reward Distribution**: Automated cryptocurrency payments to participant PaxAccount contracts
- **Multi-Token Rewards**: Support for distributing rewards in any of the supported ERC-20 tokens
- **Event Logging**: Comprehensive on-chain event emission for transparency and tracking

## Development Environment

### Technology Stack
- **Solidity 0.8.28**: Latest stable Solidity with advanced optimization features
- **Hardhat**: Ethereum development environment with TypeScript support
- **OpenZeppelin Contracts**: Security-audited contract libraries and upgradeable patterns
- **UUPS Proxy Pattern**: Gas-efficient upgradeable contract architecture
- **TypeScript**: Type-safe development environment and testing framework
- **Celo Network**: Carbon-negative, mobile-first blockchain platform

### Prerequisites
- **Node.js** (v18 or later) and npm
- **Hardhat CLI** for development and deployment
- **Git** for version control
- **Celo wallet** with testnet/mainnet CELO for deployments

### Installation

1. **Navigate to the Hardhat directory:**
   ```bash
   cd hardhat
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Compile contracts:**
   ```bash
   npx hardhat compile
   ```

### Development Workflow

#### Testing
```bash
# Run all tests with gas reporting
npm test

# Run specific test file
npx hardhat test test/02-paxAccount.test.ts

# Run tests with coverage
npx hardhat coverage

# Run tests with detailed gas reporting
REPORT_GAS=true npx hardhat test
```

#### Deployment

1. **Local development:**
   ```bash
   # Start local Hardhat node
   npx hardhat node
   
   # Deploy to local network (in another terminal)
   npx hardhat ignition deploy ignition/modules/TaskManagerV1.ts --network localhost
   ```

2. **Celo Alfajores testnet:**
   ```bash
   npx hardhat ignition deploy ignition/modules/TaskManagerV1.ts --network alfajores
   ```

3. **Celo mainnet:**
   ```bash
   npx hardhat ignition deploy ignition/modules/TaskManagerV1.ts --network celo
   ```

#### Contract Verification
```bash
# Verify on Celo Explorer (Alfajores)
npx hardhat verify --network alfajores <contract_address>

# Verify on Celo Explorer (Mainnet)
npx hardhat verify --network celo <contract_address>
```

## Contract Implementation Details

### PaxAccountV1 Contract Functions

#### Core Account Management
- **`initialize(address owner, address initialImplementation)`**: Sets up the upgradeable proxy with owner permissions
- **`getBalance(address token)`**: Returns the current balance for any supported ERC-20 token
- **`getWithdrawals()`**: Retrieves the complete withdrawal history for the account
- **`onERC20Received(address token, uint256 amount)`**: Handles incoming token transfers and reward distributions

#### Payment Method Management
- **`linkPaymentMethod(PaymentMethodType methodType, string calldata details)`**: Links external payment methods (bank accounts, mobile money, etc.)
- **`getPaymentMethods()`**: Returns all linked payment methods for withdrawal options
- **`updatePaymentMethod(uint256 methodId, string calldata newDetails)`**: Updates existing payment method information

#### Withdrawal Processing
- **`createWithdrawal(address token, uint256 amount, uint256 paymentMethodId, bytes calldata signature)`**: Initiates withdrawals with EIP-712 signature verification
- **`getWithdrawalStatus(uint256 withdrawalId)`**: Returns the current status of any withdrawal request
- **`cancelWithdrawal(uint256 withdrawalId)`**: Allows cancellation of pending withdrawals

### TaskManagerV1 Contract Functions

#### Task Lifecycle Management
- **`createTask(string calldata taskId, address rewardToken, uint256 rewardAmount, bytes calldata taskData)`**: Creates new tasks with token reward allocations
- **`getTaskDetails(string calldata taskId)`**: Returns comprehensive task information including rewards and status
- **`isTaskActive(string calldata taskId)`**: Checks if a task is currently available for participation

#### Participant Operations
- **`screenParticipant(string calldata taskId, address participant, bytes calldata signature)`**: Validates participant eligibility using EIP-712 cryptographic verification
- **`completeTask(string calldata taskId, address participant, bytes calldata completionData, bytes calldata signature)`**: Processes task completion with secure validation
- **`getParticipantStatus(string calldata taskId, address participant)`**: Returns the current status of a participant for a specific task

#### Reward Distribution
- **`distributeReward(string calldata taskId, address participant)`**: Transfers cryptocurrency rewards to participant PaxAccount contracts
- **`getRewardHistory(address participant)`**: Returns complete reward history for any participant
- **`calculateRewardAmount(string calldata taskId)`**: Computes the reward amount for successful task completion

## Security & Architecture Features

### 🛡️ Security Measures
- **EIP-712 Typed Signatures**: Cryptographic verification of all critical operations from the mobile app
- **Access Control**: OpenZeppelin's role-based permissions with owner-only administrative functions
- **Upgradeable Architecture**: UUPS proxy pattern for secure contract upgrades with timelock mechanisms
- **Comprehensive Testing**: 100% test coverage with integration tests and edge case validation
- **Audit-Ready Code**: Following OpenZeppelin standards and security best practices
- **Emergency Mechanisms**: Pausable functionality for emergency situations
- **Input Validation**: Extensive validation of all user inputs and external data

### ⚡ Gas Optimization
- **Storage Efficiency**: Packed structs and minimal storage usage patterns
- **Function Optimization**: Gas-efficient function implementations with optimized loops
- **Batch Operations**: Support for batching multiple operations in single transactions
- **Event-Driven Architecture**: Comprehensive event emission for off-chain indexing
- **Proxy Pattern**: UUPS proxies for reduced deployment costs and efficient upgrades

### 🔄 Upgradeability 
- **UUPS Proxy Pattern**: Upgradeable contracts with built-in upgrade authorization
- **Version Management**: Proper versioning and migration paths for contract upgrades
- **Backward Compatibility**: Ensuring existing user data remains accessible across upgrades
- **Deployment Scripts**: Automated deployment and upgrade processes with verification

### 🌍 Celo Network Integration
- **Multi-Currency Support**: Native integration with Celo ecosystem tokens (CUSD, cUSD, USDT, USDC)
- **Mobile-First Design**: Optimized for mobile wallet interactions and account abstraction
- **Carbon Negative**: Built on Celo's environmentally sustainable blockchain
- **Low Transaction Costs**: Leveraging Celo's low gas fees for micro-transactions

## Project Structure

```
hardhat/
├── contracts/                 # Solidity smart contracts
│   ├── PaxAccountV1.sol      # User account contract with account abstraction
│   └── TaskManagerV1.sol     # Task lifecycle management contract
├── test/                     # Comprehensive test suite
│   ├── 01-setup.test.ts      # Test environment setup and configuration
│   ├── 02-paxAccount.test.ts # PaxAccount contract functionality tests
│   ├── 03-taskManager.test.ts# TaskManager contract functionality tests
│   ├── 04-integration.test.ts# End-to-end integration tests
│   ├── abis/                 # Contract ABI definitions for testing
│   ├── bytecode/             # Contract bytecode for deployment testing
│   ├── deploy/               # Deployment helper functions
│   └── utils/                # Testing utilities and helper functions
├── ignition/                 # Hardhat Ignition deployment modules
│   └── modules/              # Deployment configuration for each contract
├── artifacts/                # Compiled contract artifacts (auto-generated)
├── cache/                    # Hardhat compilation cache (auto-generated)
├── hardhat.config.ts         # Hardhat configuration with network settings
├── tsconfig.json            # TypeScript configuration
└── package.json             # Node.js dependencies and scripts
```

## Development Guidelines

### Smart Contract Development
- **Security First**: Follow OpenZeppelin patterns and implement comprehensive access controls
- **Gas Efficiency**: Optimize storage usage and function implementations for minimal gas costs
- **Upgradeability**: Use UUPS proxy pattern for future-proof contract architecture
- **Documentation**: Write comprehensive NatSpec documentation for all public functions
- **Testing**: Achieve 100% test coverage with unit tests, integration tests, and edge cases

### Testing Strategy
- **Unit Tests**: Test individual contract functions in isolation
- **Integration Tests**: Test complete user workflows end-to-end
- **Gas Reporting**: Monitor and optimize gas usage for all operations
- **Security Testing**: Test access controls, input validation, and edge cases
- **Upgrade Testing**: Verify contract upgrade paths and data migration

### Code Quality
- **TypeScript**: Use TypeScript for all test files and deployment scripts
- **Linting**: Follow Solidity style guidelines and best practices
- **Version Control**: Use semantic versioning for contract upgrades
- **Documentation**: Maintain up-to-date README and inline documentation

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/contract-improvement`)
3. Write comprehensive tests for any new functionality
4. Ensure all tests pass with `npm test`
5. Verify gas optimization with `REPORT_GAS=true npm test`
6. Update documentation as needed
7. Commit your changes (`git commit -m 'Add contract improvement'`)
8. Push to the branch (`git push origin feature/contract-improvement`)
9. Open a Pull Request

## License

This project is proprietary and confidential. All rights reserved.

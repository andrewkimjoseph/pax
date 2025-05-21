# Pax Smart Contracts

This directory contains the smart contracts that power the Pax platform's blockchain functionality. The contracts are built using Hardhat and Solidity, implementing the core business logic for task management, rewards, and withdrawals.

## Core Contracts

### PaxAccount.sol
- Manages participant accounts and balances
- Handles payment method linking
- Processes withdrawals to payment methods
- Manages reward distributions

### TaskManager.sol
- Creates and manages tasks
- Handles participant screening
- Processes task completions
- Manages reward distributions

## Development

### Prerequisites
- Node.js (v16 or later)
- npm or yarn
- Hardhat CLI

### Installation
```bash
npm install
# or
yarn install
```

### Compilation
```bash
npx hardhat compile
```

### Testing
```bash
# Run all tests
npx hardhat test

# Run tests with gas reporting
REPORT_GAS=true npx hardhat test

# Run specific test file
npx hardhat test test/PaxAccount.test.js
```

### Deployment
```bash
# Deploy to local network
npx hardhat node
npx hardhat run scripts/deploy.js --network localhost

# Deploy to testnet
npx hardhat run scripts/deploy.js --network goerli

# Deploy to mainnet
npx hardhat run scripts/deploy.js --network mainnet
```

### Contract Verification
```bash
npx hardhat verify --network <network> <contract_address> <constructor_args>
```

## Contract Architecture

### PaxAccount Contract
- **Purpose**: Manages participant accounts and funds
- **Key Functions**:
  - `linkPaymentMethod`: Links a payment method to the account
  - `withdraw`: Processes withdrawals to linked payment methods
  - `receiveReward`: Handles incoming rewards
  - `getBalance`: Returns account balance

### TaskManager Contract
- **Purpose**: Manages tasks and their lifecycle
- **Key Functions**:
  - `createTask`: Creates a new task with rewards
  - `screenParticipant`: Validates participant eligibility
  - `completeTask`: Marks a task as complete
  - `distributeReward`: Handles reward distribution

## Security

- All contracts are thoroughly tested
- Gas optimization implemented
- Access control mechanisms in place
- Emergency pause functionality available
- Regular security audits conducted

## Gas Optimization

The contracts are optimized for gas efficiency:
- Minimal storage usage
- Efficient function calls
- Optimized data structures
- Batch operations where possible

## Contributing

1. Fork the repository
2. Create your feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is proprietary and confidential. All rights reserved.

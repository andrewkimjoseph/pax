# Pax - Online Micro Tasks Platform

Pax is a comprehensive platform that enables organizations to create and manage micro-tasks while rewarding participants with both stable and non-stable tokens. The platform combines mobile application development with blockchain technology to create a secure and efficient task management system.

## Project Overview

Pax consists of two main components:
1. **Mobile Application** (Flutter)
2. **Smart Contracts** (Solidity/Hardhat)

## System Architecture

The following diagram illustrates the complete flow of the Pax platform:

```mermaid
flowchart TD
    %% Style definitions
    classDef userAction fill:#d1c4e9,stroke:#7e57c2,stroke-width:2px,color:#4527a0
    classDef systemProcess fill:#bbdefb,stroke:#1976d2,stroke-width:1px,color:#0d47a1
    classDef blockchainAction fill:#ffccbc,stroke:#e64a19,stroke-width:2px,color:#bf360c
    classDef databaseAction fill:#c8e6c9,stroke:#388e3c,stroke-width:1px,color:#1b5e20
    classDef decision fill:#fff9c4,stroke:#fbc02d,stroke-width:1px,color:#f57f17
    classDef notification fill:#ffe0b2,stroke:#f57c00,stroke-width:1px,color:#e65100
    classDef error fill:#ffcdd2,stroke:#d32f2f,stroke-width:1px,color:#b71c1c
    classDef service fill:#e1f5fe,stroke:#0288d1,stroke-width:1px,color:#01579b
    classDef function fill:#f3e5f5,stroke:#7b1fa2,stroke-width:1px,color:#4a148c
    
    %% Main entry point
    START([User opens Pax App]) --> F1

    %% FLOW 1: Registration & Onboarding
    subgraph F1[FLOW 1: REGISTRATION]
        A1[User logs in with Google]:::userAction --> A2{Auth success?}:::decision
        A2 -->|No| A3[Show error]:::error --> A1
        A2 -->|Yes| A4[AppInitializer Service]:::service
        A4 --> A5[createPrivyServerWallet Function]:::function
        A5 --> A6[Create Ethereum server wallet]:::systemProcess
        A6 --> A7[createPaxAccountV1Proxy Function]:::function
        A7 --> A8[Deploy PaxAccount contract]:::blockchainAction
        A8 --> A9[Store contract & wallet info]:::systemProcess
        A9 --> A10[Create pax_accounts record]:::databaseAction
        A10 --> A11[Update participant with paxAccountId]:::databaseAction
    end

    %% FLOW 2: Payment Method Connection
    subgraph F2[FLOW 2: PAYMENT METHOD]
        B1[User enters payment details]:::userAction --> B2[WithdrawalService]:::service
        B2 --> B3{Valid?}:::decision
        B3 -->|No| B4[Show error]:::error --> B1
        B3 -->|Yes| B5[Create payment method request]:::systemProcess
        B5 --> B6[Fetch server wallet]:::systemProcess
        B6 --> B7[Call PaxAccount.linkPaymentMethod]:::blockchainAction
        B7 --> B8[Get transaction hash]:::blockchainAction
        B8 --> B9[Create payment_methods record]:::databaseAction
        B9 --> B10[Store linkingTxnHash]:::databaseAction
        B10 --> B11[FCMService Notification]:::notification
    end

    %% FLOW 3: TaskMaster Creating a Task
    subgraph F3[FLOW 3: TASK CREATION]
        C1[TaskMaster creates task]:::userAction --> C2[Validate task data]:::systemProcess
        C2 --> C3{Valid?}:::decision
        C3 -->|No| C4[Show error]:::error --> C1
        C3 -->|Yes| C5[Initialize task creation]:::systemProcess
        C5 --> C6[Deploy TaskManager contract]:::blockchainAction
        C6 --> C7[Calculate total reward amount]:::systemProcess
        C7 --> C8[Fund contract with total rewards]:::blockchainAction
        C8 --> C9[Create tasks record]:::databaseAction
        C9 --> C10[Store managerContractAddress]:::databaseAction
        C10 --> C11[Mark task as available]:::databaseAction
    end

    %% FLOW 4: Participant Completes a Task
    subgraph F4[FLOW 4: TASK COMPLETION]
        D1[User browses available tasks]:::userAction
        D1 --> D2[User selects task]:::userAction
        D2 --> D3[Book/screen task]:::userAction
        D3 --> D4[ScreeningService]:::service
        D4 --> D5[screenParticipantProxy Function]:::function
        D5 --> D6[Call TaskManager.screenParticipant]:::blockchainAction
        D6 --> D7[Create screenings record]:::databaseAction
        D7 --> D8[User completes task/survey]:::userAction
        D8 --> D9[TaskCompletionService]:::service
        D9 --> D10[markTaskCompletionAsComplete Function]:::function
        D10 --> D11[Create task_completions record]:::databaseAction
        D11 --> D12[RewardService]:::service
        D12 --> D13[rewardParticipantProxy Function]:::function
        D13 --> D14[Call transferRewardToPaxAccount]:::blockchainAction
        D14 --> D15[Update reward as paid out]:::databaseAction
        D15 --> D16[FCMService Notification]:::notification
    end

    %% FLOW 5: Participant Makes a Withdrawal
    subgraph F5[FLOW 5: WITHDRAWAL]
        E1[User initiates withdrawal]:::userAction --> E2[WithdrawalService]:::service
        E2 --> E3{Balance > 0?}:::decision
        E3 -->|No| E4[Show insufficient funds]:::error
        E3 -->|Yes| E5[Select amount & payment method]:::userAction
        E5 --> E6{Valid?}:::decision
        E6 -->|No| E7[Show error]:::error --> E5
        E6 -->|Yes| E8[Confirm withdrawal]:::userAction
        E8 --> E9[withdrawToPaymentMethod Function]:::function
        E9 --> E10[Call PaxAccount.withdraw]:::blockchainAction
        E10 --> E11[Transfer funds to payment method]:::blockchainAction
        E11 --> E12[Create withdrawals record]:::databaseAction
        E12 --> E13[FCMService Notification]:::notification
    end

    %% FLOW 6: Account Deletion
    subgraph F6[FLOW 6: ACCOUNT DELETION]
        F1[User requests account deletion]:::userAction --> F2[deleteParticipantOnRequest Function]:::function
        F2 --> F3[Delete participant data]:::databaseAction
        F3 --> F4[Delete PaxAccount record]:::databaseAction
        F4 --> F5[Delete task completions]:::databaseAction
        F5 --> F6[Delete rewards]:::databaseAction
        F6 --> F7[Delete withdrawals]:::databaseAction
        F7 --> F8[Delete FCM tokens]:::databaseAction
        F8 --> F9[Delete payment methods]:::databaseAction
        F9 --> F10[Delete screenings]:::databaseAction
        F10 --> F11[Delete auth record]:::databaseAction
    end

    %% Smart Contracts (placed on the side)
    subgraph SC[SMART CONTRACTS]
        direction LR
        SC1[PaxAccount.sol]:::blockchainAction
        SC2[TaskManager.sol]:::blockchainAction
    end

    %% Flow connections
    F1 --> F2
    F1 --> F4
    F1 --> F5
    F3 --> F4
    F4 --> F5
    F1 --> F6

    %% Contract connections - simplified
    A7 -.-> SC1
    B7 -.-> SC1
    C6 -.-> SC2
    D6 -.-> SC2
    D14 -.-> SC1
    E10 -.-> SC1

    %% Legend - simplified
    subgraph LEGEND[LEGEND]
        direction LR
        LEGEND_USER[User Action]:::userAction
        LEGEND_SERVICE[Service]:::service
        LEGEND_FUNCTION[Function]:::function
        LEGEND_SYSTEM[System Process]:::systemProcess
        LEGEND_BLOCKCHAIN[Blockchain Action]:::blockchainAction
        LEGEND_DATABASE[Database Action]:::databaseAction
        LEGEND_DECISION{Decision}:::decision
        LEGEND_NOTIFICATION[Notification]:::notification
        LEGEND_ERROR[Error]:::error
    end
```

## Key Features

### Mobile Application
- Micro-task management and completion tracking
- Participant screening and verification
- Dual token reward distribution (stable and non-stable)
- Payment method management
- Real-time notifications
- Activity feed and history

### Smart Contracts
- Secure participant account management
- Task creation and management
- Automated token reward distribution
- Payment method integration
- Withdrawal processing

## Technology Stack

### Mobile Application
- Flutter for cross-platform development
- Firebase for backend services
- Riverpod for state management
- Firebase Cloud Messaging for notifications

### Smart Contracts
- Solidity for contract development
- Hardhat for development environment
- OpenZeppelin for security standards
- Ethers.js for blockchain interaction

## Getting Started

### Prerequisites
- Flutter SDK
- Node.js (v16 or later)
- Firebase project
- Ethereum development environment

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-org/pax.git
cd pax
```

2. Install dependencies:
```bash
# Install Flutter dependencies
cd flutter
flutter pub get

# Install Hardhat dependencies
cd ../hardhat
npm install
```

3. Configure environment:
- Set up Firebase project and add configuration files
- Configure Ethereum network settings
- Set up environment variables

4. Run the application:
```bash
# Start the Flutter app
cd flutter
flutter run

# Deploy smart contracts
cd ../hardhat
npx hardhat run scripts/deploy.js --network <network>
```

## Development

### Mobile Application
- Follow Flutter best practices
- Use Riverpod for state management
- Implement proper error handling
- Write unit and widget tests

### Smart Contracts
- Follow Solidity best practices
- Implement comprehensive testing
- Use gas optimization techniques
- Maintain security standards

## Security

- Regular security audits
- Smart contract best practices
- Secure key management
- Access control implementation
- Emergency pause functionality

## Contributing

1. Fork the repository
2. Create your feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is proprietary and confidential. All rights reserved.

## Support

For support, please contact the development team or raise an issue in the repository.

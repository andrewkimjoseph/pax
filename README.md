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
    classDef contract fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px,color:#1b5e20
    classDef provider fill:#f3e5f5,stroke:#7b1fa2,stroke-width:1px,color:#4a148c
    classDef repository fill:#e8eaf6,stroke:#3949ab,stroke-width:1px,color:#1a237e
    
    %% Main Components
    subgraph APP[Flutter Mobile App]
        direction TB
        UI[User Interface]:::userAction
        Providers[State Providers]:::provider
        Repositories[Data Repositories]:::repository
        Services[Core Services]:::service
    end

    subgraph BC[Blockchain Layer]
        direction TB
        PA[PaxAccount Contract]:::contract
        TM[TaskManager Contract]:::contract
        Tokens[Token Contracts]:::contract
    end

    subgraph DB[Database Layer]
        direction TB
        Firestore[(Firestore DB)]:::databaseAction
        Auth[(Firebase Auth)]:::databaseAction
        FCM[(Firebase Cloud Messaging)]:::notification
    end

    %% Core Flows
    subgraph F1[Account Creation Flow]
        A1[User Signs In]:::userAction --> A2[Auth Service]:::service
        A2 --> A3[Create PaxAccount]:::blockchainAction
        A3 --> A4[Store Account Data]:::databaseAction
    end

    subgraph F2[Payment Method Flow]
        B1[Add Payment Method]:::userAction --> B2[Validate Payment Details]:::service
        B2 --> B3{Valid?}:::decision
        B3 -->|No| B4[Show Error]:::error --> B1
        B3 -->|Yes| B5[Link Payment Method]:::blockchainAction
        B5 --> B6[Store Payment Method]:::databaseAction
        B6 --> B7[Send Confirmation]:::notification
    end

    subgraph F3[Task Completion Flow]
        C1[Complete Task]:::userAction --> C2[Verify Completion]:::service
        C2 --> C3[Distribute Reward]:::blockchainAction
        C3 --> C4[Update Balances]:::databaseAction
        C4 --> C5[Send Notification]:::notification
    end

    subgraph F4[Withdrawal Flow]
        D1[Request Withdrawal]:::userAction --> D2[Verify Balance]:::service
        D2 --> D3[Process Withdrawal]:::blockchainAction
        D3 --> D4[Update Records]:::databaseAction
        D4 --> D5[Send Confirmation]:::notification
    end

    subgraph F5[Achievement Flow]
        E1[Complete Milestone]:::userAction --> E2[Check Achievement Criteria]:::service
        E2 --> E3[Update Achievement Status]:::databaseAction
        E3 --> E4[Unlock Rewards]:::blockchainAction
        E4 --> E5[Notify User]:::notification
    end

    subgraph F6[Claim Flow]
        F1[Check Available Claims]:::userAction --> F2[Verify Eligibility]:::service
        F2 --> F3[Process Claim]:::blockchainAction
        F3 --> F4[Update Claim Status]:::databaseAction
        F4 --> F5[Distribute Rewards]:::blockchainAction
        F5 --> F6[Send Confirmation]:::notification
    end

    %% Component Connections
    UI --> Providers
    Providers --> Repositories
    Repositories --> Services
    Services --> BC
    Services --> DB

    %% Flow Connections
    F1 --> F2
    F2 --> F3
    F3 --> F4
    F3 --> F5
    F5 --> F6

    %% Legend
    subgraph LEGEND[LEGEND]
        direction LR
        LEGEND_USER[User Action]:::userAction
        LEGEND_SERVICE[Service]:::service
        LEGEND_PROVIDER[Provider]:::provider
        LEGEND_REPO[Repository]:::repository
        LEGEND_CONTRACT[Smart Contract]:::contract
        LEGEND_DB[Database]:::databaseAction
        LEGEND_BC[Blockchain Action]:::blockchainAction
        LEGEND_NOTIF[Notification]:::notification
        LEGEND_DECISION{Decision}:::decision
        LEGEND_ERROR[Error]:::error
    end
```

## Key Features

### Mobile Application
- Task completion and tracking
- Participant screening and verification
- Dual token reward distribution (stable and non-stable)
- Payment method management and verification
- Real-time notifications
- Activity feed and history
- Achievement system with milestones
- Reward claiming mechanism

### Smart Contracts
- Secure participant account management
- Task completion verification
- Automated token reward distribution
- Payment method integration and verification
- Withdrawal processing
- Achievement tracking and rewards
- Claim verification and processing

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

# PAX - Task Management and Reward Platform

PAX is a Flutter-based mobile application that facilitates task management, participant screening, and reward distribution. The platform enables organizations to create tasks, screen participants, and distribute rewards through a secure and efficient system.

## Core Features

### Task Management
- Task creation and assignment
- Task completion tracking
- Real-time task status updates
- Activity feed for task-related events

### Participant Screening
- Secure participant verification process
- Blockchain-based screening validation
- Real-time screening status updates
- Integration with task completion workflow

### Reward System
- Automated reward distribution
- Multiple reward currency support
- Transaction tracking and verification
- Reward history and activity logging

### Withdrawal System
- Multiple payment method support
- Secure withdrawal processing
- Transaction history tracking
- Real-time withdrawal status updates

### Notifications
- Firebase Cloud Messaging (FCM) integration
- Real-time push notifications
- Background message handling
- Token management and refresh

## Technical Architecture

### Services Layer
The application uses a service-oriented architecture with the following core services:

- **AppInitializer**: Handles core app initialization, Firebase setup, and error handling
- **TaskCompletionService**: Manages task completion workflow and state
- **ScreeningService**: Handles participant screening process
- **RewardService**: Manages reward distribution
- **WithdrawalService**: Processes withdrawals and payment methods
- **FCMService**: Manages push notifications and device tokens

### State Management
- Uses Riverpod for state management
- Provider-based dependency injection
- Real-time state synchronization
- Efficient state updates and caching

### Backend Integration
- Firebase Functions for server-side operations
- Firestore for real-time data storage
- Firebase Authentication for user management
- Firebase Crashlytics for error tracking

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Firebase project setup
- Required API keys and configurations

### Installation
1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Add your `google-services.json` (Android)
   - Add your `GoogleService-Info.plist` (iOS)
4. Run the app:
   ```bash
   flutter run
   ```

### Development Setup
1. Set up your development environment following [Flutter's setup guide](https://docs.flutter.dev/get-started/install)
2. Configure your IDE (VS Code or Android Studio)
3. Set up Firebase CLI and FlutterFire CLI
4. Configure environment variables and API keys

## Project Structure

```
lib/
├── services/           # Core business logic services
├── providers/          # State management providers
├── repositories/       # Data access layer
├── models/            # Data models
└── utils/             # Utility functions and helpers
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is proprietary and confidential. All rights reserved.

## Support

For support, please contact the development team or raise an issue in the repository.

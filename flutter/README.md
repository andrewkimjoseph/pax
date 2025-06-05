# Pax Mobile App

This directory contains the Flutter-based mobile application for the Pax platform. The app provides a comprehensive interface for participants to complete micro-tasks, manage their cryptocurrency earnings, and interact with the blockchain-powered reward system.

## Core Features

### Task Management
- Browse and discover available micro-tasks
- WebView-based task completion interface
- Real-time task progress tracking
- Task completion verification and submission

### Participant Authentication & Screening
- Google Sign-In integration via Firebase Auth
- Automatic participant eligibility verification
- Blockchain-based screening validation
- Real-time screening status updates

### Cryptocurrency Wallet Integration
- Account abstraction with gasless transactions
- MiniPay wallet connection and management
- Multi-currency support (CUSD, Good Dollar, USDT, USDC)
- Real-time balance updates and transaction history

### Reward & Achievement System
- Automatic cryptocurrency reward distribution
- Achievement badges and progress tracking
- Gamified user experience with milestones
- Comprehensive earning history and analytics

### Withdrawal Management
- Multiple withdrawal method support (bank, mobile money, etc.)
- Secure withdrawal processing via smart contracts
- Transaction status tracking and notifications
- Withdrawal history and receipt management

### Real-Time Features
- Firebase Cloud Messaging for instant notifications
- Live task updates and availability changes
- Real-time reward distribution notifications
- Offline capability with data synchronization

## Mobile App Architecture

### Technology Stack
- **Flutter 3.x**: Cross-platform mobile development framework
- **Riverpod 3.0**: Reactive state management with code generation
- **Firebase SDK**: Authentication, Firestore, Analytics, FCM, Remote Config
- **GoRouter**: Declarative routing with authentication guards
- **ShadCN Flutter**: Modern UI component library and design system
- **Branch.io**: Deep linking and user attribution
- **Viem & Web3**: Blockchain interaction and wallet connectivity

### Services Layer
The app implements a clean, service-oriented architecture:

- **AppInitializer**: Manages app startup, Firebase initialization, and error handling
- **TaskCompletionService**: Orchestrates the complete task workflow and state management
- **ScreeningService**: Handles participant verification and eligibility checks
- **RewardService**: Manages cryptocurrency reward distribution and tracking
- **WithdrawalService**: Processes withdrawals to various payment methods
- **BlockchainService**: Interfaces with Celo network and smart contracts
- **NotificationService**: Manages FCM tokens and push notification handling
- **AnalyticsService**: Tracks user behavior and app performance metrics

### State Management (Riverpod)
- **Provider-based architecture**: Separation of concerns with dedicated providers
- **Code generation**: Type-safe provider definitions with build_runner
- **Real-time synchronization**: Live updates from Firebase Firestore
- **Efficient caching**: Optimized state updates and memory management
- **Repository pattern**: Clean data access layer with provider dependencies

### Platform Integrations
- **Firebase Functions**: Server-side business logic and blockchain orchestration
- **Cloud Firestore**: Real-time NoSQL database with offline support
- **Firebase Authentication**: Secure user management with Google Sign-In
- **Firebase Crashlytics**: Comprehensive error tracking and performance monitoring
- **Firebase Remote Config**: Feature flags and A/B testing capabilities
- **Celo Blockchain**: Direct integration for account abstraction and transactions

## Getting Started

### Prerequisites
- **Flutter SDK** (3.0 or later) - [Installation Guide](https://docs.flutter.dev/get-started/install)
- **Android Studio** or **Xcode** for platform-specific development
- **Firebase CLI** for project configuration
- **Git** for version control

### Installation

1. **Navigate to the Flutter directory:**
   ```bash
   cd flutter
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate code (for Riverpod providers):**
   ```bash
   dart run build_runner build
   ```

### Firebase Configuration

1. **Set up Firebase project:**
   - Create a project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication, Firestore, Functions, and Cloud Messaging
   - Configure Google Sign-In provider in Authentication settings

2. **Add Firebase configuration files:**
   - Download `google-services.json` for Android and place in `android/app/`
   - Download `GoogleService-Info.plist` for iOS and add to `ios/Runner/`

3. **Configure Firebase CLI:**
   ```bash
   npm install -g firebase-tools
   firebase login
   firebase use <your-project-id>
   ```

### Running the App

1. **Development mode:**
   ```bash
   flutter run
   ```

2. **Debug mode with hot reload:**
   ```bash
   flutter run --debug
   ```

3. **Release mode (for testing):**
   ```bash
   flutter run --release
   ```

### Development Workflow

1. **Code generation (run when providers change):**
   ```bash
   dart run build_runner watch
   ```

2. **Testing:**
   ```bash
   flutter test
   ```

3. **Build for distribution:**
   ```bash
   # Android
   flutter build appbundle
   
   # iOS
   flutter build ipa
   ```

## Project Structure

```
lib/
├── features/           # Feature-based UI modules
│   ├── home/          # Dashboard, tasks, achievements
│   ├── account/       # User profile and settings
│   ├── wallet/        # Wallet management and withdrawals
│   ├── activity/      # Transaction and task history
│   └── task/          # Task execution interface
├── services/          # Business logic services
│   ├── analytics/     # Analytics and tracking
│   ├── blockchain/    # Celo network integration
│   ├── notifications/ # FCM and push notifications
│   └── *.dart        # Core service implementations
├── providers/         # Riverpod state management
│   ├── auth/          # Authentication providers
│   ├── db/            # Database providers
│   ├── local/         # Local state providers
│   └── minipay/       # MiniPay wallet providers
├── repositories/      # Data access layer
│   ├── auth/          # Authentication repository
│   ├── firestore/     # Firebase Firestore repositories
│   └── local/         # Local storage repositories
├── models/            # Data models and DTOs
│   ├── auth/          # Authentication models
│   ├── firestore/     # Firestore document models
│   └── local/         # Local storage models
├── widgets/           # Reusable UI components
├── theming/           # App theme and styling
├── routing/           # Navigation and routing
└── utils/             # Utility functions and helpers
```

## Key Directories

### `/features`
Contains feature-specific UI modules organized by user functionality. Each feature includes views, view models, and feature-specific widgets.

### `/services`
Business logic layer that interfaces between the UI and data layers. Handles complex operations like blockchain transactions, notifications, and analytics.

### `/providers`
Riverpod providers for state management, organized by data source and functionality. Includes both local state and remote data providers.

### `/repositories`
Data access layer that abstracts data sources (Firebase, local storage) from the business logic layer. Implements clean architecture principles.

### `/models`
Data models representing the application's domain objects. Includes serialization logic for Firebase and local storage.

## Development Guidelines

### Code Style
- Follow Flutter and Dart style guidelines
- Use meaningful variable and function names
- Write comprehensive documentation for complex logic
- Implement proper error handling and user feedback

### State Management
- Use Riverpod providers for all shared state
- Implement repository pattern for data access
- Separate business logic from UI components
- Use code generation for type safety

### Testing
- Write widget tests for UI components
- Implement integration tests for critical user flows
- Mock external dependencies in tests
- Aim for high test coverage on business logic

### Performance
- Optimize for 60fps animations and smooth scrolling
- Implement proper image caching and lazy loading
- Use efficient list rendering for large datasets
- Monitor memory usage and prevent leaks

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow the development guidelines above
4. Write or update tests as needed
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

This project is proprietary and confidential. All rights reserved.

## Support

For technical support, please contact the development team or raise an issue in the repository.

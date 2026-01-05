# Pax - Comprehensive MVP Specification

## Executive Summary

**Pax** is a mobile-first micro-task and rewards platform that connects researchers/organizations with participants who complete surveys and tasks in exchange for cryptocurrency rewards. The platform features identity verification, multi-currency wallet management, achievement gamification, and seamless withdrawal to external crypto wallets.

---

## Core Concept

Pax enables organizations ("Task Masters") to create micro-tasks (primarily surveys) that verified participants complete to earn cryptocurrency tokens. The platform ensures only real, verified humans participate through face verification integration with GoodDollar's identity system, preventing bots and fraud.

---

## User Personas

### 1. Participant (Primary User)
- Signs up via Google authentication
- Completes profile (country, gender, date of birth)
- Verifies identity through connected wallet's face verification
- Browses and completes available tasks
- Earns cryptocurrency rewards
- Withdraws earnings to connected wallets
- Earns achievements for milestones

### 2. Task Master (Admin/Organization)
- Creates and publishes tasks
- Sets task parameters (reward amount, target participants, deadline)
- Funds task reward pools
- Reviews task completions

---

## Data Models

### Participant
```
- id: string (unique identifier)
- displayName: string (from Google auth)
- emailAddress: string (from Google auth)
- phoneNumber: string (optional)
- gender: enum ["Male", "Female"]
- country: string (country name)
- dateOfBirth: timestamp
- profilePictureURI: string (from Google auth)
- goodDollarIdentityTimeLastAuthenticated: timestamp
- goodDollarIdentityExpiryDate: timestamp
- timeCreated: timestamp
- timeUpdated: timestamp
```

### Task
```
- id: string (unique identifier)
- taskMasterId: string (reference to creator)
- title: string
- type: enum ["checkOutApp", "fillAForm", "doVideoInterview"]
- category: string (default: "General")
- estimatedTimeOfCompletionInMinutes: number
- deadline: timestamp
- targetNumberOfParticipants: number
- link: string (URL to task/survey)
- levelOfDifficulty: string
- managerContractAddress: string (blockchain contract)
- rewardAmountPerParticipant: number
- rewardCurrencyId: number (1=GoodDollar, 2=CeloDollar, 3=USDT, 4=USDC)
- isAvailable: boolean
- isTest: boolean
- feedback: string
- paymentTerms: string
- instructions: string (multi-line)
- targetCountry: string ("ALL" or comma-separated country codes)
- numberOfCooldownHours: number (wait time before re-participation)
- timeCreated: timestamp
- timeUpdated: timestamp
```

### Task Completion
```
- id: string
- taskId: string (reference)
- screeningId: string (reference)
- participantId: string (reference)
- timeCompleted: timestamp
- timeCreated: timestamp
- timeUpdated: timestamp
- isValid: boolean (indicates if submission is valid for reward)
```

### Screening
```
- id: string
- taskId: string (reference)
- participantId: string (reference)
- signature: string (cryptographic signature)
- nonce: string
- txnHash: string (blockchain transaction hash)
- timeCreated: timestamp
- timeUpdated: timestamp
```

### Reward
```
- id: string
- participantId: string (reference)
- taskId: string (reference)
- screeningId: string (reference)
- taskCompletionId: string (reference)
- signature: string
- amountReceived: number
- rewardCurrencyId: number
- txnHash: string (blockchain transaction)
- isPaidOutToPaxAccount: boolean
- timePaidOut: timestamp
- timeCreated: timestamp
- timeUpdated: timestamp
```

### Pax Account (User's Blockchain Wallet)
```
- id: string (same as participantId)
- contractAddress: string (smart contract address)
- contractCreationTxnHash: string
- serverWalletId: string
- serverWalletAddress: string
- smartAccountWalletAddress: string
- timeCreated: timestamp
- timeUpdated: timestamp
```

### Withdrawal Method (Payment Method)
```
- id: string
- predefinedId: number (1=MiniPay, 2=GoodWallet)
- participantId: string (reference)
- paxAccountId: string (reference)
- name: string ("MiniPay" or "GoodWallet")
- walletAddress: string (blockchain address)
- txnHash: string
- timeCreated: timestamp
- timeUpdated: timestamp
```

### Withdrawal
```
- id: string
- participantId: string (reference)
- paymentMethodId: string (reference)
- amountTakenOut: number
- rewardCurrencyId: number
- txnHash: string
- timeRequested: timestamp
- timeCreated: timestamp
- timeUpdated: timestamp
```

### Achievement
```
- id: string
- participantId: string (reference)
- name: string (achievement type)
- tasksCompleted: number
- tasksNeededForCompletion: number
- timeCreated: timestamp
- timeCompleted: timestamp
- timeClaimed: timestamp
- amountEarned: number
- txnHash: string (reward transaction)
```

### FCM Token (Push Notifications)
```
- id: string
- participantId: string (reference)
- token: string (Firebase Cloud Messaging token)
- timeCreated: timestamp
- timeUpdated: timestamp
```

---

## Achievement System

### Achievement Types & Rewards

| Achievement Name | Goal | Reward (G$) |
|-----------------|------|-------------|
| Payout Connector | Connect first withdrawal method | 500 |
| Verified Human | Complete face verification | 500 |
| Profile Perfectionist | Fill country, gender, DOB | 400 |
| Task Starter | Complete 1 task | 100 |
| Task Expert | Complete 10 tasks | 1000 |
| Double Payout Connector | Connect 2 withdrawal methods | 500 |

### Achievement States
- **In Progress**: User is working toward the goal
- **Earned**: Goal completed, reward available to claimYEs
- **Claimed**: Reward has been claimed and transferred

---

## Currency System

### Supported Currencies
1. **Good Dollar (G$)** - ID: 1 - Primary reward currency
2. **Celo Dollar (cUSD)** - ID: 2
3. **Tether USD (USDT)** - ID: 3
4. **USD Coin (USDC)** - ID: 4

### Currency Features
- Users can view balance in any supported currency
- Currency selection persists across sessions
- All currencies are ERC-20 compatible tokens on Celo blockchain

---

## Application Routes & Navigation

### Route Structure

```
/onboarding                              - Welcome screens (3 pages) + Sign in
/home                                    - Main hub with tabs
  ├── Dashboard (index 0)                - Balance card, carousel, published reports
  ├── Tasks (index 1)                    - Available tasks list
  └── Achievements (index 2)             - Achievement cards with filters

/wallet                                  - Balance view + withdrawal methods
/wallet/withdraw                         - Enter withdrawal amount
/wallet/withdraw/select-wallet           - Select withdrawal destination
/wallet/withdraw/select-wallet/review    - Confirm withdrawal

/tasks/task-summary                      - Task details before starting
/tasks/check-out-app                     - WebView for app check tasks
/tasks/fill-a-form                       - WebView for survey tasks

/claim-reward                            - Claim earned task reward

/withdrawal-methods                      - Manage connected wallets
/withdrawal-methods/minipay-connection   - Connect MiniPay wallet
/withdrawal-methods/minipay-connection/copy-wallet-address
/withdrawal-methods/good-wallet-connection    - Connect GoodWallet
/withdrawal-methods/good-wallet-connection/copy-wallet-address

/profile                                 - Edit profile details
/account-and-security                    - Account settings, delete account
/activity                                - Transaction history
/help-and-support                        - Help options
/help-and-support/faq                    - Frequently asked questions
/help-and-support/contact-support        - Contact form

/canvassing-x-gooddollar                 - Partnership info page
/report-page                             - View published research reports
/notifications                           - Notification center
```

---

## Feature Specifications

### 1. Onboarding Flow

**Screens:**
1. **Welcome Screen 1**: "Earn as you share your opinions" - Introduction
2. **Welcome Screen 2**: "We value your voice. We pay for your opinion." - Value proposition
3. **Welcome Screen 3**: "Sign in with Google" - Authentication

**Functionality:**
- Swipeable page carousel with dot indicators
- Skip button (jumps to last page)
- Continue button (advances one page)
- Google Sign-In integration
- Automatic user creation in database on first sign-in
- Progress indicators (3 dots)

---

### 2. Dashboard

**Components:**
- Current Balance Card (shows selected currency balance)
- Social Links Carousel (X, Telegram, WhatsApp links)
- Image Carousel (5 rotating promotional images)
- Published Reports Section (links to research reports)

**Balance Card Features:**
- Currency selector dropdown (4 currencies)
- Balance refresh button (5-minute cooldown)
- Wallet/Withdraw button
- Loading skeleton during fetch

---

### 3. Tasks System

**Task List View:**
- Real-time list of available tasks
- Tasks filtered by participant's country
- Shows task count badge in tab
- Empty state with Lottie animation when no tasks
- Task cards showing: title, reward amount, difficulty, time estimate

**Task Card Information:**
- Task title
- Reward amount with currency icon
- Estimated completion time
- Difficulty level
- Action type (Check Out App / Fill A Form)
- Category badge
- Deadline indicator

**Task Summary View:**
- Full task image
- Detailed task information card
- Instructions preview (first 2 lines, expandable)
- "Continue with task" button

**Task Execution Flow:**
1. User clicks task from list → Task Summary
2. System checks: withdrawal method connected + profile complete
3. If incomplete → Dialog prompting to add withdrawal method
4. System checks task manager contract has sufficient balance
5. Screening process begins (blockchain verification)
6. On success → Navigate to task WebView
7. Task loads in embedded WebView
8. User completes task (survey/app checkout)
9. Task completion recorded
10. User redirected to claim reward

**Task Types:**
- **Check Out App**: Visit and interact with a web/mobile app
- **Fill A Form**: Complete a survey form

**Cooldown System:**
- Tasks can have cooldown periods (hours)
- Users must wait before re-participating
- Countdown timer shows remaining wait time
- Button disabled during cooldown

**Screening Process:**
- Verifies participant eligibility
- Creates blockchain transaction
- Generates cryptographic signature
- Records screening in database

---

### 4. Reward Claiming

**Claim Reward View:**
- Task completion confirmation graphic
- Amount earned display
- Task completion ID (copyable)
- Cooldown status indicator (if applicable)
- Invalid submission notice (if marked invalid)

**Claim States:**
- **Not Completed**: "Complete Task" button → Returns to tasks
- **Cooldown Active**: Shows countdown timer, button disabled
- **Ready to Claim**: "Claim Reward" button active
- **Claimed**: Button shows "Claimed", disabled
- **Invalid**: Shows error message, cannot claim

**Claim Process:**
1. User taps "Claim Reward"
2. Loading dialog appears
3. Backend processes reward
4. Blockchain transaction executed
5. Success dialog with confirmation
6. User redirected to home

---

### 5. Achievements

**Achievement View:**
- Partnership banner (Canvassing x GoodDollar)
- Filter tabs: All, In Progress, Earned, Claimed
- Achievement cards list

**Achievement Card:**
- Achievement icon (SVG)
- Achievement name
- Goal description
- Progress indicator (X/Y tasks)
- Reward amount
- Status badge
- Claim button (when earned)

**Achievement Claim Process:**
1. User taps "Claim" on earned achievement
2. Loading dialog
3. Backend verifies eligibility
4. Blockchain reward transaction
5. Success confirmation
6. Achievement status updated to "Claimed"

---

### 6. Wallet & Withdrawals

**Wallet View:**
- Current balance card with currency selector
- Refresh balance button
- Available Withdrawal Methods section
- MiniPay card (connected/not connected)
- GoodWallet card (connected/not connected)

**Withdrawal Flow:**
1. Select currency to withdraw
2. Enter amount (validates: >0, ≤ balance, max 2 decimals)
3. Select destination wallet (MiniPay or GoodWallet)
4. Review summary (amount, fees, destination)
5. Confirm withdrawal
6. Processing dialog
7. Blockchain transaction
8. Success confirmation

**Withdrawal Amount Validation:**
- Must be greater than 0
- Cannot exceed available balance
- Maximum 2 decimal places
- Real-time validation feedback

---

### 7. Withdrawal Methods Connection

**Supported Methods:**
1. **MiniPay** - Celo mobile wallet
2. **GoodWallet** - GoodDollar ecosystem wallet

**Connection Flow (Both Methods):**
1. User navigates to withdrawal methods
2. Taps on desired method card
3. Guide screens explain the process
4. User copies their Pax account address
5. User goes to external wallet app
6. User sends small amount to Pax address
7. System detects transaction
8. Wallet linked automatically
9. Confirmation shown

**Connection Verification:**
- System monitors blockchain for incoming transactions
- Extracts sender's wallet address
- Links wallet to user's Pax account
- Creates withdrawal method record

**Guide Steps (MiniPay):**
1. Download MiniPay if not installed
2. Open MiniPay
3. Copy your Pax receiving address
4. In MiniPay, tap Send
5. Paste Pax address
6. Send minimum amount
7. Wait for confirmation

---

### 8. Profile Management

**Profile View:**
- Profile picture (from Google, not editable)
- Display name (from Google, read-only)
- Email (from Google, read-only)
- Country (editable once, then locked)
- Gender (editable once, then locked)
- Date of Birth (editable once, then locked)

**Validation Rules:**
- Country: Required, select from list
- Gender: Required, Male/Female
- Date of Birth: Required, must be 18+ years old

**Profile Completion:**
- Users cannot start tasks without completing profile
- Profile fields lock after first save
- Triggers "Profile Perfectionist" achievement

---

### 9. Account & Security

**Options:**
- Delete Account (with confirmation flow)

**Account Deletion:**
- Requires confirmation
- Deletes all user data
- Signs out user
- Blockchain assets remain in user's connected wallets

---

### 10. Help & Support

**Help Options:**
- FAQ section
- Contact Support form

**FAQ Content:**
- Task frequency (weekly, typically Tuesdays)
- Task availability times (8:00 AM UTC)
- Face verification explanation
- Task capacity/rush situations
- Currency conversion guides
- Account ban information
- Achievement claiming hours

---

### 11. Notifications

**Push Notifications For:**
- New task available
- Reward claimed successfully
- Withdrawal completed
- Achievement unlocked
- Achievement ready to claim
- System announcements

**FCM Token Management:**
- Token registered on app launch
- Updated when token refreshes
- Associated with participant ID

---

### 12. Navigation Drawer

**Drawer Options:**
- Profile
- Wallet
- Activity (transaction history)
- Achievements
- Help & Support
- Account & Security
- Logout

---

## Backend Functions

### Cloud Functions

1. **createPrivyServerWallet**
   - Creates secure server-managed wallet for new users

2. **createPaxAccountV1Proxy**
   - Deploys smart contract account for user
   - Links withdrawal method

3. **addNonPrimaryWithdrawalMethodToPaxAccountV1Proxy**
   - Adds secondary withdrawal method to existing account

4. **screenParticipantProxy**
   - Verifies participant eligibility for task
   - Creates screening record
   - Generates cryptographic signature

5. **markTaskCompletionAsComplete**
   - Marks task as completed after survey submission

6. **rewardParticipantProxy**
   - Processes reward claim
   - Executes blockchain reward transfer
   - Records reward transaction

7. **withdrawToPaymentMethod**
   - Processes withdrawal request
   - Transfers tokens to external wallet
   - Records withdrawal

8. **processAchievementClaim**
   - Verifies achievement completion
   - Processes reward payout
   - Updates achievement status

9. **deleteParticipantOnRequest**
   - Handles GDPR deletion requests
   - Removes user data

10. **sendNotification**
    - Sends push notifications via FCM

11. **notifyPaxTotifierAboutNewUser**
    - Alerts admin bot about new registrations

---

## Feature Flags (Remote Config)

| Flag Key | Purpose |
|----------|---------|
| areTasksAvailable | Enable/disable tasks tab |
| areAchievementsAvailable | Enable/disable achievements tab |
| isWalletAvailable | Enable/disable wallet access |
| isWithdrawalMethodConnectionAvailable | Enable/disable wallet connection |

---

## Analytics Events

### Authentication
- signInWithGoogleTapped
- signOutTapped

### Navigation
- dashboardTapped
- tasksTapped
- achievementsTapped
- homeWalletTapped
- walletWithdrawTapped
- optionsTapped

### Task Flow
- taskCardTapped
- continueWithTaskTapped
- screeningStarted
- screeningFailed
- taskCompleted
- claimRewardTapped
- claimRewardComplete
- claimRewardFailed
- goHomeToCompleteTaskTapped

### Wallet
- refreshBalancesTapped
- continueWithdrawTapped
- withdrawalMethodConnectionTapped
- setUpWithdrawalMethodTapped

### Profile
- saveProfileChangesTapped

### Onboarding
- onboardingSkipTapped

---

## UI/UX Specifications

### Color Palette
- **Deep Purple**: Primary brand color (#5E4DB2)
- **Lilac**: Secondary accent
- **White**: Background
- **Light Grey**: Borders, dividers
- **Green**: Success states
- **Red**: Error states, badges
- **Orange to Pink Gradient**: Premium accents

### Design Patterns
- Card-based layouts
- Bottom navigation (via drawer)
- Tab navigation in home
- Pull-to-refresh on lists
- Skeleton loading states
- Toast notifications
- Modal dialogs for confirmations
- Bottom sheets for complex selections

### Typography
- Bold headers (28-32px)
- Section titles (20px)
- Body text (14-16px)
- Captions (12px)

---

## Security Considerations

### Authentication
- Google OAuth 2.0 only
- Session management via Firebase Auth
- Auto-logout on token expiration

### Data Protection
- Profile fields non-editable after first save
- Age verification (18+ requirement)
- Identity verification via GoodDollar

### Blockchain Security
- Server-managed wallets (no private keys on client)
- Cryptographic signatures for all transactions
- Transaction verification before reward distribution

### Privacy
- Account deletion capability
- Minimal data collection
- Clear privacy policy

---

## Task Availability Rules

1. Tasks have limited participant slots
2. First-come, first-served basis
3. Tasks expire after deadline
4. Country-targeted tasks only show to eligible users
5. Tasks with cooldowns prevent repeat participation
6. Invalid submissions cannot claim rewards

---

## Error Handling

### User-Facing Errors
- Network connectivity issues
- Insufficient balance for withdrawal
- Task manager insufficient funds
- Screening failures
- Claim failures
- Invalid submissions

### Error Messages
- Clear, actionable language
- Contact support suggestions
- Retry options where applicable

---

## Platform Requirements

### Mobile Support
- iOS
- Android
- Web (responsive)

### Minimum Requirements
- Internet connection
- Google account
- Age 18+
- Supported country

---

## Integration Points

### External Services
- Google Sign-In (Authentication)
- GoodDollar (Identity verification, G$ token)
- MiniPay (Celo wallet)
- GoodWallet (GoodDollar wallet)
- Firebase (Database, Auth, Functions, Messaging, Analytics, Remote Config)
- Celo Blockchain (Smart contracts, token transfers)

### Social Links
- X (Twitter): Follow for updates
- Telegram: Community group
- WhatsApp: Community group

---

## Appendix: FAQ Content

1. **Task Frequency**: Once weekly (4 tasks/month), dependent on researchers
2. **Task Time**: 8:00 AM UTC / 9:00 AM WAT / 10:00 AM CAT / 11:00 AM EAT
3. **Task Day**: Tuesdays (PaxDay)
4. **Face Verification**: Required for fraud prevention via GoodDollar Identity
5. **Task Availability**: First-come-first-served, high volume causes quick closure
6. **G$ to cUSD Conversion**: Guide available via Medium article
7. **Task Types**: Currently surveys only, more coming
8. **Questions per Task**: 10-15 questions
9. **Slot Booking**: Grants immediate access to task
10. **Account Ban**: Disabled accounts cannot do tasks or withdraw
11. **Achievement Claiming Hours**: Daily 8AM-3PM UTC window

---

## Success Metrics

- User registration rate
- Task completion rate
- Average time to complete task
- Reward claim rate
- Achievement completion rate
- Withdrawal frequency
- User retention (weekly active users)
- Average earnings per user

---

*This MVP specification provides a complete blueprint for recreating the Pax platform. All systems, models, user flows, and functionalities are documented to enable accurate reproduction of the application's core features.*



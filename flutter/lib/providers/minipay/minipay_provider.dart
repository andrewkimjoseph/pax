// providers/minipay_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/db/achievement/achievement_provider.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';
import 'package:pax/providers/db/payment_method/payment_method_provider.dart';
import 'package:pax/services/minipay/minipay_service.dart';
import 'package:pax/providers/fcm/fcm_provider.dart';
import 'package:pax/utils/achievement_constants.dart';
import 'package:pax/utils/user_property_constants.dart';

final miniPayServiceProvider = Provider<MiniPayService>((ref) {
  return MiniPayService(
    paxAccountRepository: ref.watch(paxAccountRepositoryProvider),
    withdrawalMethodRepository: ref.watch(withdrawalMethodRepositoryProvider),
  );
});

// Define an enum for the connection state
enum MiniPayConnectionState {
  initial,
  validating,
  checkingWhitelist,
  creatingServerWallet,
  deployingContract,
  creatingPaymentMethod,
  updatingParticipant,
  success,
  error,
}

// Define a state class for MiniPay connection
class MiniPayConnectionStateModel {
  final MiniPayConnectionState state;
  final String? errorMessage;
  final bool isConnecting;
  final Map<String, dynamic>? serverWalletData;
  final Map<String, dynamic>? contractData;
  final bool serverWalletCreated;
  final bool contractDeployed;

  MiniPayConnectionStateModel({
    this.state = MiniPayConnectionState.initial,
    this.errorMessage,
    this.isConnecting = false,
    this.serverWalletData,
    this.contractData,
    this.serverWalletCreated = false,
    this.contractDeployed = false,
  });

  // Copy with method
  MiniPayConnectionStateModel copyWith({
    MiniPayConnectionState? state,
    String? errorMessage,
    bool? isConnecting,
    Map<String, dynamic>? serverWalletData,
    Map<String, dynamic>? contractData,
    bool? serverWalletCreated,
    bool? contractDeployed,
  }) {
    return MiniPayConnectionStateModel(
      state: state ?? this.state,
      errorMessage: errorMessage,
      isConnecting: isConnecting ?? this.isConnecting,
      serverWalletData: serverWalletData ?? this.serverWalletData,
      contractData: contractData ?? this.contractData,
      serverWalletCreated: serverWalletCreated ?? this.serverWalletCreated,
      contractDeployed: contractDeployed ?? this.contractDeployed,
    );
  }
}

// Create a notifier for MiniPay connection
class MiniPayConnectionNotifier extends Notifier<MiniPayConnectionStateModel> {
  late final MiniPayService _miniPayService;

  @override
  MiniPayConnectionStateModel build() {
    _miniPayService = ref.watch(miniPayServiceProvider);
    return MiniPayConnectionStateModel();
  }

  // Validate and connect wallet
  Future<void> connectMiniPay(
    String userId,
    String primaryPaymentMethod,
  ) async {
    if (state.isConnecting) return; // Prevent multiple connection attempts

    // Reset state
    state = MiniPayConnectionStateModel(
      state: MiniPayConnectionState.validating,
      isConnecting: true,
    );

    try {
      // Step 1: Validate wallet address
      await _validateWalletAddress(primaryPaymentMethod);

      // Step 2: Check whitelist
      await _checkWhitelist(primaryPaymentMethod);

      // Step 3: Handle server wallet
      final serverWalletData = await _handleServerWallet(userId);

      // Step 4: Handle contract deployment
      final contractData = await _handleContractDeployment(
        userId,
        primaryPaymentMethod,
        serverWalletData,
      );

      // Step 5: Complete setup
      await _completeSetup(userId, primaryPaymentMethod, contractData);

      // Success
      state = state.copyWith(
        state: MiniPayConnectionState.success,
        isConnecting: false,
      );
    } catch (e) {
      _handleError(e, primaryPaymentMethod);
    }
  }

  // Helper method to validate wallet address
  Future<void> _validateWalletAddress(String primaryPaymentMethod) async {
    bool isValidEthereumAddress = _miniPayService.isValidEthereumAddress(
      primaryPaymentMethod,
    );

    if (!isValidEthereumAddress) {
      throw Exception(
        'Invalid Ethereum wallet address format. Please enter a valid address.',
      );
    }

    bool isWalletAddressUsed = await _miniPayService.isWalletAddressUsed(
      primaryPaymentMethod,
    );

    if (kDebugMode) {
      print('isWalletAddressUsed: $isWalletAddressUsed');
    }

    if (isWalletAddressUsed) {
      throw Exception(
        'This wallet address is already in use. Please use a different address.',
      );
    }
  }

  // Helper method to check whitelist
  Future<void> _checkWhitelist(String primaryPaymentMethod) async {
    state = state.copyWith(state: MiniPayConnectionState.checkingWhitelist);

    final isVerified = await _miniPayService.isGoodDollarVerified(
      primaryPaymentMethod,
    );

    if (!isVerified) {
      throw Exception(
        'This wallet is not GoodDollar verified. Please complete verification first.',
      );
    }
  }

  // Helper method to handle server wallet creation/retrieval
  Future<Map<String, dynamic>> _handleServerWallet(String userId) async {
    final startingPaxAccount = ref.read(paxAccountProvider).account;
    if (startingPaxAccount == null) {
      throw Exception('PaxAccount document not found');
    }

    // Check if server wallet exists already
    bool serverWalletExists =
        startingPaxAccount.serverWalletId != null &&
        startingPaxAccount.serverWalletId?.isNotEmpty == true &&
        startingPaxAccount.serverWalletAddress != null &&
        startingPaxAccount.serverWalletAddress?.isNotEmpty == true &&
        startingPaxAccount.smartAccountWalletAddress != null &&
        startingPaxAccount.smartAccountWalletAddress?.isNotEmpty == true;

    if (serverWalletExists) {
      // Use existing server wallet
      if (kDebugMode) {
        print(
          'Using existing PaxAccount details: ${startingPaxAccount.toMap()}',
        );
      }

      final serverWalletData = {
        'serverWalletId': startingPaxAccount.serverWalletId,
        'serverWalletAddress': startingPaxAccount.serverWalletAddress,
        'smartAccountWalletAddress':
            startingPaxAccount.smartAccountWalletAddress,
      };

      state = state.copyWith(
        serverWalletData: serverWalletData,
        serverWalletCreated: true,
      );

      return serverWalletData;
    } else {
      // Create a new server wallet
      return await _createNewServerWallet(userId);
    }
  }

  // Helper method to create new server wallet
  Future<Map<String, dynamic>> _createNewServerWallet(String userId) async {
    state = state.copyWith(state: MiniPayConnectionState.creatingServerWallet);

    try {
      final serverWalletData = await _miniPayService.createServerWallet();

      // Update PaxAccount with server wallet data immediately
      await _miniPayService.updatePaxAccount(userId, {
        'serverWalletId': serverWalletData['serverWalletId'],
        'serverWalletAddress': serverWalletData['serverWalletAddress'],
        'smartAccountWalletAddress':
            serverWalletData['smartAccountWalletAddress'],
      });

      state = state.copyWith(
        serverWalletData: serverWalletData,
        serverWalletCreated: true,
      );

      return serverWalletData;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating server wallet: $e');
      }
      throw Exception('Failed to create server wallet: ${e.toString()}');
    }
  }

  // Helper method to handle contract deployment
  Future<Map<String, dynamic>> _handleContractDeployment(
    String userId,
    String primaryPaymentMethod,
    Map<String, dynamic> serverWalletData,
  ) async {
    // Refresh the PaxAccount provider and wait for it to complete
    await ref.read(paxAccountProvider.notifier).refreshAccount();
    final latestPaxAccount = ref.read(paxAccountProvider).account;

    if (kDebugMode) {
      print('LatestPaxAccount: ${latestPaxAccount?.toMap()}');
    }

    // Check if contract exists already
    bool contractExists =
        latestPaxAccount?.contractAddress != null &&
        latestPaxAccount?.contractAddress?.isNotEmpty == true &&
        latestPaxAccount?.contractCreationTxnHash != null &&
        latestPaxAccount?.contractCreationTxnHash?.isNotEmpty == true;

    if (contractExists) {
      // Use existing contract
      if (kDebugMode) {
        print('Using existing contract: ${latestPaxAccount?.contractAddress}');
      }

      final contractData = {
        'contractAddress': latestPaxAccount?.contractAddress,
        'contractCreationTxnHash': latestPaxAccount?.contractCreationTxnHash,
      };

      state = state.copyWith(
        contractData: contractData,
        contractDeployed: true,
      );

      return contractData;
    } else {
      // Deploy a new contract
      return await _deployNewContract(
        userId,
        primaryPaymentMethod,
        serverWalletData,
      );
    }
  }

  // Helper method to deploy new contract
  Future<Map<String, dynamic>> _deployNewContract(
    String userId,
    String primaryPaymentMethod,
    Map<String, dynamic> serverWalletData,
  ) async {
    state = state.copyWith(state: MiniPayConnectionState.deployingContract);

    try {
      final contractData = await _miniPayService
          .deployPaxAccountV1ProxyContractAddress(
            primaryPaymentMethod,
            serverWalletData['serverWalletId'],
          );

      // Update PaxAccount with contract data immediately
      await _miniPayService.updatePaxAccount(userId, {
        'contractAddress': contractData['contractAddress'],
        'contractCreationTxnHash':
            contractData['contractCreationTxnHash'] ?? contractData['txnHash'],
      });

      state = state.copyWith(
        contractData: contractData,
        contractDeployed: true,
      );

      return contractData;
    } catch (e) {
      if (kDebugMode) {
        print('Error deploying contract: $e');
      }
      throw Exception('Failed to deploy contract: ${e.toString()}');
    }
  }

  // Helper method to complete the setup
  Future<void> _completeSetup(
    String userId,
    String primaryPaymentMethod,
    Map<String, dynamic> contractData,
  ) async {
    state = state.copyWith(state: MiniPayConnectionState.creatingPaymentMethod);

    // Refresh the PaxAccount provider and wait for it to complete
    await ref.read(paxAccountProvider.notifier).refreshAccount();
    final finalPaxAccount = ref.read(paxAccountProvider).account;
    final startingPaxAccount = ref.read(paxAccountProvider).account;

    if (kDebugMode) {
      print('FinalPaxAccount: ${finalPaxAccount?.toMap()}');
    }

    try {
      await _miniPayService.createWithdrawalMethod(
        userId: userId,
        paxAccountId: finalPaxAccount?.id ?? startingPaxAccount!.id,
        walletAddress: primaryPaymentMethod,
      );

      // Update state to show we're updating participant related data
      state = state.copyWith(state: MiniPayConnectionState.updatingParticipant);

      await _updateParticipantData(userId, primaryPaymentMethod);
      await _createAchievements(userId);
      await _sendAnalyticsAndNotifications(
        userId,
        primaryPaymentMethod,
        finalPaxAccount,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating payment method or updating participant: $e');
      }
      throw Exception('Failed to complete wallet connection: ${e.toString()}');
    }
  }

  // Helper method to update participant data
  Future<void> _updateParticipantData(
    String userId,
    String primaryPaymentMethod,
  ) async {
    // Get the last authentication time and expiry date from GoodDollar
    int goodDollarIdentityTimeLastAuthenticated = await _miniPayService
        .getLastAuthenticated(primaryPaymentMethod);

    // Get GoodDollar identity expiry date
    Timestamp? goodDollarIdentityExpiryDate = await _miniPayService
        .getGoodDollarIdentityExpiryDate(primaryPaymentMethod);

    // Update participant profile with authentication timestamp and expiry date
    Map<String, dynamic> participantUpdateData = {
      "goodDollarIdentityTimeLastAuthenticated":
          Timestamp.fromMillisecondsSinceEpoch(
            goodDollarIdentityTimeLastAuthenticated * 1000,
          ),
    };

    // Only add expiry date if it exists
    if (goodDollarIdentityExpiryDate != null) {
      participantUpdateData["goodDollarIdentityExpiryDate"] =
          goodDollarIdentityExpiryDate;
    }

    // Update the participant profile
    await ref
        .read(participantProvider.notifier)
        .updateProfile(participantUpdateData);
  }

  // Helper method to create achievements
  Future<void> _createAchievements(String userId) async {
    final fcmToken = await ref.read(fcmTokenProvider.future);

    // Create payout connector achievement
    await ref
        .read(achievementsProvider.notifier)
        .createAchievement(
          timeCreated: Timestamp.now(),
          participantId: userId,
          name: AchievementConstants.payoutConnector,
          tasksNeededForCompletion:
              AchievementConstants.payoutConnectorTasksNeeded,
          tasksCompleted: 1,
          timeCompleted: Timestamp.now(),
          amountEarned: AchievementConstants.payoutConnectorAmount,
        );

    ref.read(analyticsProvider).achievementCreated({
      'achievementName': AchievementConstants.payoutConnector,
      'amountEarned': AchievementConstants.payoutConnectorAmount,
    });

    if (fcmToken != null) {
      await ref
          .read(notificationServiceProvider)
          .sendAchievementEarnedNotification(
            token: fcmToken,
            achievementData: {
              'achievementName': AchievementConstants.payoutConnector,
              'amountEarned': AchievementConstants.payoutConnectorAmount,
            },
          );
    }

    // Create verified human achievement
    await ref
        .read(achievementsProvider.notifier)
        .createAchievement(
          timeCreated: Timestamp.now(),
          participantId: userId,
          name: AchievementConstants.verifiedHuman,
          tasksNeededForCompletion:
              AchievementConstants.verifiedHumanTasksNeeded,
          tasksCompleted: 1,
          timeCompleted: Timestamp.now(),
          amountEarned: AchievementConstants.verifiedHumanAmount,
        );

    ref.read(analyticsProvider).achievementCreated({
      'achievementName': AchievementConstants.verifiedHuman,
      'amountEarned': AchievementConstants.verifiedHumanAmount,
    });

    if (fcmToken != null) {
      ref
          .read(notificationServiceProvider)
          .sendAchievementEarnedNotification(
            token: fcmToken,
            achievementData: {
              'achievementName': AchievementConstants.verifiedHuman,
              'amountEarned': AchievementConstants.verifiedHumanAmount,
            },
          );
    }

    await ref.read(achievementsProvider.notifier).fetchAchievements(userId);
  }

  // Helper method to send analytics and notifications
  Future<void> _sendAnalyticsAndNotifications(
    String userId,
    String primaryPaymentMethod,
    dynamic finalPaxAccount,
  ) async {
    // Refresh providers properly
    await ref.read(participantProvider.notifier).refreshParticipant();
    await ref.read(withdrawalMethodsProvider.notifier).refresh(userId);

    final participant = ref.read(participantProvider);
    final withdrawalMethod = ref.read(withdrawalMethodsProvider);

    if (kDebugMode) {
      print('participant: ${participant.participant?.toMap()}');
      print(
        'withdrawalMethod count: ${withdrawalMethod.withdrawalMethods.length}',
      );
      if (withdrawalMethod.withdrawalMethods.isNotEmpty) {
        print(
          'withdrawalMethod: ${withdrawalMethod.withdrawalMethods.first.toMap()}',
        );
      }
    }

    // Check if participant exists
    if (participant.participant == null) {
      if (kDebugMode) {
        print('Warning: Participant is null, skipping analytics');
      }
      return;
    }

    // Check if withdrawal methods exist before accessing first element
    if (withdrawalMethod.withdrawalMethods.isNotEmpty) {
      ref
          .read(analyticsProvider)
          .minipayConnectionComplete(
            withdrawalMethod.withdrawalMethods.first.toMap(),
          );
    } else {
      if (kDebugMode) {
        print('Warning: No withdrawal methods found for analytics');
      }
      // Send analytics without withdrawal method data
      ref.read(analyticsProvider).minipayConnectionComplete({});
    }

    ref.read(analyticsProvider).identifyUser({
      UserPropertyConstants.participantId: participant.participant?.id,
      UserPropertyConstants.displayName: participant.participant?.displayName,
      UserPropertyConstants.emailAddress: participant.participant?.emailAddress,
      UserPropertyConstants.profilePictureURI:
          participant.participant?.profilePictureURI,
      UserPropertyConstants.goodDollarIdentityTimeLastAuthenticated:
          participant.participant?.goodDollarIdentityTimeLastAuthenticated,
      UserPropertyConstants.goodDollarIdentityExpiryDate:
          participant.participant?.goodDollarIdentityExpiryDate,
      UserPropertyConstants.timeCreated: participant.participant?.timeCreated,
      UserPropertyConstants.timeUpdated: participant.participant?.timeUpdated,
      UserPropertyConstants.miniPayWalletAddress: primaryPaymentMethod,
      UserPropertyConstants.privyServerWalletId:
          finalPaxAccount?.serverWalletId,
      UserPropertyConstants.privyServerWalletAddress:
          finalPaxAccount?.serverWalletAddress,
      UserPropertyConstants.smartAccountWalletAddress:
          finalPaxAccount?.smartAccountWalletAddress,
      UserPropertyConstants.paxAccountId: finalPaxAccount?.id,
      UserPropertyConstants.paxAccountContractAddress:
          finalPaxAccount?.contractAddress,
      UserPropertyConstants.paxAccountContractCreationTxnHash:
          finalPaxAccount?.contractCreationTxnHash,
    });
  }

  // Helper method to handle errors
  void _handleError(dynamic error, String primaryPaymentMethod) {
    if (kDebugMode) {
      print('Error: $error');
    }

    ref.read(analyticsProvider).minipayConnectionFailed({
      "primaryPaymentMethod": primaryPaymentMethod,
      "error": error.toString().substring(
        0,
        error.toString().length.clamp(0, 99),
      ),
    });

    state = state.copyWith(
      state: MiniPayConnectionState.error,
      errorMessage: error.toString(),
      isConnecting: false,
    );
  }

  // Reset state
  void resetState() {
    state = MiniPayConnectionStateModel();
  }
}

// Create the provider for the MiniPay connection notifier
final miniPayConnectionProvider =
    NotifierProvider<MiniPayConnectionNotifier, MiniPayConnectionStateModel>(
      () {
        return MiniPayConnectionNotifier();
      },
    );

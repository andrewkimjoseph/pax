import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/db/achievement/achievement_provider.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';
import 'package:pax/providers/db/withdrawal_method/withdrawal_method_provider.dart';
import 'package:pax/services/withdrawal/withdrawal_method_connection_service.dart';
import 'package:pax/providers/fcm/fcm_provider.dart';
import 'package:pax/utils/achievement_constants.dart';
import 'package:pax/utils/user_property_constants.dart';

final withdrawalMethodConnectionProvider =
    Provider<WithdrawalMethodConnectionService>((ref) {
      return WithdrawalMethodConnectionService(
        paxAccountRepository: ref.watch(paxAccountRepositoryProvider),
        withdrawalMethodRepository: ref.watch(
          withdrawalMethodRepositoryProvider,
        ),
      );
    });

// Define an enum for the connection state
enum WithdrawalMethodConnectionState {
  initial,
  validating,
  checkingWhitelist,
  creatingServerWallet,
  deployingOrInteractingWithContract,
  creatingWithdrawalMethod,
  updatingParticipant,
  success,
  error,
}

// Define a state class for MiniPay connection
class WithdrawalMethodConnectionStateModel {
  final WithdrawalMethodConnectionState state;
  final String? errorMessage;
  final bool isConnecting;
  final Map<String, dynamic>? serverWalletData;
  final Map<String, dynamic>? contractData;
  final bool serverWalletCreated;
  final bool contractDeployed;

  WithdrawalMethodConnectionStateModel({
    this.state = WithdrawalMethodConnectionState.initial,
    this.errorMessage,
    this.isConnecting = false,
    this.serverWalletData,
    this.contractData,
    this.serverWalletCreated = false,
    this.contractDeployed = false,
  });

  // Copy with method
  WithdrawalMethodConnectionStateModel copyWith({
    WithdrawalMethodConnectionState? state,
    String? errorMessage,
    bool? isConnecting,
    Map<String, dynamic>? serverWalletData,
    Map<String, dynamic>? contractData,
    bool? serverWalletCreated,
    bool? contractDeployed,
  }) {
    return WithdrawalMethodConnectionStateModel(
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
class WithdrawalMethodConnectionNotifier
    extends Notifier<WithdrawalMethodConnectionStateModel> {
  late final WithdrawalMethodConnectionService _withdrawalMethodService;

  @override
  WithdrawalMethodConnectionStateModel build() {
    _withdrawalMethodService = ref.watch(withdrawalMethodConnectionProvider);
    return WithdrawalMethodConnectionStateModel();
  }

  // Validate and connect wallet
  Future<void> connectWalletAddress({
    required String userId,
    required String walletAddress,
    required bool checkWhitelist,
    required String name,
    required int predefinedId,
  }) async {
    if (state.isConnecting) return; // Prevent multiple connection attempts

    // Reset state
    state = WithdrawalMethodConnectionStateModel(
      state: WithdrawalMethodConnectionState.validating,
      isConnecting: true,
    );

    try {
      // Step 1: Validate wallet address
      await _validateWalletAddress(walletAddress: walletAddress);

      // Step 2: Check whitelist
      await _checkWhitelist(
        walletAddress: walletAddress,
        checkWhitelist: checkWhitelist,
      );

      // Step 3: Handle server wallet
      final serverWalletData = await _handleServerWallet(userId);

      // Step 4: Handle contract deployment
      final contractData = await _handleContractDeploymentOrInteraction(
        userId: userId,
        primaryPaymentMethod: walletAddress,
        serverWalletData: serverWalletData,
        isLinkingNewWithdrawalMethod: checkWhitelist == false,
        predefinedId: predefinedId - 1,
      );

      // Step 5: Complete setup
      await _completeSetup(
        userId: userId,
        walletAddress: walletAddress,
        contractData: contractData,
        name: name,
        predefinedId: predefinedId,
      );

      // Success
      state = state.copyWith(
        state: WithdrawalMethodConnectionState.success,
        isConnecting: false,
      );
    } catch (e) {
      _handleError(e, walletAddress);
    }
  }

  // Helper method to validate wallet address
  Future<void> _validateWalletAddress({required String walletAddress}) async {
    bool isValidEthereumAddress = _withdrawalMethodService
        .isValidEthereumAddress(walletAddress);

    if (!isValidEthereumAddress) {
      throw Exception(
        'Invalid Ethereum wallet address format. Please enter a valid address.',
      );
    }

    bool isWalletAddressUsed = await _withdrawalMethodService
        .isWalletAddressUsed(walletAddress);

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
  Future<void> _checkWhitelist({
    required String walletAddress,
    required bool checkWhitelist,
  }) async {
    state = state.copyWith(
      state: WithdrawalMethodConnectionState.checkingWhitelist,
    );

    final isVerified = await _withdrawalMethodService.isGoodDollarVerified(
      walletAddress,
      checkWhitelist,
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
    state = state.copyWith(
      state: WithdrawalMethodConnectionState.creatingServerWallet,
    );

    try {
      final serverWalletData =
          await _withdrawalMethodService.createServerWallet();

      // Update PaxAccount with server wallet data immediately
      await _withdrawalMethodService.updatePaxAccount(userId, {
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
  Future<Map<String, dynamic>> _handleContractDeploymentOrInteraction({
    required String userId,
    required String primaryPaymentMethod,
    required Map<String, dynamic> serverWalletData,
    required bool isLinkingNewWithdrawalMethod,
    required int predefinedId,
  }) async {
    // Refresh the PaxAccount provider and wait for it to complete
    await ref.read(paxAccountProvider.notifier).refreshAccount();
    final latestPaxAccount = ref.read(paxAccountProvider).account;

    // Check if contract exists already
    bool contractExists =
        latestPaxAccount?.contractAddress != null &&
        latestPaxAccount?.contractAddress?.isNotEmpty == true &&
        latestPaxAccount?.contractCreationTxnHash != null &&
        latestPaxAccount?.contractCreationTxnHash?.isNotEmpty == true;

    if (contractExists) {
      Map<String, dynamic> contractData = {
        'contractAddress': latestPaxAccount?.contractAddress,
        'contractCreationTxnHash': latestPaxAccount?.contractCreationTxnHash,
      };

      if (isLinkingNewWithdrawalMethod) {
        final addNonPrimaryPaymentMethodData =
            await _addNonPrimaryPaymentMethodToPaxAccount(
              userId: userId,
              paxAccountContractAddress:
                  latestPaxAccount?.contractAddress ?? '',
              primaryPaymentMethod: primaryPaymentMethod,
              serverWalletData: serverWalletData,
              predefinedId: predefinedId,
            );

        contractData.addAll(addNonPrimaryPaymentMethodData);
      }

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
    state = state.copyWith(
      state: WithdrawalMethodConnectionState.deployingOrInteractingWithContract,
    );

    try {
      final contractData = await _withdrawalMethodService
          .deployPaxAccountV1ProxyContractAddress(
            primaryPaymentMethod,
            serverWalletData['serverWalletId'],
          );

      // Update PaxAccount with contract data immediately
      await _withdrawalMethodService.updatePaxAccount(userId, {
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

  // Helper method to deploy new contract
  Future<Map<String, dynamic>> _addNonPrimaryPaymentMethodToPaxAccount({
    required String userId,
    required String paxAccountContractAddress,
    required String primaryPaymentMethod,
    required Map<String, dynamic> serverWalletData,
    required int predefinedId,
  }) async {
    state = state.copyWith(
      state: WithdrawalMethodConnectionState.deployingOrInteractingWithContract,
    );

    try {
      final contractData = await _withdrawalMethodService
          .addNonPrimaryPaymentMethodToPaxAccount(
            withdrawalMethod: primaryPaymentMethod,
            predefinedId: predefinedId,
            serverWalletId: serverWalletData['serverWalletId'],
            contractAddress: paxAccountContractAddress,
          );

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
  Future<void> _completeSetup({
    required String userId,
    required String walletAddress,
    required Map<String, dynamic> contractData,
    required String name,
    required int predefinedId,
  }) async {
    state = state.copyWith(
      state: WithdrawalMethodConnectionState.creatingWithdrawalMethod,
    );

    // Refresh the PaxAccount provider and wait for it to complete
    await ref.read(paxAccountProvider.notifier).refreshAccount();
    final finalPaxAccount = ref.read(paxAccountProvider).account;
    final startingPaxAccount = ref.read(paxAccountProvider).account;

    try {
      await _withdrawalMethodService.createWithdrawalMethod(
        userId: userId,
        paxAccountId: finalPaxAccount?.id ?? startingPaxAccount!.id,
        walletAddress: walletAddress,
        name: name,
        predefinedId: predefinedId,
        txnHash: contractData['txnHash'],
      );

      // Update state to show we're updating participant related data
      state = state.copyWith(
        state: WithdrawalMethodConnectionState.updatingParticipant,
      );

      if (predefinedId == 1) {
        // This is the first withdrawal method connection
        await _updateParticipantData(userId, walletAddress);
        await _createAchievementsForFirstTimeWithdrawalMethodConnection(userId);

        await _sendAnalyticsAndNotificationsForFirstTimeWithdrawalMethodConnection(
          userId,
          walletAddress,
          finalPaxAccount,
        );
      }

      if (predefinedId == 2) {
        // This is the second withdrawal method connection
        await _createDoublePayoutConnectorAchievement(userId);

        await _sendAnalyticsAndNotificationsForNonFirstTimeWithdrawalMethodConnection(
          userId: userId,
          primaryPaymentMethod: walletAddress,
          predefinedId: predefinedId,
        );
      }
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
    int goodDollarIdentityTimeLastAuthenticated = await _withdrawalMethodService
        .getLastAuthenticated(primaryPaymentMethod);

    // Get GoodDollar identity expiry date
    Timestamp? goodDollarIdentityExpiryDate = await _withdrawalMethodService
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
  Future<void> _createAchievementsForFirstTimeWithdrawalMethodConnection(
    String userId,
  ) async {
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

  Future<void> _createDoublePayoutConnectorAchievement(String userId) async {
    final fcmToken = await ref.read(fcmTokenProvider.future);

    // Create payout connector achievement
    await ref
        .read(achievementsProvider.notifier)
        .createAchievement(
          timeCreated: Timestamp.now(),
          participantId: userId,
          name: AchievementConstants.doublePayoutConnector,
          tasksNeededForCompletion:
              AchievementConstants.doublePayoutConnectorTasksNeeded,
          tasksCompleted: 1,
          timeCompleted: Timestamp.now(),
          amountEarned: AchievementConstants.doublePayoutConnectorAmount,
        );

    ref.read(analyticsProvider).achievementCreated({
      'achievementName': AchievementConstants.doublePayoutConnector,
      'amountEarned': AchievementConstants.doublePayoutConnectorAmount,
    });

    if (fcmToken != null) {
      await ref
          .read(notificationServiceProvider)
          .sendAchievementEarnedNotification(
            token: fcmToken,
            achievementData: {
              'achievementName': AchievementConstants.doublePayoutConnector,
              'amountEarned': AchievementConstants.doublePayoutConnectorAmount,
            },
          );
    }

    await ref.read(achievementsProvider.notifier).fetchAchievements(userId);
  }

  // Helper method to send analytics and notifications
  Future<void>
  _sendAnalyticsAndNotificationsForFirstTimeWithdrawalMethodConnection(
    String userId,
    String primaryPaymentMethod,
    dynamic finalPaxAccount,
  ) async {
    // Refresh providers properly
    await ref.read(participantProvider.notifier).refreshParticipant();
    await ref.read(withdrawalMethodsProvider.notifier).refresh(userId);

    final participant = ref.read(participantProvider);
    final withdrawalMethod = ref.read(withdrawalMethodsProvider);

    // Check if participant exists
    if (participant.participant == null) {
      if (kDebugMode) {
        print('Warning: Participant is null, skipping analytics');
      }
      return;
    }

    // Check if withdrawal methods exist before accessing first element
    if (withdrawalMethod.withdrawalMethods.isNotEmpty) {
      final withdrawalMethodData =
          withdrawalMethod.withdrawalMethods.first.toMap();

      withdrawalMethodData.addAll({
        "currentWithdrawalMethodCount":
            withdrawalMethod.withdrawalMethods.length,
      });

      ref
          .read(analyticsProvider)
          .withdrawalMethodConnectionComplete(withdrawalMethodData);
    } else {
      if (kDebugMode) {
        print('Warning: No withdrawal methods found for analytics');
      }
      // Send analytics without withdrawal method data
      ref.read(analyticsProvider).withdrawalMethodConnectionComplete({});
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

  Future<void>
  _sendAnalyticsAndNotificationsForNonFirstTimeWithdrawalMethodConnection({
    required String userId,
    required String primaryPaymentMethod,
    required int predefinedId,
  }) async {
    // Refresh providers properly
    await ref.read(participantProvider.notifier).refreshParticipant();
    await ref.read(withdrawalMethodsProvider.notifier).refresh(userId);

    final withdrawalMethod = ref.read(withdrawalMethodsProvider);

    if (withdrawalMethod.withdrawalMethods.isNotEmpty &&
        withdrawalMethod.withdrawalMethods.length >= predefinedId) {
      ref
          .read(analyticsProvider)
          .withdrawalMethodConnectionComplete(
            withdrawalMethod.withdrawalMethods[predefinedId - 1].toMap(),
          );
    } else {
      ref.read(analyticsProvider).withdrawalMethodConnectionComplete({
        "currentWithdrawalMethodCount":
            withdrawalMethod.withdrawalMethods.length,
      });
    }
  }

  // Helper method to handle errors
  void _handleError(dynamic error, String primaryPaymentMethod) {
    if (kDebugMode) {
      print('Error: $error');
    }

    ref.read(analyticsProvider).withdrawalMethodConnectionFailed({
      "primaryPaymentMethod": primaryPaymentMethod,
      "error": error.toString().substring(
        0,
        error.toString().length.clamp(0, 99),
      ),
    });

    state = state.copyWith(
      state: WithdrawalMethodConnectionState.error,
      errorMessage: error.toString(),
      isConnecting: false,
    );
  }

  // Reset state
  void resetState() {
    state = WithdrawalMethodConnectionStateModel();
  }
}

// Create the provider for the withdrawal method connection notifier
final withdrawalConnectionProvider = NotifierProvider<
  WithdrawalMethodConnectionNotifier,
  WithdrawalMethodConnectionStateModel
>(() {
  return WithdrawalMethodConnectionNotifier();
});

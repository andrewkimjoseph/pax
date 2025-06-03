// providers/minipay_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/db/achievement/achievement_provider.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';
import 'package:pax/providers/db/payment_method/payment_method_provider.dart';
import 'package:pax/repositories/firestore/payment_method/payment_method_repository.dart';
import 'package:pax/services/minipay/minipay_service.dart';
import 'package:pax/providers/fcm/fcm_provider.dart';

final paymentMethodRepositoryProvider = Provider<PaymentMethodRepository>((
  ref,
) {
  return PaymentMethodRepository();
});

final miniPayServiceProvider = Provider<MiniPayService>((ref) {
  return MiniPayService(
    paxAccountRepository: ref.watch(paxAccountRepositoryProvider),
    paymentMethodRepository: ref.watch(paymentMethodRepositoryProvider),
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
      // 1. Validate wallet address format
      if (!_miniPayService.isValidEthereumAddress(primaryPaymentMethod)) {
        state = state.copyWith(
          state: MiniPayConnectionState.error,
          errorMessage:
              'Invalid Ethereum wallet address format. Please enter a valid address.',
          isConnecting: false,
        );
        return;
      }

      // 2. Check if wallet address is already used
      final isUsed = await _miniPayService.isWalletAddressUsed(
        primaryPaymentMethod,
      );
      if (isUsed) {
        state = state.copyWith(
          state: MiniPayConnectionState.error,
          errorMessage:
              'This wallet address is already in use. Please use a different address.',
          isConnecting: false,
        );
        return;
      }

      // 3. Check GoodDollar whitelist
      state = state.copyWith(state: MiniPayConnectionState.checkingWhitelist);

      final isVerified = await _miniPayService.isGoodDollarVerified(
        primaryPaymentMethod,
      );
      if (!isVerified) {
        state = state.copyWith(
          state: MiniPayConnectionState.error,
          errorMessage:
              'This wallet is not GoodDollar verified. Please complete verification first.',
          isConnecting: false,
        );
        return;
      }

      // 4. Get the existing PaxAccount
      final paxAccount = await _miniPayService.getPaxAccount(userId);
      if (paxAccount == null) {
        state = state.copyWith(
          state: MiniPayConnectionState.error,
          errorMessage: 'PaxAccount not found',
          isConnecting: false,
        );
        return;
      }

      // 5. Check if server wallet exists already in the PaxAccount
      Map<String, dynamic> serverWalletData;
      if (paxAccount.serverWalletId != null &&
          paxAccount.serverWalletId!.isNotEmpty &&
          paxAccount.serverWalletAddress != null &&
          paxAccount.serverWalletAddress!.isNotEmpty &&
          paxAccount.smartAccountWalletAddress != null &&
          paxAccount.smartAccountWalletAddress!.isNotEmpty) {
        // Use existing server wallet
        if (kDebugMode) {
          print('Using existing PaxAccount details: ${paxAccount.toMap()}');
        }

        serverWalletData = {
          'serverWalletId': paxAccount.serverWalletId,
          'serverWalletAddress': paxAccount.serverWalletAddress,
          'smartAccountWalletAddress': paxAccount.smartAccountWalletAddress,
        };

        state = state.copyWith(
          serverWalletData: serverWalletData,
          serverWalletCreated: true,
        );
      } else {
        // Create a new server wallet
        state = state.copyWith(
          state: MiniPayConnectionState.creatingServerWallet,
        );

        try {
          serverWalletData = await _miniPayService.createServerWallet();

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
        } catch (e) {
          if (kDebugMode) {
            print('Error creating server wallet: $e');
          }
          state = state.copyWith(
            state: MiniPayConnectionState.error,
            errorMessage: 'Failed to create server wallet: ${e.toString()}',
            isConnecting: false,
          );
          return;
        }
      }

      // 6. Check if contract exists already in the PaxAccount
      Map<String, dynamic> contractData;
      if (paxAccount.contractAddress != null &&
          paxAccount.contractAddress!.isNotEmpty &&
          paxAccount.contractCreationTxnHash != null &&
          paxAccount.contractCreationTxnHash!.isNotEmpty) {
        // Use existing contract
        if (kDebugMode) {
          print('Using existing contract: ${paxAccount.contractAddress}');
        }

        contractData = {
          'contractAddress': paxAccount.contractAddress,
          'contractCreationTxnHash': paxAccount.contractCreationTxnHash,
        };

        state = state.copyWith(
          contractData: contractData,
          contractDeployed: true,
        );
      } else {
        // Deploy a new contract
        state = state.copyWith(state: MiniPayConnectionState.deployingContract);

        try {
          contractData = await _miniPayService
              .deployPaxAccountV1ProxyContractAddress(
                primaryPaymentMethod,
                serverWalletData['serverWalletId'],
              );

          // Update PaxAccount with contract data immediately
          await _miniPayService.updatePaxAccount(userId, {
            'contractAddress': contractData['contractAddress'],
            'contractCreationTxnHash':
                contractData['contractCreationTxnHash'] ??
                contractData['txnHash'],
          });

          state = state.copyWith(
            contractData: contractData,
            contractDeployed: true,
          );
        } catch (e) {
          if (kDebugMode) {
            print('Error deploying contract: $e');
          }
          state = state.copyWith(
            state: MiniPayConnectionState.error,
            errorMessage: 'Failed to deploy contract: ${e.toString()}',
            isConnecting: false,
          );
          return;
        }
      }

      // 7. Create payment method and update participant
      state = state.copyWith(
        state: MiniPayConnectionState.creatingPaymentMethod,
      );

      try {
        await _miniPayService.createPaymentMethod(
          userId: userId,
          paxAccountId: paxAccount.id,
          walletAddress: primaryPaymentMethod,
        );

        // Update state to show we're updating participant related data
        state = state.copyWith(
          state: MiniPayConnectionState.updatingParticipant,
        );

        // Get the last authentication time and expiry date from GoodDollar
        int goodDollarIdentityTimeLastAuthenticated = await _miniPayService
            .getLastAuthenticated(primaryPaymentMethod);

        // Get GoodDollar identity expiry date
        Timestamp? goodDollarIdentityExpiryDate = await _miniPayService
            .getGoodDollarIdentityExpiryDate(primaryPaymentMethod);

        // Refresh payment methods in state
        await ref.read(paymentMethodsProvider.notifier).refresh(userId);

        // Sync blockchain balances with Firestore
        await ref
            .read(paxAccountProvider.notifier)
            .syncBalancesFromBlockchain();

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

        // Create achievements
        await ref
            .read(achievementProvider.notifier)
            .createAchievement(
              timeCreated: Timestamp.now(),
              participantId: userId,
              name: 'Payout Connector',
              tasksNeededForCompletion: 1,
              tasksCompleted: 1,
              timeCompleted: Timestamp.now(),
              amountEarned: 500,
            );
        ref.read(analyticsProvider).achievementCreated({
          'achievementName': 'Payout Connector',
          'amountEarned': 500,
        });
        final fcmToken = await ref.read(fcmTokenProvider.future);
        if (fcmToken != null) {
          await ref
              .read(notificationServiceProvider)
              .sendAchievementEarnedNotification(
                token: fcmToken,
                achievementData: {
                  'achievementName': 'Payout Connector',
                  'amountEarned': 500,
                },
              );
        }

        await ref
            .read(achievementProvider.notifier)
            .createAchievement(
              timeCreated: Timestamp.now(),
              participantId: userId,
              name: 'Verified Human',
              tasksNeededForCompletion: 1,
              tasksCompleted: 1,
              timeCompleted: Timestamp.now(),
              amountEarned: 500,
            );
        ref.read(analyticsProvider).achievementCreated({
          'achievementName': 'Verified Human',
          'amountEarned': 500,
        });
        if (fcmToken != null) {
          ref
              .read(notificationServiceProvider)
              .sendAchievementEarnedNotification(
                token: fcmToken,
                achievementData: {
                  'achievementName': 'Verified Human',
                  'amountEarned': 500,
                },
              );
        }

        // Refresh achievements
        await ref.read(achievementProvider.notifier).fetchAchievements(userId);

        // Refresh participant data in state
        await ref.read(participantProvider.notifier).refreshParticipant();

        final participant = ref.read(participantProvider);

        final paymentMethod = ref.read(paymentMethodsProvider).paymentMethods;

        ref
            .read(analyticsProvider)
            .minipayConnectionComplete(paymentMethod.first.toMap());

        ref.read(analyticsProvider).identifyUser({
          '[Pax] Participant Id': participant.participant?.id,
          '[Pax] Display Name': participant.participant?.displayName,
          '[Pax] Email Address': participant.participant?.emailAddress,
          '[Pax] Phone Number': participant.participant?.phoneNumber,
          '[Pax] Gender': participant.participant?.gender,
          '[Pax] Country': participant.participant?.country,
          '[Pax] Date of Birth': participant.participant?.dateOfBirth,
          '[Pax] Profile Picture URI':
              participant.participant?.profilePictureURI,
          '[Pax] GoodDollar Identity Time Last Authenticated':
              participant.participant?.goodDollarIdentityTimeLastAuthenticated,
          '[Pax] GoodDollar Identity Expiry Date':
              participant.participant?.goodDollarIdentityExpiryDate,
          '[Pax] Time Created': participant.participant?.timeCreated,
          '[Pax] Time Updated': participant.participant?.timeUpdated,
          '[Pax] MiniPay Wallet Address': primaryPaymentMethod,
          '[Pax] Privy Server Wallet Id': paxAccount.serverWalletId,
          '[Pax] Privy Server Wallet Address': paxAccount.serverWalletAddress,
          '[Pax] Smart Account Wallet Address':
              paxAccount.smartAccountWalletAddress,
          '[Pax] PaxAccount Id': paxAccount.id,
          '[Pax] PaxAccount Contract Address': paxAccount.contractAddress,
          '[Pax] PaxAccount Contract Creation Txn Hash':
              paxAccount.contractCreationTxnHash,
        });

        // Set state to success once everything is complete
        state = state.copyWith(
          state: MiniPayConnectionState.success,
          isConnecting: false,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Error creating payment method or updating participant: $e');
        }
        state = state.copyWith(
          state: MiniPayConnectionState.error,
          errorMessage: 'Failed to complete wallet connection: ${e.toString()}',
          isConnecting: false,
        );
      }
    } catch (e) {
      ref.read(analyticsProvider).minipayConnectionFailed({
        "primaryPaymentMethod": primaryPaymentMethod,
      });
      state = state.copyWith(
        state: MiniPayConnectionState.error,
        errorMessage: 'An error occurred: ${e.toString()}',
        isConnecting: false,
      );
    }
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

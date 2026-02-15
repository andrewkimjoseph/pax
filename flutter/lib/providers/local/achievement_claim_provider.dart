import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/firestore/achievement/achievement_model.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/providers/db/achievement/achievement_provider.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';
import 'package:pax/providers/db/withdrawal_method/withdrawal_method_provider.dart';
import 'package:pax/providers/fcm/fcm_provider.dart';
import 'package:pax/providers/withdrawal_method_connection/withdrawal_method_connection_provider.dart';
import 'package:pax/repositories/firestore/achievement/achievement_repository.dart';
import 'package:pax/services/blockchain/blockchain_service.dart';
import 'package:pax/services/notifications/notification_service.dart';
import 'package:pax/services/withdrawal/withdrawal_method_connection_service.dart';
import 'package:pax/utils/secret_constants.dart';

class AchievementStateModel {
  final Map<String, bool> claimingStates;
  final String? errorMessage;
  final String? txnHash;

  const AchievementStateModel({
    this.claimingStates = const {},
    this.errorMessage,
    this.txnHash,
  });

  AchievementStateModel copyWith({
    Map<String, bool>? claimingStates,
    String? errorMessage,
    String? txnHash,
  }) {
    return AchievementStateModel(
      claimingStates: claimingStates ?? this.claimingStates,
      errorMessage: errorMessage,
      txnHash: txnHash ?? this.txnHash,
    );
  }

  bool isClaiming(String achievementId) =>
      claimingStates[achievementId] ?? false;
}

class AchievementNotifier extends Notifier<AchievementStateModel> {
  final AchievementRepository _achievementRepository = AchievementRepository();
  final NotificationService _notificationService = NotificationService();
  late final WithdrawalMethodConnectionService _withdrawalMethodService;

  @override
  AchievementStateModel build() {
    _withdrawalMethodService = ref.watch(withdrawalMethodConnectionProvider);
    return const AchievementStateModel();
  }

  Future<void> claimAchievement({required Achievement achievement}) async {
    if (state.isClaiming(achievement.id)) return;

    if (achievement.status == AchievementStatus.claimed) {
      return;
    }

    // Set claiming state for this specific achievement
    final updatedClaimingStates = Map<String, bool>.from(state.claimingStates);
    updatedClaimingStates[achievement.id] = true;
    state = state.copyWith(
      claimingStates: updatedClaimingStates,
      errorMessage: null,
      txnHash: null,
    );

    try {
      final auth = ref.read(authProvider);
      final paxAccountContractAddress =
          ref.read(paxAccountProvider).account?.contractAddress;

      if (paxAccountContractAddress == null) {
        throw Exception('Pax account not found');
      }

      // Check if the claiming address has sufficient balance
      final hasBalance = await BlockchainService.hasSufficientBalance(
        paxMasterAddressSmartAccountWalletAddress,
        BlockchainService.supportedTokens[1]!.address,
        achievement.amountEarned?.toDouble() ?? 0,
        18,
      );

      if (!hasBalance) {
        final finalClaimingStates = Map<String, bool>.from(
          state.claimingStates,
        );
        finalClaimingStates.remove(achievement.id);
        state = state.copyWith(
          claimingStates: finalClaimingStates,
          errorMessage: 'B: Claiming is not possible at this time',
        );
        throw Exception('B: Claiming is not possible at this time');
      }

      // Check if at least one withdrawal method is GoodDollar verified
      final withdrawalMethods =
          ref.read(withdrawalMethodsProvider).withdrawalMethods;
      bool hasVerifiedMethod = false;

      for (final withdrawalMethod in withdrawalMethods) {
        final isVerified = await _withdrawalMethodService.isGoodDollarVerified(
          withdrawalMethod.walletAddress,
          true, // checkWhitelist = true
        );
        if (isVerified) {
          hasVerifiedMethod = true;
          break;
        }
      }

      // If no withdrawal method is verified, fail the claim
      if (!hasVerifiedMethod) {
        final finalClaimingStates = Map<String, bool>.from(
          state.claimingStates,
        );
        finalClaimingStates.remove(achievement.id);
        state = state.copyWith(
          claimingStates: finalClaimingStates,
          errorMessage:
              'You need to complete face verification again in MiniPay or GoodWallet.',
        );
        throw Exception(
          'You need to complete face verification again in MiniPay or GoodWallet.',
        );
      }

      // Call the cloud function
      final txnHash = await _achievementRepository.processAchievementClaim(
        achievementId: achievement.id,
        paxAccountContractAddress: paxAccountContractAddress,
        amountEarned: achievement.amountEarned ?? 0,
        tasksCompleted: achievement.tasksCompleted,
      );

      // Send notification about the claimed achievement
      final fcmToken = await ref.read(fcmTokenProvider.future);
      if (fcmToken != null) {
        await _notificationService.sendAchievementClaimedNotification(
          token: fcmToken,
          achievementData: {
            'achievementName': achievement.name,
            'amountEarned': achievement.amountEarned ?? 0,
            'txnHash': txnHash,
          },
        );
      }

      // Update balances
      await ref.read(paxAccountProvider.notifier).syncBalancesFromBlockchain();

      // Clear claiming state for this achievement
      final finalClaimingStates = Map<String, bool>.from(state.claimingStates);
      finalClaimingStates.remove(achievement.id);
      state = state.copyWith(
        claimingStates: finalClaimingStates,
        txnHash: txnHash,
      );

      // Only fetch achievements if the provider is still mounted
      if (ref.mounted) {
        ref
            .read(achievementsProvider.notifier)
            .fetchAchievements(auth.user.uid);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error claiming achievement: $e');
      }

      // Clear claiming state for this achievement
      final finalClaimingStates = Map<String, bool>.from(state.claimingStates);
      finalClaimingStates.remove(achievement.id);
      state = state.copyWith(
        claimingStates: finalClaimingStates,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  void resetState() {
    state = const AchievementStateModel();
  }
}

final achievementClaimProvider =
    NotifierProvider<AchievementNotifier, AchievementStateModel>(
      () => AchievementNotifier(),
    );

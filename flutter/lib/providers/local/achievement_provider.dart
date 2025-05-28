import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/firestore/achievement/achievement_model.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/providers/db/achievement/achievement_provider.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';
import 'package:pax/providers/fcm/fcm_provider.dart';
import 'package:pax/services/achievement_service.dart';
import 'package:pax/services/blockchain/blockchain_service.dart';
import 'package:pax/services/notifications/notification_service.dart';
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
  final AchievementService _achievementService = AchievementService();
  final BlockchainService _blockchainService = BlockchainService();
  final NotificationService _notificationService = NotificationService();

  @override
  AchievementStateModel build() {
    return const AchievementStateModel();
  }

  Future<void> claimAchievement({required Achievement achievement}) async {
    if (state.isClaiming(achievement.id)) return;

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
      final hasBalance = await _blockchainService.hasSufficientBalance(
        paxMasterAddressSmartAccount,
        BlockchainService.supportedTokens[1]!.address,
        achievement.amountAwarded.toDouble(),
        18,
      );

      if (!hasBalance) {
        throw Exception('B: Claiming is not possible at this time');
      }

      // Call the cloud function
      final txnHash = await _achievementService.processAchievementClaim(
        achievementId: achievement.id,
        paxAccountContractAddress: paxAccountContractAddress,
        amountEarned: achievement.amountAwarded,
        tasksCompleted: achievement.tasksCompleted,
      );

      // Send notification about the claimed achievement
      final fcmToken = await ref.read(fcmTokenProvider.future);
      if (fcmToken != null) {
        await _notificationService.sendAchievementClaimedNotification(
          token: fcmToken,
          achievementData: {
            'achievementName': achievement.name,
            'amountEarned': achievement.amountAwarded,
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

      ref.read(achievementProvider.notifier).fetchAchievements(auth.user.uid);
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

// This service manages the participant screening process:
// - Handles participant screening through Firebase Functions
// - Manages screening state and context through Riverpod providers
// - Updates activity feed after successful screening
// - Provides error handling and state management for the screening process

// lib/services/screening_service.dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/db/tasks/task_provider.dart';
import 'package:pax/providers/db/withdrawal_method/withdrawal_method_provider.dart';
import 'package:pax/providers/local/activity_providers.dart';
import 'package:pax/providers/local/screening_state_provider.dart';
import 'package:pax/providers/local/screenings_provider.dart';
import 'package:pax/providers/local/screening_context/screening_context_provider.dart';
import 'package:pax/providers/withdrawal_method_connection/withdrawal_method_connection_provider.dart';
import 'package:pax/services/notifications/notification_service.dart';

class ScreeningService {
  final Ref ref;

  ScreeningService(this.ref);

  Future<void> screenParticipant({
    required String serverWalletId,
    required String taskId,
    required String participantId,
    required String taskManagerContractAddress,
    required String taskMasterServerWalletId,
  }) async {
    try {
      // Update state to loading
      ref.read(screeningProvider.notifier).startScreening();

      // Refresh withdrawal methods so we use the latest from Firestore (avoids
      // stale or empty list when user just verified or navigated before initial
      // load completed).
      await ref.read(withdrawalMethodsProvider.notifier).refresh(participantId);

      final withdrawalMethods =
          ref.read(withdrawalMethodsProvider).withdrawalMethods;

      // Check if at least one withdrawal method is GoodDollar verified
      final withdrawalService = ref.read(withdrawalMethodConnectionProvider);
      bool hasVerifiedMethod = false;

      for (final withdrawalMethod in withdrawalMethods) {
        final isVerified = await withdrawalService.isGoodDollarVerified(
          withdrawalMethod.walletAddress,
          true, // checkWhitelist = true
        );
        if (isVerified) {
          hasVerifiedMethod = true;
          break;
        }
      }

      // If no withdrawal method is verified, fail the screening
      if (!hasVerifiedMethod) {
        throw Exception(
          'You need to complete face verification again in MiniPay or GoodWallet.',
        );
      }

      // Call the Firebase function
      final httpsCallable = FirebaseFunctions.instance.httpsCallable(
        'screenParticipantProxy',
      );
      final result = await httpsCallable.call({
        'serverWalletId': serverWalletId,
        'taskId': taskId,
        'participantId': participantId,
        'taskManagerContractAddress': taskManagerContractAddress,
        'taskMasterServerWalletId': taskMasterServerWalletId,
      });

      // Extract data from the result
      final data = result.data as Map<String, dynamic>;

      // Create ScreeningResult object
      final screeningResult = ScreeningResult(
        participantProxy: data['participantProxy'],
        taskId: data['taskId'],
        signature: data['signature'],
        nonce: data['nonce'],
        txnHash: data['txnHash'],
        screeningId: data['screeningId'],
        taskCompletionId: data['taskCompletionId'],
      );

      await ref
          .read(screeningContextProvider.notifier)
          .fetchScreeningById(screeningResult.screeningId);

      final screening = ref.read(screeningContextProvider)?.screening;
      if (screening?.timeCreated != null) {
        await NotificationService().scheduleTaskCooldownReminders(
          screening!.timeCreated!.toDate(),
        );
      }

      ref
          .read(screeningContextProvider.notifier)
          .setScreeningResult(screeningResult);

      // Update state to complete with the result
      ref.read(screeningProvider.notifier).completeScreening(screeningResult);

      ref.invalidate(activityRepositoryProvider);
      ref.invalidate(participantScreeningsStreamProvider);
      ref.invalidate(availableTasksStreamProvider(participantId));

      ref.read(analyticsProvider).screeningComplete({
        "taskId": taskId,
        "taskManagerContractAddress": taskManagerContractAddress,
        "screeningId": screeningResult.screeningId,
        "txnHash": screeningResult.txnHash,
        "signature": screeningResult.signature,
        "nonce": screeningResult.nonce,
        "taskCompletionId": screeningResult.taskCompletionId,
      });
    } catch (e) {
      // Update state to error with error message
      ref
          .read(screeningProvider.notifier)
          .setError(e is FirebaseFunctionsException ? e.message : e.toString());
      rethrow;
    }
  }
}

final screeningServiceProvider = Provider<ScreeningService>((ref) {
  return ScreeningService(ref);
});

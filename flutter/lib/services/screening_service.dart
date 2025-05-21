// This service manages the participant screening process:
// - Handles participant screening through Firebase Functions
// - Manages screening state and context through Riverpod providers
// - Updates activity feed after successful screening
// - Provides error handling and state management for the screening process

// lib/services/screening_service.dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/local/activity_providers.dart';
import 'package:pax/providers/local/screening_state_provider.dart';
import 'package:pax/providers/local/task_context/screening_context_provider.dart';

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

      // Update state to complete with the result
      ref.read(screeningProvider.notifier).completeScreening(screeningResult);

      ref.invalidate(activityRepositoryProvider);
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

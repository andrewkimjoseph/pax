// lib/providers/db/screenings/screenings_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/firestore/screening/screening_model.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';

// Provider for participant's screenings only
final participantScreeningsStreamProvider =
    StreamProvider.autoDispose<List<Screening>>((ref) {
      final participantState = ref.read(participantProvider);
      final participant = participantState.participant;
      if (participant == null || participant.id.isEmpty) {
        return Stream.value([]);
      }

      return FirebaseFirestore.instance
          .collection('screenings')
          .where('participantId', isEqualTo: participant.id)
          .orderBy('timeCreated', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => Screening.fromFirestore(doc))
                    .toList(),
          );
    });

// Provider for a specific task's screening for the current participant
final taskScreeningProvider = Provider.family<Screening?, String>((
  ref,
  taskId,
) {
  final screeningsAsyncValue = ref.watch(participantScreeningsStreamProvider);

  return screeningsAsyncValue.when(
    data: (screenings) {
      try {
        return screenings.firstWhere((screening) => screening.taskId == taskId);
      } catch (e) {
        // If no matching screening is found, return null
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

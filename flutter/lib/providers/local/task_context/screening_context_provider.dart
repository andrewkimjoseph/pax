// lib/providers/local/screening_context/screening_context_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/firestore/screening/screening_model.dart';

// Provider for getting a screening by ID (as a Future)
final screeningByIdProvider = FutureProvider.family<Screening?, String>((
  ref,
  screeningId,
) async {
  if (screeningId.isEmpty) {
    return null;
  }

  try {
    // Get screening document from Firestore
    final docSnapshot =
        await FirebaseFirestore.instance
            .collection('screenings')
            .doc(screeningId)
            .get();

    if (!docSnapshot.exists) {
      return null;
    }

    return Screening.fromFirestore(docSnapshot);
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching screening: $e');
    }
    return null;
  }
});

// Model for screening context
class ScreeningContext {
  final Screening? screening;

  const ScreeningContext({this.screening});

  ScreeningContext copyWith({Screening? screening}) {
    return ScreeningContext(screening: screening ?? this.screening);
  }
}

// Notifier for screening context
class ScreeningContextNotifier extends Notifier<ScreeningContext?> {
  @override
  ScreeningContext? build() {
    return null;
  }

  void setScreening(Screening screening) {
    state = ScreeningContext(screening: screening);
  }

  Future<void> fetchScreeningById(String screeningId) async {
    if (screeningId.isEmpty) {
      return;
    }

    try {
      // Get screening document from Firestore
      final docSnapshot =
          await FirebaseFirestore.instance
              .collection('screenings')
              .doc(screeningId)
              .get();

      if (!docSnapshot.exists) {
        state = null;
        return;
      }

      final screening = Screening.fromFirestore(docSnapshot);
      state = ScreeningContext(screening: screening);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching screening: $e');
      }
      state = null;
    }
  }

  void clear() {
    state = null;
  }
}

// Provider for screening context
final screeningContextProvider =
    NotifierProvider<ScreeningContextNotifier, ScreeningContext?>(
      () => ScreeningContextNotifier(),
    );

// Stream provider for real-time updates to a screening
final screeningStreamProvider = StreamProvider.family<Screening?, String>((
  ref,
  screeningId,
) {
  if (screeningId.isEmpty) {
    return Stream.value(null);
  }

  return FirebaseFirestore.instance
      .collection('screenings')
      .doc(screeningId)
      .snapshots()
      .map((snapshot) {
        if (!snapshot.exists) {
          return null;
        }
        return Screening.fromFirestore(snapshot);
      });
});

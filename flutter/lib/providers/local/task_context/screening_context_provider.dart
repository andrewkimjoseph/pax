// This file contains providers for managing screening-related state and data.
// It provides functionality for:
// - Fetching screening data by ID
// - Managing screening context state
// - Streaming real-time screening updates
//
// The providers in this file work in conjunction with the task context providers
// to provide a complete view of a task's screening status.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/firestore/screening/screening_model.dart';

/// Provider for getting a screening by ID.
/// This provider fetches a single screening record from Firestore.
/// Returns null if the screening doesn't exist or if there's an error.
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

/// Model for screening context.
/// This class holds the current screening data and provides methods
/// for creating updated copies of the context.
class ScreeningContext {
  /// The current screening data, if any
  final Screening? screening;

  const ScreeningContext({this.screening});

  /// Create a copy with updated screening data.
  /// This is used to maintain immutability while allowing state updates.
  ScreeningContext copyWith({Screening? screening}) {
    return ScreeningContext(screening: screening ?? this.screening);
  }
}

/// Notifier for screening context.
/// This notifier manages the state of the current screening context,
/// providing methods to set, fetch, and clear the screening data.
class ScreeningContextNotifier extends Notifier<ScreeningContext?> {
  @override
  ScreeningContext? build() {
    return null;
  }

  /// Set the screening context with the provided screening data.
  /// This should be called when a screening is selected or created.
  void setScreening(Screening screening) {
    state = ScreeningContext(screening: screening);
  }

  /// Fetch a screening by ID and update the context.
  /// This method will update the state with the fetched screening data
  /// or set it to null if the screening doesn't exist.
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

  /// Clear the screening context.
  /// This should be called when navigating away from a screening
  /// or when the screening data is no longer needed.
  void clear() {
    state = null;
  }
}

/// Provider for screening context.
/// This provider gives access to the current screening context state
/// and methods to modify it.
final screeningContextProvider =
    NotifierProvider<ScreeningContextNotifier, ScreeningContext?>(
      () => ScreeningContextNotifier(),
    );

/// Stream provider for real-time updates to a screening.
/// This provider streams updates for a specific screening document.
/// Returns null if the screening doesn't exist or if there's an error.
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

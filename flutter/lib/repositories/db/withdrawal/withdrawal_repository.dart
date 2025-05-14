// lib/repositories/withdrawal/withdrawal_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/models/firestore/withdrawal/withdrawal_model.dart';

class WithdrawalRepository {
  final FirebaseFirestore _firestore;
  final String collectionName = 'withdrawals';

  WithdrawalRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get withdrawals for a participant
  Future<List<Withdrawal>> getWithdrawalsForParticipant(
    String participantId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection(collectionName)
              .where('participantId', isEqualTo: participantId)
              .orderBy('timeCreated', descending: true)
              .get();

      return snapshot.docs.map((doc) => Withdrawal.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting withdrawals: $e');
      }
      // Return empty list on error
      return [];
    }
  }

  // Get a specific withdrawal by ID
  Future<Withdrawal?> getWithdrawal(String id) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(id).get();

      if (doc.exists) {
        return Withdrawal.fromFirestore(doc);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting withdrawal: $e');
      }
      rethrow;
    }
  }

  // Get withdrawals for a specific payment method
  Future<List<Withdrawal>> getWithdrawalsForPaymentMethod(
    String paymentMethodId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection(collectionName)
              .where('paymentMethodId', isEqualTo: paymentMethodId)
              .orderBy('timeCreated', descending: true)
              .get();

      return snapshot.docs.map((doc) => Withdrawal.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting withdrawals for payment method: $e');
      }
      // Return empty list on error
      return [];
    }
  }
}

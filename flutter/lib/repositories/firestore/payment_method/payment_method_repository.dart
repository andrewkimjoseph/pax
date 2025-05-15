// repositories/payment_method_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/models/firestore/payment_method/payment_method.dart';

class PaymentMethodRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'payment_methods';

  // Check if wallet address is already used
  Future<bool> isWalletAddressUsed(String walletAddress) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(collectionName)
              .where('walletAddress', isEqualTo: walletAddress)
              .limit(1)
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if wallet address is used: $e');
      }
      rethrow;
    }
  }

  // Create a new payment method
  Future<PaymentMethod> createPaymentMethod({
    required String participantId,
    required String paxAccountId,
    required String walletAddress,
    int predefinedId = 1,
    String name = 'minipay',
  }) async {
    try {
      final now = Timestamp.now();

      // Create payment method
      final newPaymentMethod = PaymentMethod(
        id: _firestore.collection(collectionName).doc().id, // Auto-generate ID
        predefinedId: predefinedId,
        participantId: participantId,
        paxAccountId: paxAccountId,
        name: name,
        walletAddress: walletAddress,
        timeCreated: now,
        timeUpdated: now,
      );

      // Save to Firestore
      await _firestore
          .collection(collectionName)
          .doc(newPaymentMethod.id)
          .set(newPaymentMethod.toMap());

      return newPaymentMethod;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating payment method: $e');
      }
      rethrow;
    }
  }

  // Get all payment methods for a participant
  Future<List<PaymentMethod>> getPaymentMethodsForParticipant(
    String participantId,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(collectionName)
              .where('participantId', isEqualTo: participantId)
              .get();

      return querySnapshot.docs
          .map((doc) => PaymentMethod.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting payment methods: $e');
      }
      rethrow;
    }
  }
}

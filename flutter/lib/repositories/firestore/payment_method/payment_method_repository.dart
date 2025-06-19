// repositories/firestore/payment_method/payment_method_repository.dart
// Note: This repository interacts with the 'payment_methods' collection in Firestore,
// while the UI presents these as "Withdrawal Methods" for better user experience.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/models/firestore/payment_method/payment_method.dart';

class WithdrawalMethodRepository {
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
  Future<WithdrawalMethod> createWithdrawalMethod({
    required String participantId,
    required String paxAccountId,
    required String walletAddress,
    int predefinedId = 1,
    String name = 'MiniPay',
    bool isDefault = false,
  }) async {
    try {
      final now = Timestamp.now();

      // If this is set as default, remove default status from other payment methods
      if (isDefault) {
        await _removeDefaultStatus(participantId);
      }

      // Create payment method
      final newPaymentMethod = WithdrawalMethod(
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

  // Update a payment method
  Future<WithdrawalMethod> updatePaymentMethod(
    String paymentMethodId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Add timestamp
      final updateData = {...data, 'timeUpdated': FieldValue.serverTimestamp()};

      // If setting as default, remove default status from other payment methods
      if (data['isDefault'] == true) {
        // Get the payment method to find the participant ID
        final paymentMethodDoc =
            await _firestore
                .collection(collectionName)
                .doc(paymentMethodId)
                .get();

        if (paymentMethodDoc.exists) {
          final participantId = paymentMethodDoc.data()?['participantId'];
          if (participantId != null) {
            await _removeDefaultStatus(
              participantId,
              exceptId: paymentMethodId,
            );
          }
        }
      }

      // Update in Firestore
      await _firestore
          .collection(collectionName)
          .doc(paymentMethodId)
          .update(updateData);

      // Get the updated record
      final updatedDoc =
          await _firestore
              .collection(collectionName)
              .doc(paymentMethodId)
              .get();

      return WithdrawalMethod.fromMap(updatedDoc.data()!, id: updatedDoc.id);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating payment method: $e');
      }
      rethrow;
    }
  }

  // Delete a payment method
  Future<void> deletePaymentMethod(String paymentMethodId) async {
    try {
      await _firestore.collection(collectionName).doc(paymentMethodId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting payment method: $e');
      }
      rethrow;
    }
  }

  // Get all payment methods for a participant
  Future<List<WithdrawalMethod>> getPaymentMethodsForParticipant(
    String participantId,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(collectionName)
              .where('participantId', isEqualTo: participantId)
              .get();

      return querySnapshot.docs
          .map((doc) => WithdrawalMethod.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting payment methods: $e');
      }
      rethrow;
    }
  }

  // Get payment method by wallet address
  Future<WithdrawalMethod?> getPaymentMethodByWalletAddress(
    String walletAddress,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(collectionName)
              .where('walletAddress', isEqualTo: walletAddress)
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return WithdrawalMethod.fromMap(
        querySnapshot.docs.first.data(),
        id: querySnapshot.docs.first.id,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting payment method by wallet address: $e');
      }
      rethrow;
    }
  }

  // Helper method to remove default status from all payment methods for a participant
  Future<void> _removeDefaultStatus(
    String participantId, {
    String? exceptId,
  }) async {
    try {
      // Get all default payment methods
      final querySnapshot =
          await _firestore
              .collection(collectionName)
              .where('participantId', isEqualTo: participantId)
              .where('isDefault', isEqualTo: true)
              .get();

      // Batch update to remove default status
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        // Skip the exception if provided
        if (exceptId != null && doc.id == exceptId) {
          continue;
        }
        batch.update(doc.reference, {
          'isDefault': false,
          'timeUpdated': FieldValue.serverTimestamp(),
        });
      }

      // Commit batch
      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('Error removing default status: $e');
      }
      rethrow;
    }
  }
}

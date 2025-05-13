// repositories/pax_account_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/models/firestore/pax_account/pax_account_model.dart';

class PaxAccountRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'pax_accounts';

  // Check if an account exists for user
  Future<bool> accountExists(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection(collectionName).doc(userId).get();

      return docSnapshot.exists;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if account exists: $e');
      }
      rethrow;
    }
  }

  // Get account by user ID
  Future<PaxAccountModel?> getAccount(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection(collectionName).doc(userId).get();

      if (docSnapshot.exists) {
        return PaxAccountModel.fromMap(docSnapshot.data()!, id: docSnapshot.id);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting account: $e');
      }
      rethrow;
    }
  }

  // Create a new account
  Future<PaxAccountModel> createAccount(String userId) async {
    try {
      final now = Timestamp.now();

      // Create basic account
      final newAccount = PaxAccountModel(
        id: userId,
        timeCreated: now,
        timeUpdated: now,
        balances: {'1': 0, '2': 0, '3': 0, '4': 0}, // Default balance
      );

      // Save to Firestore
      await _firestore
          .collection(collectionName)
          .doc(userId)
          .set(newAccount.toMap());

      return newAccount;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating account: $e');
      }
      rethrow;
    }
  }

  // Update an account
  Future<PaxAccountModel> updateAccount(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Add timestamp
      final updateData = {...data, 'timeUpdated': FieldValue.serverTimestamp()};

      // Update in Firestore
      await _firestore
          .collection(collectionName)
          .doc(userId)
          .update(updateData);

      // Get the updated record
      final updatedDoc =
          await _firestore.collection(collectionName).doc(userId).get();

      return PaxAccountModel.fromMap(updatedDoc.data()!, id: updatedDoc.id);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating account: $e');
      }
      rethrow;
    }
  }

  // Handle user signup - create account if not exists
  Future<PaxAccountModel> handleUserSignup(String userId) async {
    try {
      final exists = await accountExists(userId);

      if (exists) {
        // Account exists, get it
        final account = await getAccount(userId);
        return account!;
      } else {
        // Create new account
        return await createAccount(userId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling user signup: $e');
      }
      rethrow;
    }
  }

  // Update balance for a specific token
  Future<PaxAccountModel> updateBalance(
    String userId,
    String tokenId,
    num amount,
  ) async {
    try {
      // Get current account
      final account = await getAccount(userId);

      if (account == null) {
        throw Exception('Account not found');
      }

      // Update balance for the token
      final updatedBalances = Map<String, num>.from(account.balances);
      updatedBalances[tokenId] = amount;

      // Update account with new balances
      return await updateAccount(userId, {'balances': updatedBalances});
    } catch (e) {
      if (kDebugMode) {
        print('Error updating balance: $e');
      }
      rethrow;
    }
  }
}

// repositories/pax_account_repository.dart - Fixed type casting issues
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/models/firestore/pax_account/pax_account_model.dart';
import 'package:pax/services/blockchain/blockchain_service.dart';
import 'package:pax/utils/local_db_helper.dart';
import 'package:pax/utils/token_balance_util.dart';

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
  Future<PaxAccount?> getAccount(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection(collectionName).doc(userId).get();

      if (docSnapshot.exists) {
        return PaxAccount.fromMap(docSnapshot.data()!, id: docSnapshot.id);
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
  Future<PaxAccount> createAccount(String userId) async {
    try {
      final now = Timestamp.now();

      // Create basic account without balances
      final newAccount = PaxAccount(
        id: userId,
        timeCreated: now,
        timeUpdated: now,
      );

      // Convert to map and remove balances before saving to Firestore
      final accountMap = newAccount.toMap();
      accountMap.remove('balances');

      // Save to Firestore (without balances)
      await _firestore.collection(collectionName).doc(userId).set(accountMap);

      // Upsert default zero balances for all supported tokens in local DB
      for (final token in TokenBalanceUtil.getAllTokens()) {
        await LocalDBHelper().upsertBalance(userId, token.id, 0);
      }

      return newAccount;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating account: $e');
      }
      rethrow;
    }
  }

  // Update an account
  Future<PaxAccount> updateAccount(
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

      return PaxAccount.fromMap(updatedDoc.data()!, id: updatedDoc.id);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating account: $e');
      }
      rethrow;
    }
  }

  // Handle user signup - create account if not exists
  Future<PaxAccount> handleUserSignup(String userId) async {
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
  Future<void> updateBalance(String userId, int tokenId, num amount) async {
    try {
      // Ensure account exists
      final account = await getAccount(userId);
      if (account == null) {
        throw Exception('Account not found');
      }
      // Update balance in local DB only
      await LocalDBHelper().upsertBalance(userId, tokenId, amount);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating balance: $e');
      }
      rethrow;
    }
  }

  // Fetch and sync balances from blockchain
  Future<void> syncBalancesFromBlockchain(String participantId) async {
    try {
      // Get current account
      final account = await getAccount(participantId);
      if (account == null) {
        throw Exception('Account not found');
      }
      // Check if contract address exists
      if (account.contractAddress == null || account.contractAddress!.isEmpty) {
        if (kDebugMode) {
          print('No contract address found, using balances from database');
        }
        // Nothing to sync, just return
        return;
      }
      // Fetch balances from blockchain for all tokens
      final paxAccountContractAddress = account.contractAddress!;
      final updatedBalances = await BlockchainService.fetchAllTokenBalances(
        paxAccountContractAddress,
      );
      // Store balances in local DB
      for (final entry in updatedBalances.entries) {
        await LocalDBHelper().upsertBalance(
          participantId,
          entry.key,
          entry.value as num,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing balances from blockchain: $e');
      }
      rethrow;
    }
  }

  // Fetch single token balance from blockchain or local DB
  Future<double> fetchTokenBalance(String userId, int tokenId) async {
    try {
      // Get current account
      final account = await getAccount(userId);
      if (account == null) {
        throw Exception('Account not found');
      }
      // Check if contract address exists
      if (account.contractAddress == null || account.contractAddress!.isEmpty) {
        if (kDebugMode) {
          print('No contract address found, using balance from local DB');
        }
        final balances = await LocalDBHelper().getBalances(userId);
        return balances[tokenId]?.toDouble() ?? 0.0;
      }
      // Fetch balance from blockchain
      final walletAddress = account.contractAddress!;
      return await BlockchainService.fetchTokenBalance(walletAddress, tokenId);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching token balance: $e');
      }
      return 0.0;
    }
  }
}

// repositories/pax_account_repository.dart - Fixed type casting issues
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/models/firestore/pax_account/pax_account_model.dart';
import 'package:pax/services/blockchain/blockchain_service.dart';

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

      // Create basic account with default balances
      final Map<int, num> defaultBalances = {
        1: 0, // GoodDollar
        2: 0, // Celo Dollar
        3: 0, // Tether USD
        4: 0, // USD Coin
      };

      // Create basic account
      final newAccount = PaxAccount(
        id: userId,
        timeCreated: now,
        timeUpdated: now,
        balances: defaultBalances,
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
  Future<PaxAccount> updateBalance(
    String userId,
    int tokenId, // Changed from String to int to match model
    num amount,
  ) async {
    try {
      // Get current account
      final account = await getAccount(userId);

      if (account == null) {
        throw Exception('Account not found');
      }

      // Update balance for the token
      final updatedBalances = Map<int, num>.from(account.balances);
      updatedBalances[tokenId] = amount;

      // Convert Map<int, num> to Map<String, num> for Firestore
      final firestoreBalances = <String, num>{};
      updatedBalances.forEach((key, value) {
        firestoreBalances[key.toString()] = value;
      });

      // Update account with new balances
      return await updateAccount(userId, {'balances': firestoreBalances});
    } catch (e) {
      if (kDebugMode) {
        print('Error updating balance: $e');
      }
      rethrow;
    }
  }

  // Fetch and sync balances from blockchain
  Future<PaxAccount> syncBalancesFromBlockchain(String userId) async {
    try {
      // Get current account
      final account = await getAccount(userId);

      if (account == null) {
        throw Exception('Account not found');
      }

      // Check if contract address exists
      if (account.contractAddress == null || account.contractAddress!.isEmpty) {
        if (kDebugMode) {
          print('No contract address found, using balances from database');
        }
        return account;
      }

      // Fetch balances from blockchain for all tokens
      final paxAccountContractAddress = account.contractAddress!;
      final updatedBalances = await BlockchainService.fetchAllTokenBalances(
        paxAccountContractAddress,
      );

      // Convert to Firestore format (string keys)
      final firestoreBalances = <String, num>{};
      updatedBalances.forEach((key, value) {
        firestoreBalances[key.toString()] = value as num;
      });

      // Update account with new balances
      return await updateAccount(userId, {'balances': firestoreBalances});
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing balances from blockchain: $e');
      }
      // Return current account without updating if sync fails
      final account = await getAccount(userId);
      return account!;
    }
  }

  // Fetch single token balance from blockchain
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
          print('No contract address found, using balance from database');
        }
        return account.balances[tokenId]?.toDouble() ?? 0.0;
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/models/firestore/fcm_token/fcm_token_model.dart';

class FcmTokenRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'fcm_tokens';

  // Get token by id
  Future<FCMToken?> getTokenById(String id) async {
    try {
      final docSnapshot =
          await _firestore.collection(collectionName).doc(id).get();

      if (docSnapshot.exists) {
        return FCMToken.fromMap(docSnapshot.data()!, id: docSnapshot.id);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token by id: $e');
      }
      rethrow;
    }
  }

  // Get token by participant id
  Future<List<FCMToken>> getAllTokensByParticipantId(
    String participantId,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(collectionName)
              .where('participantId', isEqualTo: participantId)
              .get();

      return querySnapshot.docs
          .map((doc) => FCMToken.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting all FCM tokens by participant id: $e');
      }
      rethrow;
    }
  }

  // Get most recent token by participant id
  Future<FCMToken?> getTokenByParticipantId(String participantId) async {
    try {
      final tokens = await getAllTokensByParticipantId(participantId);

      if (tokens.isEmpty) {
        return null;
      }

      if (tokens.length > 1) {
        if (kDebugMode) {
          print(
            'Warning: Found ${tokens.length} tokens for participant $participantId, using most recent',
          );
        }

        // Sort by timeUpdated (most recent first)
        tokens.sort((a, b) {
          if (a.timeUpdated == null) return 1;
          if (b.timeUpdated == null) return -1;
          return b.timeUpdated!.compareTo(a.timeUpdated!);
        });
      }

      return tokens.first;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token by participant id: $e');
      }
      rethrow;
    }
  }

  // Get all tokens with a specific token value
  Future<List<FCMToken>> getAllTokensByValue(String token) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(collectionName)
              .where('token', isEqualTo: token)
              .get();

      return querySnapshot.docs
          .map((doc) => FCMToken.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting all FCM tokens by value: $e');
      }
      rethrow;
    }
  }

  // Get the most recent token with the given value
  Future<FCMToken?> getTokenByValue(String token) async {
    try {
      final tokens = await getAllTokensByValue(token);

      if (tokens.isEmpty) {
        return null;
      }

      if (tokens.length > 1) {
        if (kDebugMode) {
          print(
            'Warning: Found ${tokens.length} documents with the same token value, using most recent',
          );
        }

        // Sort by timeUpdated (most recent first)
        tokens.sort((a, b) {
          if (a.timeUpdated == null) return 1;
          if (b.timeUpdated == null) return -1;
          return b.timeUpdated!.compareTo(a.timeUpdated!);
        });
      }

      return tokens.first;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token by value: $e');
      }
      rethrow;
    }
  }

  // Save or update token using a two-phase approach to prevent duplicates
  Future<FCMToken> saveToken(String participantId, String token) async {
    try {
      // PHASE 1: Query operations - Find and analyze existing tokens
      if (kDebugMode) {
        print(
          'FCM Token Repository: Starting saveToken for participant $participantId',
        );
      }

      // Get tokens with the exact same value
      final tokensWithSameValue = await getAllTokensByValue(token);

      // Get tokens belonging to this participant
      final participantTokens = await getAllTokensByParticipantId(
        participantId,
      );

      // PHASE 2: Write operations - Apply the appropriate action based on what we found

      // CASE 1: This exact token already exists for this participant
      for (var existingToken in tokensWithSameValue) {
        if (existingToken.participantId == participantId) {
          if (kDebugMode) {
            print(
              'Found exact token match for participant $participantId, no changes needed',
            );
          }
          return existingToken;
        }
      }

      // CASE 2: Token exists but belongs to another participant
      if (tokensWithSameValue.isNotEmpty) {
        final tokenToUpdate = tokensWithSameValue.first;
        if (kDebugMode) {
          print(
            'Token exists for participant ${tokenToUpdate.participantId}, updating ownership to $participantId',
          );
        }

        // Update ownership
        await _firestore
            .collection(collectionName)
            .doc(tokenToUpdate.id)
            .update({
              'participantId': participantId,
              'timeUpdated': FieldValue.serverTimestamp(),
            });

        // Return updated token
        return FCMToken(
          id: tokenToUpdate.id,
          participantId: participantId,
          token: token,
          timeCreated: tokenToUpdate.timeCreated,
          timeUpdated: Timestamp.now(),
        );
      }

      // CASE 3: Participant already has token(s), update the most recent one
      if (participantTokens.isNotEmpty) {
        // Sort by time (most recent first)
        participantTokens.sort((a, b) {
          if (a.timeUpdated == null) return 1;
          if (b.timeUpdated == null) return -1;
          return b.timeUpdated!.compareTo(a.timeUpdated!);
        });

        final mostRecentToken = participantTokens.first;
        if (kDebugMode) {
          print(
            'Participant has existing token(s), updating most recent one with new value',
          );
        }

        // Update token value
        await _firestore
            .collection(collectionName)
            .doc(mostRecentToken.id)
            .update({
              'token': token,
              'timeUpdated': FieldValue.serverTimestamp(),
            });

        // Return updated token
        return FCMToken(
          id: mostRecentToken.id,
          participantId: participantId,
          token: token,
          timeCreated: mostRecentToken.timeCreated,
          timeUpdated: Timestamp.now(),
        );
      }

      // CASE 4: No matching tokens, create a new one
      if (kDebugMode) {
        print(
          'Creating new token for participant $participantId (no existing tokens found)',
        );
      }

      final now = Timestamp.now();
      final newTokenRef = _firestore.collection(collectionName).doc();

      final newToken = FCMToken(
        id: newTokenRef.id,
        participantId: participantId,
        token: token,
        timeCreated: now,
        timeUpdated: now,
      );

      await newTokenRef.set(newToken.toMap());

      if (kDebugMode) {
        print(
          'FCM token saved for participant: $participantId with ID: ${newToken.id}',
        );
      }

      return newToken;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving FCM token: $e');
      }
      rethrow;
    }
  }
}

// repositories/fcm_token_repository.dart - Updated version to prevent duplicates
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/models/firestore/fcm_token/fcm_token_model.dart';

class FcmTokenRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'fcm_tokens';

  // Get token by id
  Future<FcmTokenModel?> getTokenById(String id) async {
    try {
      final docSnapshot =
          await _firestore.collection(collectionName).doc(id).get();

      if (docSnapshot.exists) {
        return FcmTokenModel.fromMap(docSnapshot.data()!, id: docSnapshot.id);
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
  Future<FcmTokenModel?> getTokenByParticipantId(String participantId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(collectionName)
              .where('participantId', isEqualTo: participantId)
              .get();

      // There might be multiple tokens for the same participant due to the bug
      // Return the most recently updated one if multiple exist
      if (querySnapshot.docs.isNotEmpty) {
        if (querySnapshot.docs.length > 1) {
          if (kDebugMode) {
            print(
              'Warning: Found ${querySnapshot.docs.length} tokens for participant $participantId, using most recent',
            );
          }

          // Sort by timeUpdated (most recent first)
          final sortedDocs =
              querySnapshot.docs.toList()..sort((a, b) {
                final timeA = a.data()['timeUpdated'] as Timestamp?;
                final timeB = b.data()['timeUpdated'] as Timestamp?;

                if (timeA == null) return 1;
                if (timeB == null) return -1;

                return timeB.compareTo(timeA);
              });

          // Return the most recent one
          final doc = sortedDocs.first;
          return FcmTokenModel.fromMap(doc.data(), id: doc.id);
        } else {
          // Just one token found, return it
          final doc = querySnapshot.docs.first;
          return FcmTokenModel.fromMap(doc.data(), id: doc.id);
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token by participant id: $e');
      }
      rethrow;
    }
  }

  // Get token by token value
  Future<FcmTokenModel?> getTokenByValue(String token) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(collectionName)
              .where('token', isEqualTo: token)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return FcmTokenModel.fromMap(doc.data(), id: doc.id);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token by value: $e');
      }
      rethrow;
    }
  }

  // Save or update token with deduplication
  Future<FcmTokenModel> saveToken(String participantId, String token) async {
    try {
      // Check if this exact token already exists in the database
      final existingTokenByValue = await getTokenByValue(token);

      if (existingTokenByValue != null) {
        // Check if it belongs to this participant
        if (existingTokenByValue.participantId == participantId) {
          if (kDebugMode) {
            print('Token already exists for this participant');
          }
          return existingTokenByValue;
        } else {
          if (kDebugMode) {
            print(
              'Token exists but for a different participant, updating ownership',
            );
          }
          // Update the token to belong to this participant
          return await updateTokenOwnership(
            existingTokenByValue.id,
            participantId,
          );
        }
      }

      // Check if participant already has any token(s)
      final existingTokenByParticipant = await getTokenByParticipantId(
        participantId,
      );

      if (existingTokenByParticipant != null) {
        // Update existing token with new value
        if (kDebugMode) {
          print('Updating existing token for participant');
        }
        return await updateTokenValue(existingTokenByParticipant.id, token);
      } else {
        // Create new token
        if (kDebugMode) {
          print('Creating new token for participant');
        }
        return await createToken(participantId, token);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving FCM token: $e');
      }
      rethrow;
    }
  }

  // Create a new token
  Future<FcmTokenModel> createToken(String participantId, String token) async {
    try {
      final now = Timestamp.now();

      // Generate a unique ID
      final String id = _firestore.collection(collectionName).doc().id;

      // Create the token document
      final newToken = FcmTokenModel(
        id: id,
        participantId: participantId,
        token: token,
        timeCreated: now,
        timeUpdated: now,
      );

      // Save to Firestore
      await _firestore.collection(collectionName).doc(id).set(newToken.toMap());

      return newToken;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating FCM token: $e');
      }
      rethrow;
    }
  }

  // Update an existing token value
  Future<FcmTokenModel> updateTokenValue(String id, String token) async {
    try {
      // Update in Firestore
      await _firestore.collection(collectionName).doc(id).update({
        'token': token,
        'timeUpdated': FieldValue.serverTimestamp(),
      });

      // Get the updated record
      final updatedDoc =
          await _firestore.collection(collectionName).doc(id).get();

      return FcmTokenModel.fromMap(updatedDoc.data()!, id: updatedDoc.id);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating FCM token value: $e');
      }
      rethrow;
    }
  }

  // Update token ownership (change participant ID)
  Future<FcmTokenModel> updateTokenOwnership(
    String id,
    String participantId,
  ) async {
    try {
      // Update in Firestore
      await _firestore.collection(collectionName).doc(id).update({
        'participantId': participantId,
        'timeUpdated': FieldValue.serverTimestamp(),
      });

      // Get the updated record
      final updatedDoc =
          await _firestore.collection(collectionName).doc(id).get();

      return FcmTokenModel.fromMap(updatedDoc.data()!, id: updatedDoc.id);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating FCM token ownership: $e');
      }
      rethrow;
    }
  }

  // Delete a token
  Future<void> deleteToken(String id) async {
    try {
      await _firestore.collection(collectionName).doc(id).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting FCM token: $e');
      }
      rethrow;
    }
  }
}

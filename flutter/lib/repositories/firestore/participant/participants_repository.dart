import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/models/auth/auth_user_model.dart';
import 'package:pax/models/firestore/participant/participant_model.dart';

class ParticipantsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'participants';

  // Check if a participant record exists for the given user ID
  Future<bool> participantExists(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection(collectionName).doc(userId).get();

      return docSnapshot.exists;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if participant exists: $e');
      }
      rethrow;
    }
  }

  // Get a participant record by user ID
  Future<Participant?> getParticipant(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection(collectionName).doc(userId).get();

      if (docSnapshot.exists) {
        return Participant.fromMap(docSnapshot.data()!, id: docSnapshot.id);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting participant: $e');
      }
      rethrow;
    }
  }

  // Create a new participant record from user auth data
  Future<Participant> createParticipant(AuthUser user) async {
    try {
      final now = Timestamp.now();

      // Create a basic participant from auth data
      final newParticipant = Participant(
        id: user.uid,
        displayName: user.displayName,
        emailAddress: user.email,
        profilePictureURI: user.photoURL,
        timeCreated: now,
        timeUpdated: now,
      );

      // Save to Firestore
      await _firestore
          .collection(collectionName)
          .doc(user.uid)
          .set(newParticipant.toMap());

      return newParticipant;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating participant: $e');
      }
      rethrow;
    }
  }

  // Update an existing participant record
  Future<Participant> updateParticipant(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Add timestamp and updater info
      final updateData = {...data, 'timeUpdated': FieldValue.serverTimestamp()};

      // Update in Firestore
      await _firestore
          .collection(collectionName)
          .doc(userId)
          .update(updateData);

      // Get the updated record
      final updatedDoc =
          await _firestore.collection(collectionName).doc(userId).get();

      return Participant.fromMap(updatedDoc.data()!, id: updatedDoc.id);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating participant: $e');
      }
      rethrow;
    }
  }

  // Handle a user sign-in - check if participant exists, create if not
  Future<Participant> handleUserSignIn(AuthUser user) async {
    try {
      final exists = await participantExists(user.uid);

      if (exists) {
        // Participant exists, get their record
        final participant = await getParticipant(user.uid);

        // Update any changed information from auth (if needed)
        final needsUpdate = _checkIfAuthDataChanged(participant!, user);

        if (needsUpdate) {
          return await updateParticipant(user.uid, {
            'displayName': user.displayName,
            'emailAddress': user.email,
            'profilePictureURI': user.photoURL,
          });
        }

        return participant;
      } else {
        // Create new participant
        return await createParticipant(user);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling user sign in: $e');
      }
      rethrow;
    }
  }

  // Check if auth data has changed and participant needs update
  bool _checkIfAuthDataChanged(Participant participant, AuthUser user) {
    return participant.displayName != user.displayName ||
        participant.emailAddress != user.email ||
        participant.profilePictureURI != user.photoURL;
  }
}

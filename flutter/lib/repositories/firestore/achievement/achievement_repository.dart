import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/models/firestore/achievement/achievement_model.dart';

class AchievementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'achievements';

  // Create a new achievement
  Future<Achievement> createAchievement({
    required String participantId,
    required String name,
    required int tasksNeededForCompletion,
    required int tasksCompleted,
    Timestamp? timeCreated,
    Timestamp? timeCompleted,
    num? amountEarned,
  }) async {
    try {
      // Check if an achievement with the same participantId and name already exists
      final existingAchievements =
          await _firestore
              .collection(collectionName)
              .where('participantId', isEqualTo: participantId)
              .where('name', isEqualTo: name)
              .get();

      if (existingAchievements.docs.isNotEmpty) {
        // Return the existing achievement instead of creating a new one
        return Achievement.fromFirestore(existingAchievements.docs.first);
      }

      final achievement = Achievement(
        id: _firestore.collection(collectionName).doc().id,
        participantId: participantId,
        name: name,
        tasksNeededForCompletion: tasksNeededForCompletion,
        tasksCompleted: tasksCompleted,
        timeCreated: timeCreated,
        timeCompleted: timeCompleted,
        amountEarned: amountEarned,
      );

      await _firestore
          .collection(collectionName)
          .doc(achievement.id)
          .set(achievement.toMap());

      return achievement;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating achievement: $e');
      }
      rethrow;
    }
  }

  // Get achievements for a participant
  Future<List<Achievement>> getAchievementsForParticipant(
    String participantId,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(collectionName)
              .where('participantId', isEqualTo: participantId)
              .get();

      return querySnapshot.docs
          .map((doc) => Achievement.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting achievements: $e');
      }
      rethrow;
    }
  }

  // Update an achievement
  Future<Achievement> updateAchievement(
    String achievementId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(achievementId)
          .update(data);

      final doc =
          await _firestore.collection(collectionName).doc(achievementId).get();

      return Achievement.fromFirestore(doc);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating achievement: $e');
      }
      rethrow;
    }
  }
}

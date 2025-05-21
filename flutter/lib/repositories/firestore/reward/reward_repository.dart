// lib/repositories/reward/reward_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/models/firestore/reward/reward_model.dart';

class RewardRepository {
  final FirebaseFirestore _firestore;
  final String collectionName = 'rewards';

  RewardRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get rewards for a participant
  Future<List<Reward>> getRewardsForParticipant(String participantId) async {
    try {
      final snapshot =
          await _firestore
              .collection(collectionName)
              .where('participantId', isEqualTo: participantId)
              .orderBy('timeCreated', descending: true)
              .get();

      return snapshot.docs.map((doc) => Reward.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting rewards: $e');
      }
      // Return empty list on error
      return [];
    }
  }

  // Get a specific reward by ID
  Future<Reward?> getReward(String id) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(id).get();

      if (doc.exists) {
        return Reward.fromFirestore(doc);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting reward: $e');
      }
      rethrow;
    }
  }

  // Get rewards for a specific task
  Future<List<Reward>> getRewardsForTask(String taskId) async {
    try {
      final snapshot =
          await _firestore
              .collection(collectionName)
              .where('taskId', isEqualTo: taskId)
              .orderBy('timeCreated', descending: true)
              .get();

      return snapshot.docs.map((doc) => Reward.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting rewards for task: $e');
      }
      // Return empty list on error
      return [];
    }
  }

  // Get rewards for a specific task completion
  Future<List<Reward>> getRewardsForTaskCompletion(
    String taskCompletionId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection(collectionName)
              .where('taskCompletionId', isEqualTo: taskCompletionId)
              .orderBy('timeCreated', descending: true)
              .get();

      return snapshot.docs.map((doc) => Reward.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting rewards for task completion: $e');
      }
      // Return empty list on error
      return [];
    }
  }

  // Stream of rewards for a participant
  Stream<List<Reward>> streamRewardsForParticipant(String? participantId) {
    if (participantId == null) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection(collectionName)
          .where('participantId', isEqualTo: participantId)
          .orderBy('timeCreated', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Reward.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      if (kDebugMode) {
        print('Error streaming rewards: $e');
      }
      // Return empty stream on error
      return Stream.value([]);
    }
  }
}

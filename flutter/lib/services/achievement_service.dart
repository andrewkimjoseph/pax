import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pax/models/firestore/achievement/achievement_model.dart';

class AchievementService {
  final FirebaseFunctions _functions;
  final _firestore = FirebaseFirestore.instance;

  AchievementService({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  Future<void> createPayoutConnectorAchievement(String participantId) async {
    await _createAchievement(
      participantId: participantId,
      name: 'Payout Connector',
      tasksNeededForCompletion: 1,
      tasksCompleted: 1,
      timeCompleted: Timestamp.now(),
      amountEarned: 1000,
    );
  }

  Future<void> createVerifiedHumanAchievement(String participantId) async {
    await _createAchievement(
      participantId: participantId,
      name: 'Verified Human',
      tasksNeededForCompletion: 1,
      tasksCompleted: 1,
      timeCompleted: Timestamp.now(),
      amountEarned: 1000,
    );
  }

  Future<void> createProfilePerfectionistAchievement(
    String participantId,
  ) async {
    await _createAchievement(
      participantId: participantId,
      name: 'Profile Perfectionist',
      tasksNeededForCompletion: 1,
      tasksCompleted: 1,
      timeCompleted: Timestamp.now(),
      amountEarned: 500,
    );
  }

  Future<void> createTaskStarterAchievement(String participantId) async {
    await _createAchievement(
      participantId: participantId,
      name: 'Task Starter',
      tasksNeededForCompletion: 1,
      tasksCompleted: 1,
      timeCompleted: Timestamp.now(),
      amountEarned: 500,
    );
  }

  Future<void> createTaskExpertAchievement(String participantId) async {
    await _createAchievement(
      participantId: participantId,
      name: 'Task Expert',
      tasksNeededForCompletion: 10,
      tasksCompleted: 1, // They just completed their first task
      timeCreated: Timestamp.now(),
    );
  }

  Future<void> _createAchievement({
    required String participantId,
    required String name,
    required int tasksNeededForCompletion,
    required int tasksCompleted,
    Timestamp? timeCreated,
    Timestamp? timeCompleted,
    num? amountEarned,
  }) async {
    final achievement = Achievement(
      id: _firestore.collection('achievements').doc().id,
      participantId: participantId,
      name: name,
      tasksNeededForCompletion: tasksNeededForCompletion,
      tasksCompleted: tasksCompleted,
      timeCreated: timeCreated,
      timeCompleted: timeCompleted,
      amountEarned: amountEarned,
    );

    await _firestore
        .collection('achievements')
        .doc(achievement.id)
        .set(achievement.toMap());
  }

  //  achievementId,
  //   paxAccountContractAddress,
  //   amountEarned,
  //   tasksCompleted

  Future<String> processAchievementClaim({
    required String achievementId,
    required String paxAccountContractAddress,
    required num amountEarned,
    required int tasksCompleted,
  }) async {
    try {
      final result = await _functions
          .httpsCallable('processAchievementClaim')
          .call({
            'achievementId': achievementId,
            'paxAccountContractAddress': paxAccountContractAddress,
            'amountEarned': amountEarned,
            'tasksCompleted': tasksCompleted,
          });

      final txnHash = result.data['txnHash'] as String;

      // Update the achievement with the transaction hash
      await _firestore.collection('achievements').doc(achievementId).update({
        'txnHash': txnHash,
      });

      return txnHash;
    } catch (e) {
      throw Exception('Failed to process achievement claim: $e');
    }
  }
}

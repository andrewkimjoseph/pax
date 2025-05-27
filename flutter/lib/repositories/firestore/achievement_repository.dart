import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pax/models/firestore/achievement/achievement_model.dart';

class AchievementRepository {
  final FirebaseFirestore _firestore;

  AchievementRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _achievementsCollection =>
      _firestore.collection('achievements');

  Future<List<Achievement>> getAchievements(String participantId) async {
    final snapshot =
        await _achievementsCollection
            .where('participantId', isEqualTo: participantId)
            .get();

    return snapshot.docs.map((doc) => Achievement.fromFirestore(doc)).toList();
  }

  Future<Achievement> createAchievement({
    required String participantId,
    required String name,
    required int tasksCompleted,
    required int tasksNeededForCompletion,
  }) async {
    final docRef = _achievementsCollection.doc();
    final achievement = Achievement(
      id: docRef.id,
      participantId: participantId,
      name: name,
      tasksCompleted: tasksCompleted,
      tasksNeededForCompletion: tasksNeededForCompletion,
      timeCreated: Timestamp.now(),
      timeCompleted:
          tasksCompleted >= tasksNeededForCompletion ? Timestamp.now() : null,
    );

    await docRef.set(achievement.toMap());
    return achievement;
  }

  Future<void> updateAchievement(Achievement achievement) async {
    await _achievementsCollection
        .doc(achievement.id)
        .update(achievement.toMap());
  }
}

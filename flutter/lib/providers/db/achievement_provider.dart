import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/firestore/achievement/achievement_model.dart';
import 'package:pax/repositories/firestore/achievement_repository.dart';

class AchievementNotifier extends Notifier<AsyncValue<List<Achievement>>> {
  @override
  AsyncValue<List<Achievement>> build() {
    return const AsyncValue.loading();
  }

  Future<void> loadAchievements(String participantId) async {
    try {
      state = const AsyncValue.loading();
      final achievements = await ref
          .read(achievementRepositoryProvider)
          .getAchievements(participantId);
      state = AsyncValue.data(achievements);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createAchievement({
    required String participantId,
    required String name,
    required int tasksCompleted,
    required int tasksNeededForCompletion,
  }) async {
    try {
      final achievement = await ref
          .read(achievementRepositoryProvider)
          .createAchievement(
            participantId: participantId,
            name: name,
            tasksCompleted: tasksCompleted,
            tasksNeededForCompletion: tasksNeededForCompletion,
          );

      state.whenData((achievements) {
        state = AsyncValue.data([...achievements, achievement]);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateAchievement(Achievement achievement) async {
    try {
      await ref
          .read(achievementRepositoryProvider)
          .updateAchievement(achievement);

      state.whenData((achievements) {
        final index = achievements.indexWhere((a) => a.id == achievement.id);
        if (index != -1) {
          final updatedAchievements = [...achievements];
          updatedAchievements[index] = achievement;
          state = AsyncValue.data(updatedAchievements);
        }
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return AchievementRepository();
});

final achievementProvider =
    NotifierProvider<AchievementNotifier, AsyncValue<List<Achievement>>>(
      AchievementNotifier.new,
    );

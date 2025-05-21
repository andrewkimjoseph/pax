// lib/providers/activity/activity_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/firestore/reward/reward_model.dart';
import 'package:pax/models/local/activity_model.dart';
import 'package:pax/repositories/firestore/reward/reward_repository.dart';
import 'package:pax/repositories/firestore/task_completion/task_completion_repository.dart';
import 'package:pax/repositories/firestore/withdrawal/withdrawal_repository.dart';
import 'package:pax/repositories/local/activity_repository.dart';

import '../auth/auth_provider.dart';

// Provider for repositories
final taskCompletionRepositoryProvider = Provider<TaskCompletionRepository>((
  ref,
) {
  return TaskCompletionRepository();
});

final rewardRepositoryProvider = Provider<RewardRepository>((ref) {
  return RewardRepository();
});

final withdrawalRepositoryProvider = Provider<WithdrawalRepository>((ref) {
  return WithdrawalRepository();
});

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final taskCompletionRepo = ref.watch(taskCompletionRepositoryProvider);
  final rewardRepo = ref.watch(rewardRepositoryProvider);
  final withdrawalRepo = ref.watch(withdrawalRepositoryProvider);

  return ActivityRepository(
    taskCompletionRepository: taskCompletionRepo,
    rewardRepository: rewardRepo,
    withdrawalRepository: withdrawalRepo,
  );
});

// Future providers for activities
final allActivitiesProvider = FutureProvider.family<List<Activity>, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.getAllActivitiesForParticipant(userId);
});

final taskCompletionActivitiesProvider =
    FutureProvider.family<List<Activity>, String>((ref, userId) async {
      final repository = ref.watch(activityRepositoryProvider);
      return repository.getTaskCompletionActivitiesForParticipant(userId);
    });

final rewardActivitiesProvider = FutureProvider.family<List<Activity>, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.getRewardActivitiesForParticipant(userId);
});

// Define a rewards provider that will expose the stream of rewards
final rewardsStreamProvider = StreamProvider.family<List<Reward>, String?>((
  ref,
  participantId,
) {
  // Use the rewards repository to get the stream of rewards for the participant
  final rewardsRepository = ref.watch(rewardRepositoryProvider);
  return rewardsRepository.streamRewardsForParticipant(participantId);
});

final withdrawalActivitiesProvider =
    FutureProvider.family<List<Activity>, String>((ref, userId) async {
      final repository = ref.watch(activityRepositoryProvider);
      return repository.getWithdrawalActivitiesForParticipant(userId);
    });

// Activity state class
class ActivityState {
  final List<Activity> activities;
  final bool isLoading;
  final String? errorMessage;
  final ActivityType? filterType;

  ActivityState({
    this.activities = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filterType,
  });

  ActivityState copyWith({
    List<Activity>? activities,
    bool? isLoading,
    String? errorMessage,
    ActivityType? filterType,
  }) {
    return ActivityState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      filterType: filterType ?? this.filterType,
    );
  }
}

// Activity notifier using Riverpod's Notifier
class ActivityNotifier extends Notifier<ActivityState> {
  @override
  ActivityState build() {
    // Initialize with TaskCompletion as the default filter type
    return ActivityState(
      isLoading: false,
      // Set default filter here
      filterType: ActivityType.taskCompletion,
    );
  }

  // Set filter type
  void setFilterType(ActivityType? filterType) {
    state = state.copyWith(filterType: filterType);
  }

  // Load activities
  Future<void> loadActivities(String userId) async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(activityRepositoryProvider);
      final activities = await repository.getAllActivitiesForParticipant(
        userId,
      );

      state = state.copyWith(
        activities: activities,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load activities: $e',
      );
    }
  }
}

// Provider for ActivityNotifier
final activityNotifierProvider =
    NotifierProvider<ActivityNotifier, ActivityState>(() {
      return ActivityNotifier();
    });

// UPDATED: Provider for filtered activities based on the current filter
final filteredActivitiesProvider = Provider<AsyncValue<List<Activity>>>((ref) {
  final activityState = ref.watch(activityNotifierProvider);
  final filterType = activityState.filterType;
  final userId = ref.watch(authProvider).user.uid;

  if (kDebugMode) {
    print("Current filter type: $filterType");
  }

  // Use specific activity providers based on filter type
  switch (filterType) {
    case ActivityType.taskCompletion:
      if (kDebugMode) {
        print("Using task completion provider");
      }
      return ref.watch(taskCompletionActivitiesProvider(userId));
    case ActivityType.reward:
      if (kDebugMode) {
        print("Using reward provider");
      }
      return ref.watch(rewardActivitiesProvider(userId));
    case ActivityType.withdrawal:
      if (kDebugMode) {
        print("Using withdrawal provider");
      }
      return ref.watch(withdrawalActivitiesProvider(userId));
    case null:
      if (kDebugMode) {
        print("No filter type set, using all activities provider");
      }
      return ref.watch(allActivitiesProvider(userId));
  }
});

// Provider for total number of Task Completions
final totalTaskCompletionsProvider = Provider<AsyncValue<int>>((ref) {
  final userId = ref.watch(authProvider).user.uid;
  final tasksAsync = ref.watch(taskCompletionActivitiesProvider(userId));

  return tasksAsync.when(
    data: (tasks) => AsyncValue.data(tasks.length),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Provider for total G$ tokens earned
final totalGoodDollarTokensEarnedProvider = Provider<AsyncValue<double>>((ref) {
  final userId = ref.watch(authProvider).user.uid;
  final rewardsAsync = ref.watch(rewardActivitiesProvider(userId));

  return rewardsAsync.when(
    data: (rewards) {
      double total = 0.0;
      for (final activity in rewards) {
        if (activity.type == ActivityType.reward &&
            activity.reward?.rewardCurrencyId == 1 &&
            activity.reward?.amountReceived != null) {
          total += activity.reward!.amountReceived!.toDouble();
        }
      }
      return AsyncValue.data(total);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

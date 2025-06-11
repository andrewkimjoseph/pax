// lib/views/activity/activity_view.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/local/activity_model.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';

import 'package:pax/providers/local/activity_providers.dart';
import 'package:pax/widgets/activity/activity_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../theming/colors.dart' show PaxColors;
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/providers/remote_config/remote_config_provider.dart';

class ActivityView extends ConsumerStatefulWidget {
  const ActivityView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ActivityViewState();
}

class _ActivityViewState extends ConsumerState<ActivityView> {
  int get selectedIndex {
    final filterType = ref.watch(activityNotifierProvider).filterType;
    switch (filterType) {
      case ActivityType.taskCompletion:
        return 0;
      case ActivityType.reward:
        return 1;
      case ActivityType.withdrawal:
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the activity notifier to set filters
    final activityNotifier = ref.watch(activityNotifierProvider.notifier);

    // Get the userId
    final userId = ref.watch(authProvider).user.uid;

    // Watch for activities based on the current filter
    final activitiesAsync = ref.watch(filteredActivitiesProvider);
    // Watch for all activities (unfiltered)
    final allActivitiesAsync = ref.watch(allActivitiesProvider(userId));
    // Watch feature flags
    final featureFlags = ref.watch(featureFlagsProvider);

    return Scaffold(
      headers: [
        AppBar(
          height: 87.5,
          padding: EdgeInsets.all(8),
          backgroundColor: PaxColors.white,
          header: Row(
            children: [
              Text(
                'Activity',
                style: Theme.of(context).typography.base.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  color: PaxColors.black,
                ),
              ),
            ],
          ).withPadding(bottom: 8),
          subtitle: featureFlags.when(
            data: (flags) {
              final showTaskCompletions =
                  flags['are_tasks_completions_available'] == true;
              return Row(
                children: [
                  if (showTaskCompletions)
                    Button(
                      style: const ButtonStyle.primary(
                            density: ButtonDensity.dense,
                          )
                          .withBackgroundColor(
                            color:
                                selectedIndex == 0
                                    ? PaxColors.deepPurple
                                    : Colors.transparent,
                          )
                          .withBorder(
                            border: Border.all(
                              color:
                                  selectedIndex == 0
                                      ? PaxColors.deepPurple
                                      : PaxColors.lilac,
                              width: 2,
                            ),
                          )
                          .withBorderRadius(
                            borderRadius: BorderRadius.circular(7),
                          ),
                      onPressed: () {
                        activityNotifier.setFilterType(
                          ActivityType.taskCompletion,
                        );
                        ref.read(analyticsProvider).taskCompletionsTapped();
                      },
                      child: Text(
                        'Task Completions',
                        style: TextStyle(
                          color:
                              selectedIndex == 0
                                  ? PaxColors.white
                                  : PaxColors.black,
                        ),
                      ),
                    ).withPadding(right: 8),

                  Button(
                    style: const ButtonStyle.primary(
                          density: ButtonDensity.dense,
                        )
                        .withBackgroundColor(
                          color:
                              selectedIndex == 1
                                  ? PaxColors.deepPurple
                                  : Colors.transparent,
                        )
                        .withBorder(
                          border: Border.all(
                            color:
                                selectedIndex == 1
                                    ? PaxColors.deepPurple
                                    : PaxColors.lilac,
                            width: 2,
                          ),
                        )
                        .withBorderRadius(
                          borderRadius: BorderRadius.circular(7),
                        ),
                    onPressed: () {
                      activityNotifier.setFilterType(ActivityType.reward);
                      ref.read(analyticsProvider).rewardsTapped();
                    },
                    child: Text(
                      'Rewards',
                      style: TextStyle(
                        color:
                            selectedIndex == 1
                                ? PaxColors.white
                                : PaxColors.black,
                      ),
                    ),
                  ).withPadding(right: 8),

                  Button(
                    style: const ButtonStyle.primary(
                          density: ButtonDensity.dense,
                        )
                        .withBackgroundColor(
                          color:
                              selectedIndex == 2
                                  ? PaxColors.deepPurple
                                  : Colors.transparent,
                        )
                        .withBorder(
                          border: Border.all(
                            color:
                                selectedIndex == 2
                                    ? PaxColors.deepPurple
                                    : PaxColors.lilac,
                            width: 2,
                          ),
                        )
                        .withBorderRadius(
                          borderRadius: BorderRadius.circular(7),
                        ),
                    onPressed: () {
                      activityNotifier.setFilterType(ActivityType.withdrawal);
                      ref.read(analyticsProvider).withdrawalsTapped();
                    },
                    child: Text(
                      'Withdrawals',
                      style: TextStyle(
                        color:
                            selectedIndex == 2
                                ? PaxColors.white
                                : PaxColors.black,
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),
        Divider(color: PaxColors.lightGrey),
      ],

      child: featureFlags.when(
        data: (flags) {
          final showTaskCompletions =
              flags['are_tasks_completions_available'] == true;
          // If the selected index is 0 (Task Completions) but the flag is false, show nothing
          if (selectedIndex == 0 && !showTaskCompletions) {
            return const SizedBox.shrink();
          }
          return activitiesAsync.when(
            skipLoadingOnRefresh: false,
            data: (activities) {
              return allActivitiesAsync.when(
                data: (allActivities) {
                  return SingleChildScrollView(
                    child: Builder(
                      builder: (context) {
                        if (activities.isEmpty) {
                          return SizedBox(
                            height:
                                MediaQuery.of(context).size.height /
                                2, // Account for header height
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    selectedIndex == 0
                                        ? 'No task completions'
                                        : selectedIndex == 1
                                        ? 'No rewards'
                                        : 'No withdrawals',
                                    style: TextStyle(color: PaxColors.darkGrey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: [
                            for (var activity in activities)
                              ActivityCard(
                                activity,
                                allActivities: allActivities,
                              ).withPadding(all: 8),
                          ],
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error loading all activities',
                            style: TextStyle(color: PaxColors.darkGrey),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error loading activities',
                        style: TextStyle(color: PaxColors.darkGrey),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading feature flags',
                    style: TextStyle(color: PaxColors.darkGrey),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
      ),
    );
  }
}

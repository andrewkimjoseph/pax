// lib/views/activity/activity_view.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/models/local/activity_model.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';

import 'package:pax/providers/local/activity_providers.dart';
import 'package:pax/widgets/activity/activity_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../theming/colors.dart' show PaxColors;

class ActivityView extends ConsumerStatefulWidget {
  const ActivityView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ActivityViewState();
}

class _ActivityViewState extends ConsumerState<ActivityView> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    // Initialize activities on startup
  }

  @override
  Widget build(BuildContext context) {
    // Get the activity notifier to set filters
    final activityNotifier = ref.watch(activityNotifierProvider.notifier);

    // Watch for activities based on the current filter
    final activitiesAsync = ref.watch(filteredActivitiesProvider);

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
          subtitle: Row(
            children: [
              Button(
                style: const ButtonStyle.primary(density: ButtonDensity.dense)
                    .withBackgroundColor(
                      color:
                          index == 0
                              ? PaxColors.deepPurple
                              : Colors.transparent,
                    )
                    .withBorder(
                      border: Border.all(
                        color:
                            index == 0 ? PaxColors.deepPurple : PaxColors.lilac,
                        width: 2,
                      ),
                    )
                    .withBorderRadius(borderRadius: BorderRadius.circular(7)),
                onPressed: () {
                  setState(() {
                    index = 0;
                  });
                  activityNotifier.setFilterType(ActivityType.taskCompletion);
                  ref.read(analyticsProvider).taskCompletionsTapped();
                },
                child: Text(
                  'Task Completions',
                  style: TextStyle(
                    color: index == 0 ? PaxColors.white : PaxColors.black,
                  ),
                ),
              ).withPadding(right: 8),

              Button(
                style: const ButtonStyle.primary(density: ButtonDensity.dense)
                    .withBackgroundColor(
                      color:
                          index == 1
                              ? PaxColors.deepPurple
                              : Colors.transparent,
                    )
                    .withBorder(
                      border: Border.all(
                        color:
                            index == 1 ? PaxColors.deepPurple : PaxColors.lilac,
                        width: 2,
                      ),
                    )
                    .withBorderRadius(borderRadius: BorderRadius.circular(7)),
                onPressed: () {
                  setState(() {
                    index = 1;
                  });
                  activityNotifier.setFilterType(ActivityType.reward);
                  ref.read(analyticsProvider).rewardsTapped();
                },
                child: Text(
                  'Rewards',
                  style: TextStyle(
                    color: index == 1 ? PaxColors.white : PaxColors.black,
                  ),
                ),
              ).withPadding(right: 8),

              Button(
                style: const ButtonStyle.primary(density: ButtonDensity.dense)
                    .withBackgroundColor(
                      color:
                          index == 2
                              ? PaxColors.deepPurple
                              : Colors.transparent,
                    )
                    .withBorder(
                      border: Border.all(
                        color:
                            index == 2 ? PaxColors.deepPurple : PaxColors.lilac,
                        width: 2,
                      ),
                    )
                    .withBorderRadius(borderRadius: BorderRadius.circular(7)),
                onPressed: () {
                  setState(() {
                    index = 2;
                  });
                  activityNotifier.setFilterType(ActivityType.withdrawal);
                  ref.read(analyticsProvider).withdrawalsTapped();
                },
                child: Text(
                  'Withdrawals',
                  style: TextStyle(
                    color: index == 2 ? PaxColors.white : PaxColors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(color: PaxColors.lightGrey),
      ],

      child: activitiesAsync.when(
        skipLoadingOnRefresh: false,
        data: (activities) {
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
                            index == 0
                                ? 'No task completions'
                                : index == 1
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
                      ActivityCard(activity).withPadding(all: 8),
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
                    'Error loading activities',
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

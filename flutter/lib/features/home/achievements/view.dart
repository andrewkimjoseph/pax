import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/widgets/achievement/achievement_card.dart';
import 'package:pax/providers/db/achievement_provider.dart';
import 'package:pax/models/firestore/achievement/achievement_model.dart';
import 'package:pax/widgets/achievement/filter_button.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class AchievementsView extends ConsumerStatefulWidget {
  const AchievementsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AchievementsViewState();
}

class _AchievementsViewState extends ConsumerState<AchievementsView> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    // Load achievements when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final participantId = ref.read(authProvider).user.uid;
      ref.read(achievementProvider.notifier).loadAchievements(participantId);
    });
  }

  List<Achievement> _filterAchievements(List<Achievement> achievements) {
    switch (index) {
      case 0: // All
        return achievements;
      case 1: // Earned
        return achievements
            .where((a) => a.status == AchievementStatus.earned)
            .toList();
      case 2: // In Progress
        return achievements
            .where((a) => a.status == AchievementStatus.inProgress)
            .toList();
      case 3: // Claimed
        return achievements
            .where((a) => a.status == AchievementStatus.claimed)
            .toList();
      default:
        return achievements;
    }
  }

  @override
  Widget build(BuildContext context) {
    final achievementsAsync = ref.watch(achievementProvider);

    return Scaffold(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: PaxColors.white,
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: PaxColors.lightGrey,
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(7),
                        topRight: Radius.circular(7),
                      ),
                      gradient: LinearGradient(
                        colors: PaxColors.orangeToPinkGradient,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Canvassing GoodDollar Points",
                            style: TextStyle(
                              fontSize: 16,
                              color: PaxColors.deepPurple,
                            ),
                          ),
                        ],
                      ).withPadding(bottom: 8),
                      Row(
                        children: [
                          Text(
                            "Earn G\$ token points every time you complete surveys, tasks or reach certain milestones. These points are added to your GoodDollar balance and can be withdrawn at any time.",
                            style: TextStyle(
                              fontSize: 14,
                              color: PaxColors.black,
                            ),
                          ).expanded(),
                        ],
                      ),
                    ],
                  ).withPadding(all: 8),
                ],
              ),
            ).withPadding(bottom: 8),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: PaxColors.deepPurple, width: 0.1),
                borderRadius: BorderRadius.circular(7),
              ),
              padding: EdgeInsets.all(7),
              child: Row(
                children: [
                  FilterButton(
                    label: 'All',
                    isSelected: index == 0,
                    onPressed: () => setState(() => index = 0),
                  ),
                  FilterButton(
                    label: 'In Progress',
                    isSelected: index == 2,
                    onPressed: () => setState(() => index = 2),
                  ),
                  FilterButton(
                    label: 'Earned',
                    isSelected: index == 1,
                    onPressed: () => setState(() => index = 1),
                  ),
                  FilterButton(
                    label: 'Claimed',
                    isSelected: index == 3,
                    onPressed: () => setState(() => index = 3),
                  ),
                ],
              ),
            ).withPadding(bottom: 8),

            achievementsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (achievements) {
                final filteredAchievements = _filterAchievements(achievements);

                if (filteredAchievements.isEmpty) {
                  return SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        index == 0
                            ? 'No achievements yet'
                            : 'No ${index == 1
                                ? 'earned'
                                : index == 2
                                ? 'in progress'
                                : 'claimed'} achievements',
                        style: TextStyle(fontSize: 16, color: PaxColors.black),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    children:
                        filteredAchievements.map((achievement) {
                          return AchievementCard(
                            achievement: achievement,
                          ).withPadding(bottom: 8);
                        }).toList(),
                  ),
                );
              },
            ),
          ],
        ).withPadding(all: 8),
      ),
    );
  }
}

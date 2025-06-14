import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/db/achievement/achievement_provider.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/widgets/achievement/achievement_card.dart';
import 'package:pax/models/firestore/achievement/achievement_model.dart';
import 'package:pax/models/firestore/participant/participant_model.dart';
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

  bool _isProfileComplete(Participant? participant) {
    if (participant == null) return false;
    return participant.displayName != null &&
        participant.gender != null &&
        participant.country != null &&
        participant.dateOfBirth != null;
  }

  @override
  Widget build(BuildContext context) {
    final achievementState = ref.watch(achievementProvider);
    final participant = ref.watch(participantProvider).participant;
    final isProfileComplete = _isProfileComplete(participant);

    return Scaffold(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 130,
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
                    height: 20,
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
                            "Earn G\$ tokens by completing tasks and reaching milestones. The tokens are added to your GoodDollar balance and can be withdrawn anytime.",
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

            if (!isProfileComplete)
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Complete your profile by adding your phone number, gender and date of birth to see your achievements.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: PaxColors.black),
                  ).withPadding(all: 16),
                ),
              )
            else if (achievementState.state == AchievementState.loading)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator()],
              ).sized(height: 200, width: double.infinity)
            else if (achievementState.state == AchievementState.error)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('Error: ${achievementState.errorMessage}')],
              ).sized(height: 200, width: double.infinity)
            else
              Column(
                children: [
                  if (filterAchievements(achievementState.achievements).isEmpty)
                    Center(
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
                    ).sized(height: 200, width: double.infinity)
                  else
                    ...filterAchievements(achievementState.achievements).map(
                      (achievement) => AchievementCard(
                        achievement: achievement,
                      ).withPadding(bottom: 8),
                    ),
                ],
              ),
          ],
        ).withPadding(all: 8),
      ),
    );
  }

  List<Achievement> filterAchievements(List<Achievement> achievements) {
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
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/widgets/achievement/achievement_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class AchievementsView extends ConsumerStatefulWidget {
  const AchievementsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AchievementsViewState();
}

class _AchievementsViewState extends ConsumerState<AchievementsView> {
  String? selectedValue;
  int index = 0;

  String? screenName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: PaxColors.white,
                borderRadius: BorderRadius.circular(7),
                // border: Border.all(color: PaxColors.deepPurple, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: PaxColors.lightGrey,
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 1), // changes position of shadow
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
                  Button(
                    style: const ButtonStyle.primary(
                          density: ButtonDensity.dense,
                        )
                        .withBackgroundColor(
                          color:
                              index == 0
                                  ? PaxColors.deepPurple
                                  : Colors.transparent,
                        )
                        .withBorder(
                          border: Border.all(
                            color:
                                index == 0
                                    ? PaxColors.deepPurple
                                    : PaxColors.lilac,
                            width: 2,
                          ),
                        )
                        .withBorderRadius(
                          borderRadius: BorderRadius.circular(7),
                        ),
                    onPressed: () {
                      setState(() {
                        screenName = 'Dashboard';
                        index = 0;
                      });
                    },

                    child: Text(
                      'All',
                      style: TextStyle(
                        color: index == 0 ? PaxColors.white : PaxColors.black,
                      ),
                    ),
                  ).withPadding(right: 8),
                  Button(
                    style: const ButtonStyle.primary(
                          density: ButtonDensity.dense,
                        )
                        .withBackgroundColor(
                          color:
                              index == 2
                                  ? PaxColors.deepPurple
                                  : Colors.transparent,
                        )
                        .withBorder(
                          border: Border.all(
                            color:
                                index == 2
                                    ? PaxColors.deepPurple
                                    : PaxColors.lilac,
                            width: 2,
                          ),
                        )
                        .withBorderRadius(
                          borderRadius: BorderRadius.circular(7),
                        ),
                    onPressed: () {
                      setState(() {
                        screenName = 'Achievements';
                        index = 2;
                      });
                    },

                    child: Text(
                      'In Progress',
                      style: TextStyle(
                        color: index == 2 ? PaxColors.white : PaxColors.black,
                      ),
                    ),
                  ).withPadding(right: 8),
                  Button(
                    style: const ButtonStyle.primary(
                          density: ButtonDensity.dense,
                        )
                        .withBackgroundColor(
                          color:
                              index == 1
                                  ? PaxColors.deepPurple
                                  : Colors.transparent,
                        )
                        .withBorder(
                          border: Border.all(
                            color:
                                index == 1
                                    ? PaxColors.deepPurple
                                    : PaxColors.lilac,
                            width: 2,
                          ),
                        )
                        .withBorderRadius(
                          borderRadius: BorderRadius.circular(7),
                        ),
                    onPressed: () {
                      setState(() {
                        screenName = 'Survey';
                        index = 1;
                      });
                    },

                    child: Text(
                      'Earned',
                      style: TextStyle(
                        color: index == 1 ? PaxColors.white : PaxColors.black,
                      ),
                    ),
                  ).withPadding(right: 8),
                  Button(
                    style: const ButtonStyle.primary(
                          density: ButtonDensity.dense,
                        )
                        .withBackgroundColor(
                          color:
                              index == 3
                                  ? PaxColors.deepPurple
                                  : Colors.transparent,
                        )
                        .withBorder(
                          border: Border.all(
                            color:
                                index == 3
                                    ? PaxColors.deepPurple
                                    : PaxColors.lilac,
                            width: 2,
                          ),
                        )
                        .withBorderRadius(
                          borderRadius: BorderRadius.circular(7),
                        ),
                    onPressed: () {
                      setState(() {
                        screenName = 'Survey';
                        index = 3;
                      });
                    },

                    child: Text(
                      'Claimed',
                      style: TextStyle(
                        color: index == 3 ? PaxColors.white : PaxColors.black,
                      ),
                    ),
                  ).withPadding(right: 8),
                ],
              ),
            ).withPadding(bottom: 8),

            AchievementCard('task_starter', true).withPadding(bottom: 8),
            AchievementCard('early_bird', true).withPadding(bottom: 8),
            AchievementCard('task_expert', false).withPadding(bottom: 8),

            AchievementCard(
              'profile_perfectionist',
              false,
            ).withPadding(bottom: 8),
            AchievementCard('payout_connector', true).withPadding(bottom: 8),
            AchievementCard('real_human', false).withPadding(bottom: 8),
          ],
        ).withPadding(all: 8),
      ),
    );
  }
}

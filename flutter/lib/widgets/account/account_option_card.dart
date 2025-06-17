import 'package:flutter/material.dart' show Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:pax/providers/db/achievement/achievement_provider.dart';
import 'package:pax/utils/achievement_constants.dart';

class AccountOptionCard extends ConsumerStatefulWidget {
  const AccountOptionCard(this.option, this.isEarned, {super.key});

  final String option;

  final bool isEarned;

  @override
  ConsumerState<AccountOptionCard> createState() => _AccountOptionCardState();
}

class _AccountOptionCardState extends ConsumerState<AccountOptionCard> {
  @override
  Widget build(BuildContext context) {
    final achievementState = ref.watch(achievementProvider);
    final userAchievementNames =
        achievementState.achievements
            .map((a) => a.name)
            .whereType<String>()
            .toSet();

    List<String> requiredAchievements = [];
    if (widget.option == "profile") {
      requiredAchievements = [AchievementConstants.profilePerfectionist];
    } else if (widget.option == "payment_methods") {
      requiredAchievements = [
        AchievementConstants.payoutConnector,
        AchievementConstants.verifiedHuman,
      ];
    }
    final missingCount =
        requiredAchievements
            .where((ach) => !userAchievementNames.contains(ach))
            .length;

    return SizedBox(
      width: MediaQuery.of(context).size.width,

      // padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'lib/assets/svgs/${widget.option}.svg',

            // height: 24,
          ).withPadding(right: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      widget.option == 'profile'
                          ? 'My Profile'
                          : widget.option == 'account'
                          ? 'Account & Security'
                          : widget.option == 'payment_methods'
                          ? 'Withdrawal Methods'
                          : widget.option == 'help_and_support'
                          ? 'Help & Support'
                          : widget.option == 'logout'
                          ? 'Logout'
                          : toBeginningOfSentenceCase(
                            widget.option.split('_')[0],
                          ),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color:
                            widget.option == 'logout'
                                ? Colors.red
                                : PaxColors.black,
                      ),
                    ),
                    if ((widget.option == "profile" ||
                            widget.option == "payment_methods") &&
                        missingCount > 0)
                      Badge(
                        isLabelVisible: true,
                        label: Text(""),
                        backgroundColor: PaxColors.red,
                        offset: const Offset(24, -8),
                        smallSize: 12,
                        child: SizedBox(width: 0, height: 0),
                      ),
                  ],
                ).withPadding(bottom: 8),
              ),
            ],
          ),
          Spacer(flex: 1),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      'lib/assets/svgs/arrow_right.svg',

                      // height: 24,
                    ),
                  ],
                ).withPadding(bottom: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

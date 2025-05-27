import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/gradient_border.dart';
import 'package:pax/models/firestore/achievement/achievement_model.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:intl/intl.dart';

class AchievementCard extends ConsumerWidget {
  const AchievementCard({required this.achievement, super.key});

  final Achievement achievement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEarned =
        achievement.status == AchievementStatus.earned ||
        achievement.status == AchievementStatus.claimed;
    final isClaimed = achievement.status == AchievementStatus.claimed;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(8),
      decoration:
          isEarned
              ? ShapeDecoration(
                shape: GradientBorder(
                  gradient: LinearGradient(
                    colors: PaxColors.orangeToPinkGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  width: 2,
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
              )
              : BoxDecoration(
                color: PaxColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PaxColors.lightLilac, width: 1),
              ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  SvgPicture.asset(
                    'lib/assets/svgs/achievements/${achievement.svgAssetName}.svg',
                    height: 48,
                  ).withPadding(right: 12),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            achievement.name ?? 'Achievement',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: PaxColors.black,
                            ),
                          ),
                        ),
                        Text(
                          isEarned
                              ? 'Earned'
                              : 'G\$ ${achievement.amountAwarded}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ).withPadding(bottom: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.goal,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                            color: PaxColors.black,
                          ),
                        ).withPadding(bottom: 8),

                        if (isEarned && achievement.timeCompleted != null)
                          Text(
                            'Earned on ${DateFormat('MMMM d, yyyy | h:mm a').format(achievement.timeCompleted!.toDate())}',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 11,
                              color: PaxColors.black,
                            ),
                          ),

                        if (!isEarned)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 5,
                                child: ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: PaxColors.orangeToPinkGradient,
                                      stops: [0.0, 1.0],
                                    ).createShader(bounds);
                                  },
                                  blendMode: BlendMode.srcIn,
                                  child: Progress(
                                    progress:
                                        (achievement.tasksCompleted /
                                                achievement
                                                    .tasksNeededForCompletion *
                                                100)
                                            .toDouble(),
                                    min: 0,
                                    max: 100,
                                  ),
                                ),
                              ).withPadding(bottom: 4),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${achievement.tasksCompleted}/${achievement.tasksNeededForCompletion}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 11,
                                      color: PaxColors.black,
                                    ),
                                  ),
                                  Text(
                                    'Complete ${achievement.tasksNeededForCompletion - achievement.tasksCompleted} more to earn',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 11,
                                      color: PaxColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ).withPadding(bottom: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Button(
              onPressed: () {
                // TODO: Implement claim functionality
              },
              enabled: isEarned && !isClaimed,
              style:
                  isEarned && !isClaimed
                      ? const ButtonStyle.primary(
                        density: ButtonDensity.dense,
                      ).withBorderRadius(borderRadius: BorderRadius.circular(7))
                      : const ButtonStyle.outline(density: ButtonDensity.dense)
                          .withBorderRadius(
                            borderRadius: BorderRadius.circular(7),
                          )
                          .withBorder(
                            border: Border.all(
                              color: PaxColors.mediumPurple,
                              width: 2,
                            ),
                          ),
              child: Text(
                isClaimed
                    ? 'Claimed G\$${achievement.amountAwarded}'
                    : 'Claim G\$${achievement.amountAwarded}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color:
                      isEarned && !isClaimed
                          ? PaxColors.white
                          : PaxColors.lilac,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/gradient_border.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

class AchievementCard extends ConsumerWidget {
  const AchievementCard(this.achievement, this.isEarned, {super.key});

  final String achievement;

  final bool isEarned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,

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
              SvgPicture.asset(
                'lib/assets/svgs/$achievement.svg',

                // height: 24,
              ).withPadding(right: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${toBeginningOfSentenceCase(achievement.split('_')[0])} ${toBeginningOfSentenceCase(achievement.split('_')[1])}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: PaxColors.black,
                          ),
                        ),

                        Text(
                          isEarned ? 'Earned' : "G\$ 100",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ).withPadding(bottom: 8),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Completed your first survey',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                          color: PaxColors.black,
                        ),
                      ).withPadding(bottom: 8),

                      if (isEarned)
                        Text(
                          'Earned on March 12, 2025 | 9.41 AM',
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
                              width: MediaQuery.of(context).size.width * 0.75,
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
                                  // color: PaxColors.orange,
                                  progress: 50,
                                  min: 0,
                                  max: 100,
                                ),
                              ),
                            ).withPadding(bottom: 4),

                            Text(
                              '5/10',
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
          ).withPadding(bottom: 8),
          SizedBox(
            width: double.infinity,
            child: Button(
              onPressed: () {
                // context.go('/task');
              },
              enabled: isEarned,
              style:
                  isEarned
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
                !isEarned ? 'Claimed G\$ 100' : 'Claim G\$ 100',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color:
                      isEarned
                          ? PaxColors.white
                          : PaxColors
                              .lilac, // The purple color from your images
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

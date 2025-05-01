import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

class AchievementCard extends ConsumerWidget {
  const AchievementCard(this.achievement, this.isEarned, {super.key});

  final String achievement;

  final bool isEarned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: MediaQuery.of(context).size.width,

      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: PaxColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PaxColors.lightLilac, width: 1),
      ),
      child: Row(
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
                width: MediaQuery.of(context).size.width * 0.75,

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
    );
  }
}

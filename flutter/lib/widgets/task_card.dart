import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class TaskCard extends ConsumerWidget {
  const TaskCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: PaxColors.white,
        borderRadius: BorderRadius.circular(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Consumer Shopping Habits',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 20,
                  color: PaxColors.black,
                ),
              ).withPadding(bottom: 8),

              Text(
                '\$5.00',
                style: TextStyle(fontSize: 20, color: Colors.green),
              ),
            ],
          ).withPadding(bottom: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'lib/assets/svgs/clock_icon.svg',
                  ).withPadding(right: 8),
                  Text(
                    '15 min',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: PaxColors.black,
                    ),
                  ),
                ],
              ).withPadding(right: 8),
              Row(
                children: [
                  SvgPicture.asset(
                    'lib/assets/svgs/difficulty_level_icon.svg',
                  ).withPadding(right: 8),
                  Text(
                    'Easy',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: PaxColors.black,
                    ),
                  ),
                ],
              ).withPadding(right: 8),

              Row(
                children: [
                  SvgPicture.asset(
                    'lib/assets/svgs/days_available_icon.svg',
                  ).withPadding(right: 8),
                  Text(
                    '2 days',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: PaxColors.black,
                    ),
                  ),
                ],
              ),
            ],
          ).withPadding(bottom: 12),

          Row(
            children: [
              Button(
                enableFeedback: false,
                style: const ButtonStyle.outline(density: ButtonDensity.dense)
                    .withBackgroundColor(
                      color: PaxColors.green.withValues(alpha: 0.2),
                    )
                    .withBorder(border: Border.all(color: Colors.green))
                    .withBorderRadius(borderRadius: BorderRadius.circular(20)),
                onPressed: () {},
                child: Text(
                  'Retail',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: PaxColors.green, // The purple color from your images
                  ),
                ),
              ).withPadding(right: 8),

              Button(
                enableFeedback: false,
                style: const ButtonStyle.outline(density: ButtonDensity.dense)
                    .withBackgroundColor(
                      color: PaxColors.otherBlue.withValues(alpha: 0.2),
                    )
                    .withBorder(border: Border.all(color: PaxColors.otherBlue))
                    .withBorderRadius(borderRadius: BorderRadius.circular(20)),
                onPressed: () {},
                child: Text(
                  'Shopping',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color:
                        PaxColors
                            .otherBlue, // The purple color from your images
                  ),
                ),
              ),
            ],
          ).withPadding(bottom: 12),

          SizedBox(
            width: double.infinity,
            child: Button(
              onPressed: () {
                context.go('/task');
              },
              style: const ButtonStyle.primary(
                density: ButtonDensity.normal,
              ).withBorderRadius(borderRadius: BorderRadius.circular(7)),

              child: Text(
                'Check it out',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: PaxColors.white, // The purple color from your images
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

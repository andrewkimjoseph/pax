import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/dotted_border_painter.dart';
import 'package:pax/widgets/achievement_earning_card.dart';
import 'package:pax/widgets/task_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  String? selectedValue;
  int index = 0;

  String? screenName;
  bool viewYourProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              borderColor: PaxColors.deepPurple,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Balance',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 20,
                      color: PaxColors.white,
                    ),
                  ).withPadding(bottom: 8),

                  Row(
                    children: [
                      Text(
                        '\$ 200',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          color: PaxColors.white,
                        ),
                      ).withPadding(right: 8),
                      PrimaryBadge(
                        style: ButtonStyle.primary(density: ButtonDensity.dense)
                            .withBackgroundColor(color: Colors.blue)
                            .withBorderRadius(
                              borderRadius: BorderRadius.circular(18),
                            ),
                        child: Text(
                          selectedValue ?? 'USD',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: PaxColors.white,
                          ),
                        ),
                      ),
                    ],
                  ).withPadding(bottom: 16),

                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: PaxColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Select<String>(
                          // filled: true,
                          // disableHoverEffect: true,
                          itemBuilder: (context, item) {
                            return Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: PaxColors.blue,
                                ).withPadding(right: 4),
                                Text(item),
                              ],
                            );
                          },
                          popupConstraints: const BoxConstraints(
                            maxHeight: 300,
                            maxWidth: 200,
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedValue = value;
                            });
                          },
                          value: selectedValue,
                          placeholder: const Text('Change currency'),
                          popup:
                              const SelectPopup(
                                items: SelectItemList(
                                  children: [
                                    SelectItemButton(
                                      value: 'cUSD',
                                      child: Text('Celo Dollar (cUSD)'),
                                    ),
                                    SelectItemButton(
                                      value: 'G\$',
                                      child: Text('GoodDollar (G\$)'),
                                    ),
                                  ],
                                ),
                              ).call,
                        ),
                      ).withPadding(right: 8),

                      Button(
                        style: const ButtonStyle.outline(
                              density: ButtonDensity.normal,
                            )
                            .withBackgroundColor(color: PaxColors.blue)
                            .withBorder(
                              border: Border.all(color: Colors.transparent),
                            ),
                        onPressed: () {},
                        child: Text(
                          'Wallet',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color:
                                PaxColors
                                    .deepPurple, // The purple color from your images
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Row(
                  //   children: [
                  //     OutlineButton(
                  //       child: const Text('Cancel'),
                  //       onPressed: () {},
                  //     ),
                  //     const Spacer(),
                  //     PrimaryButton(
                  //       child: const Text('Deploy'),
                  //       onPressed: () {},
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ).withPadding(bottom: 8),
            if (!viewYourProgress)
              CustomPaint(
                painter: DottedBorderPainter(
                  color: PaxColors.deepPurple,
                  strokeWidth: 2,
                  radius: 12,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      viewYourProgress = !viewYourProgress;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: PaxColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome to Canvassing',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 20,
                            color: PaxColors.black,
                          ),
                        ).withPadding(bottom: 8),

                        Text(
                          'Complete surveys to earn points and level up. Start your journey today!',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            color: PaxColors.black,
                          ),
                          textAlign: TextAlign.center,
                        ).withPadding(bottom: 16),

                        AchievementEarningCard(),
                      ],
                    ),
                  ),
                ),
              ).withPadding(bottom: 8).animate().fade(),

            if (viewYourProgress)
              GestureDetector(
                onTap: () {
                  setState(() {
                    viewYourProgress = !viewYourProgress;
                  });
                },
                child:
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: PaxColors.specialPink,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Progress',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 20,
                              color: PaxColors.black,
                            ),
                          ).withPadding(bottom: 8),

                          AchievementEarningCard().withPadding(bottom: 12),
                          Text(
                            'View All Achievements',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: PaxColors.deepPurple,
                            ),
                          ).withPadding(bottom: 4),
                        ],
                      ),
                    ).withPadding(bottom: 8).animate().fade(),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tasks Available',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 20,
                    color: PaxColors.deepPurple,
                  ),
                ).withPadding(bottom: 8),

                GestureDetector(
                  onTap: () {},
                  child: SvgPicture.asset(
                    'lib/assets/svgs/arrow_icon.svg',
                    // height: 16,
                    // width: 16,
                  ),
                ),
              ],
            ).withPadding(bottom: 8, top: 4),

            for (var item in [1, 2, 3, 4, 5])
              TaskCard().withPadding(bottom: 12),
          ],
        ).withPadding(all: 8),
      ),
    );
  }
}


// String? selectedValue;
// @override
// Widget build(BuildContext context) {
//   return 
// }

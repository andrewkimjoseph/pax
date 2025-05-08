import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:pax/extensions/tooltip.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/widgets/published_reports_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  String selectedValue = 'good_dollar';
  int index = 0;

  final CarouselController controller = CarouselController();

  String? screenName;
  bool viewYourProgress = false;

  final List<String> svgs = ['green', 'pink', 'red', 'orange', 'blue'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: PaxColors.orangeToPinkGradient,
                ),

                // color: PaxColors.mediumPurple,
                border: Border.all(color: PaxColors.mediumPurple),
                borderRadius: BorderRadius.circular(12),
              ),
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
                        '17,000,000',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          color: PaxColors.white,
                        ),
                      ).withPadding(right: 8),
                      SvgPicture.asset(
                        'lib/assets/svgs/currencies/$selectedValue.svg',
                        height: 25,
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
                                // Icon(
                                //   Icons.circle,
                                //   size: 12,
                                //   color: PaxColors.blue,
                                // ).withPadding(right: 4),
                                SvgPicture.asset(
                                  'lib/assets/svgs/currencies/$item.svg',

                                  height: 20,
                                ).withPadding(right: 8),
                                Text(item),
                              ],
                            );
                          },

                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedValue = value;
                              });
                            }
                          },
                          value: selectedValue,

                          placeholder: const Text('Change currency'),
                          popup:
                              (context) => SelectPopup(
                                items: SelectItemList(
                                  children: [
                                    SelectItemButton(
                                      value: 'good_dollar',
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            'lib/assets/svgs/currencies/good_dollar.svg',

                                            height: 25,
                                          ).withPadding(right: 4),
                                          Text('GoodDollar (G\$)'),
                                        ],
                                      ),
                                    ),
                                    SelectItemButton(
                                      value: 'celo_dollar',
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            'lib/assets/svgs/currencies/celo_dollar.svg',

                                            height: 19,
                                          ).withPadding(right: 6),
                                          Text('Celo Dollar (cUSD)'),
                                        ],
                                      ).withPadding(left: 4),
                                    ),
                                    SelectItemButton(
                                      value: 'tether_usd',
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            'lib/assets/svgs/currencies/tether_usd.svg',

                                            height: 19,
                                          ).withPadding(right: 6),
                                          Text('Tether USD (USDT)'),
                                        ],
                                      ).withPadding(left: 4),
                                    ),

                                    SelectItemButton(
                                      value: 'usd_coin',
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            'lib/assets/svgs/currencies/usd_coin.svg',

                                            height: 19,
                                          ).withPadding(right: 6),
                                          Text('USD Coin (USDC)'),
                                        ],
                                      ).withPadding(left: 4),
                                    ).withPadding(bottom: 30),
                                  ],
                                ),
                              ),
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
                        onPressed: () {
                          context.go('/wallet');
                        },
                        child: Text(
                          'Wallet',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color:
                                PaxColors
                                    .black, // The purple color from your images
                          ),
                        ),
                      ).withToolTip('Check out your wallet.'),
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
              ).withPadding(all: 12),
            ).withPadding(bottom: 8),

            Container(
              width: MediaQuery.of(context).size.width,
              height: 75,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                // gradient: LinearGradient(
                //   colors: PaxColors.orangeToPinkGradient,
                // ),
                color: PaxColors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SvgPicture.asset(
                      'lib/assets/svgs/x_white.svg',
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),

                      height: 32,
                    ),
                  ).withPadding(right: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Join the tribe!',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: PaxColors.white,
                        ),
                      ).withPadding(bottom: 8),

                      Text(
                        "Our X followers get first-time updates!",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        child: Row(
                          children: [
                            Button(
                              onPressed: () {
                                launchExternalUrl(
                                  'https://x.com/thecanvassing',
                                );
                              },
                              disableHoverEffect: true,
                              disableTransition: true,
                              style: ButtonStyle.outline(
                                    density: ButtonDensity.dense,
                                  )
                                  .withBorder(
                                    border: Border.all(color: Colors.white),
                                  )
                                  .withBorderRadius(
                                    borderRadius: BorderRadius.circular(20),
                                    hoverBorderRadius: BorderRadius.circular(
                                      20,
                                    ),
                                  ),

                              trailing: SvgPicture.asset(
                                'lib/assets/svgs/arrow_icon.svg',
                                colorFilter: ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),

                                height: 16,
                              ),
                              // onPressed: callBack,
                              child: const Text(
                                "Follow",
                                style: TextStyle(color: PaxColors.white),
                              ),
                            ).withToolTip('Follow us on X.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).withPadding(bottom: 8),

            SizedBox(
              height: MediaQuery.of(context).size.width / 2,

              child: Carousel(
                onIndexChanged: (value) {},
                // draggable: false,
                transition: const CarouselTransition.fading(),
                controller: controller,
                direction: Axis.horizontal,
                autoplaySpeed: const Duration(seconds: 1),
                // speed: Duration(seconds: 10),
                // sizeConstraint: CarouselSizeConstraint.fractional(1),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return SvgPicture.asset(
                    placeholderBuilder:
                        (context) => Center(child: CircularProgressIndicator()),
                    fit: BoxFit.fitWidth,
                    'lib/assets/svgs/dashboard_carousel/${svgs[index]}.svg',
                  );
                },
                duration: const Duration(seconds: 1),
              ),
            ),

            // if (!viewYourProgress)
            //   CustomPaint(
            //     painter: DottedBorderPainter(
            //       color: PaxColors.deepPurple,
            //       strokeWidth: 2,
            //       radius: 12,
            //     ),
            //     child: GestureDetector(
            //       onTap: () {
            //         setState(() {
            //           viewYourProgress = !viewYourProgress;
            //         });
            //       },
            //       child: Container(
            //         width: double.infinity,
            //         decoration: BoxDecoration(
            //           color: PaxColors.white,
            //           borderRadius: BorderRadius.circular(12),
            //         ),
            //         padding: const EdgeInsets.all(16),
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             Text(
            //               'Welcome to Canvassing',
            //               style: TextStyle(
            //                 fontWeight: FontWeight.normal,
            //                 fontSize: 20,
            //                 color: PaxColors.black,
            //               ),
            //             ).withPadding(bottom: 8),

            //             Text(
            //               'Complete surveys to earn points and level up. Start your journey today!',
            //               style: TextStyle(
            //                 fontWeight: FontWeight.normal,
            //                 fontSize: 16,
            //                 color: PaxColors.black,
            //               ),
            //               textAlign: TextAlign.center,
            //             ).withPadding(bottom: 16),

            //             AchievementEarningCard(),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ).withPadding(bottom: 8).animate().fade(),

            // if (viewYourProgress)
            //   GestureDetector(
            //     onTap: () {
            //       setState(() {
            //         viewYourProgress = !viewYourProgress;
            //       });
            //     },
            //     child:
            //         Container(
            //           width: double.infinity,
            //           decoration: BoxDecoration(
            //             color: PaxColors.specialPink,
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //           padding: const EdgeInsets.all(16),
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Text(
            //                 'Your Progress',
            //                 style: TextStyle(
            //                   fontWeight: FontWeight.normal,
            //                   fontSize: 20,
            //                   color: PaxColors.black,
            //                 ),
            //               ).withPadding(bottom: 8),

            //               AchievementEarningCard().withPadding(bottom: 12),
            //               Text(
            //                 'View All Achievements',
            //                 style: TextStyle(
            //                   fontWeight: FontWeight.bold,
            //                   fontSize: 14,
            //                   color: PaxColors.deepPurple,
            //                 ),
            //               ).withPadding(bottom: 4),
            //             ],
            //           ),
            //         ).withPadding(bottom: 8).animate().fade(),
            //   ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Published Reports',
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

            PublishedReportCard('early_bird').withPadding(bottom: 12),
          ],
        ).withPadding(all: 8),
      ),
    );
  }
}

Future<void> launchExternalUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    // Show error if URL can't be launched
  }
}

// String? selectedValue;
// @override
// Widget build(BuildContext context) {
//   return 
// }





// final CarouselController controller = CarouselController();
// @override
// Widget build(BuildContext context) {
//   return 
// }

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:pax/data/forum_reports.dart';
import 'package:pax/extensions/tooltip.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/url_handler.dart';
import 'package:pax/widgets/current_balance_card.dart';
import 'package:pax/widgets/published_reports_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
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
            const CurrentBalanceCard('/wallet').withPadding(bottom: 8),

            Container(
              // width: double.infinity,
              height: 120,
              padding: EdgeInsets.all(8),
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

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Text(
                          "Our X followers get early access to 30% more high-paying surveys.",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                            color: Colors.white,
                          ),
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
                                UrlHandler.launchInExternalBrowser(
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

            PublishedReportCard(forumReports).withPadding(bottom: 12),
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





// final CarouselController controller = CarouselController();
// @override
// Widget build(BuildContext context) {
//   return 
// }


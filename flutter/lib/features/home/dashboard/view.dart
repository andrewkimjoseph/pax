import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:pax/data/forum_reports.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/widgets/current_balance_card.dart';
import 'package:pax/widgets/published_reports_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pax/widgets/x_follow_card.dart';

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

            const XFollowCard().withPadding(bottom: 8),

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


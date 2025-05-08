import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pax/features/report_page/view.dart' show ReportPageView;
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/gradient_border.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class PublishedReportCard extends ConsumerStatefulWidget {
  const PublishedReportCard(this.achievement, {super.key});

  final String achievement;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PublishedReportCardState();
}

class _PublishedReportCardState extends ConsumerState<PublishedReportCard> {
  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2),
      decoration: ShapeDecoration(
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
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              children: <Widget>[
                ForumReportCard().withPadding(right: 8),
                ForumReportCard().withPadding(right: 8),
                ForumReportCard()..withPadding(right: 8),
              ],
            ),
          ),
          // FittedBox(
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       SmoothPageIndicator(
          //         controller: pageController,
          //         count: 5,
          //         onDotClicked: (index) {
          //           pageController.jumpTo(index.toDouble());
          //         },
          //         effect: const ExpandingDotsEffect(
          //           activeDotColor: PaxColors.deepPurple,
          //           dotHeight: 16,
          //           dotWidth: 16,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

class ForumReportCard extends ConsumerStatefulWidget {
  const ForumReportCard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ForumReportCardState();
}

class _ForumReportCardState extends ConsumerState<ForumReportCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReportPageView()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: PaxColors.deepPurple, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "[REPORT] How Africa's Digital Payment Landscape is Evolving",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: PaxColors.black,
                          ),
                        ),
                      ),
                    ],
                  ).withPadding(bottom: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "A recent study comparing financial behaviors among users in Nigeria and Kenya reveals fascinating insights",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                            color: PaxColors.black,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ).withPadding(bottom: 4),

                  Row(
                    children: [
                      SvgPicture.asset(
                        'lib/assets/svgs/calendar.svg',
                      ).withPadding(right: 4),

                      Expanded(
                        child: Text(
                          "1st April 2025",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 10,
                            color: Color(0xFF737373),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).withPadding(right: 8),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2.5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('lib/assets/images/cover.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

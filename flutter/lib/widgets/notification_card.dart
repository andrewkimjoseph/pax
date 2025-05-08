import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class NotificationCard extends ConsumerWidget {
  const NotificationCard(this.label, this.initials, {super.key});

  final String label;
  final String initials;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: PaxColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PaxColors.lightLilac, width: 1),
      ),

      // padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'lib/assets/svgs/new_survey.svg',

            // height: 24,
          ).withPadding(right: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        label,

                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: PaxColors.black,
                        ),
                      ),
                    ],
                  ).withPadding(bottom: 8),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'A new task is available: RZS 16(2)',

                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          color: PaxColors.darkGrey,
                        ),
                      ),
                    ),
                  ],
                ).withPadding(bottom: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '9:41 AM',

                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                          color: PaxColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Spacer(flex: 1),
        ],
      ),
    );
  }
}

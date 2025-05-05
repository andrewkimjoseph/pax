import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

class ActivityCard extends ConsumerWidget {
  const ActivityCard(this.acitivity, {super.key});

  final String acitivity;

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
            'lib/assets/svgs/$acitivity.svg',

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
                      '${toBeginningOfSentenceCase(acitivity.split('_')[0])} ',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: PaxColors.black,
                      ),
                    ),

                    Text(
                      "G\$ 100",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ).withPadding(bottom: 8),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Completed your first $acitivity',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                      color: PaxColors.black,
                    ),
                  ).withPadding(bottom: 8),

                  Text(
                    'Dec 22 2024, 2025 | 9.41 AM',
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
      ).withPadding(bottom: 8),
    );
  }
}

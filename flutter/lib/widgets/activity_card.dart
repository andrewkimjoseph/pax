import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pax/models/local/activity_model.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/activity_type.dart';
import 'package:pax/utils/currency_symbol.dart';
import 'package:pax/utils/time_formatter.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ActivityCard extends ConsumerWidget {
  const ActivityCard(this.activity, {super.key});

  final Activity activity;

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
          FaIcon(
            activity.getIcon(),
            color: PaxColors.lilac,
          ).withPadding(left: 4, right: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${activity.type.singularName} ',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: PaxColors.black,
                        ),
                      ),

                      Spacer(),

                      Visibility(
                        visible:
                            activity.reward != null ||
                            activity.withdrawal != null,
                        child: Row(
                          children: [
                            if (activity.getCurrencyId() != null)
                              SvgPicture.asset(
                                'lib/assets/svgs/currencies/${CurrencySymbolUtil.getNameForCurrency(activity.getCurrencyId())}.svg',
                                height: 20,
                              ).withPadding(right: 4),

                            Text(
                              activity.getAmount() ?? '0',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).withPadding(bottom: 8),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.taskCompletion != null
                          ? 'You have completed a task'
                          : activity.reward != null
                          ? 'You have earned a reward'
                          : 'You have made a withdrawal',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                        color: PaxColors.black,
                      ),
                    ).withPadding(bottom: 8),

                    Text(
                      activity.formattedTimestamp,
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
          ),
        ],
      ).withPadding(bottom: 8),
    );
  }
}

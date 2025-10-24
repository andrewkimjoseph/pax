import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/providers/local/task_context/task_context_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/currency_symbol.dart';
import 'package:pax/utils/token_balance_util.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class OtherTaskCard extends ConsumerWidget {
  const OtherTaskCard({super.key});

  bool _shouldShowDetails(BuildContext context, String? actionText) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final isTaskSummary = currentLocation.startsWith('/tasks/task-summary');
    final isNotCheckoutTask =
        actionText != 'Check Out Web App' &&
        actionText != 'Check Out Mobile App';

    return isTaskSummary || isNotCheckoutTask;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskContextProvider)?.task;

    // Calculate days remaining if deadline exists
    String daysRemaining = '-- days';
    if (task?.deadline != null) {
      final difference = task?.deadline!.toDate().difference(DateTime.now());
      if (difference != null &&
          difference.inSeconds > 0 &&
          difference.inDays < 1) {
        daysRemaining = '1 day';
      } else if (difference != null && difference.inDays >= 1) {
        daysRemaining =
            '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
      } else if (difference != null && difference.inSeconds <= 0) {
        daysRemaining = 'Expired';
      }
    }

    // Format reward amount
    String rewardAmount = '--';
    if (task?.rewardAmountPerParticipant != null) {
      // Using NumberFormat for proper currency formatting
      rewardAmount =
          task?.rewardAmountPerParticipant!.toStringAsFixed(2) ?? '0';
    }

    // Format estimated time
    String estimatedTime = '-- min';
    if (task?.estimatedTimeOfCompletionInMinutes != null) {
      estimatedTime = '${task?.estimatedTimeOfCompletionInMinutes} min';
    }

    // Get difficulty level with fallback
    String difficultyLevel = task?.levelOfDifficulty ?? 'Not specified';

    return Container(
      padding: EdgeInsets.all(10),
      width: double.infinity,
      // decoration: BoxDecoration(
      //   color: PaxColors.white,
      //   borderRadius: BorderRadius.circular(12),
      //   boxShadow: [
      //     BoxShadow(
      //       color: PaxColors.lightGrey,
      //       spreadRadius: 1,
      //       blurRadius: 2,
      //       offset: Offset(0, 1), // changes position of shadow
      //     ),
      //   ],
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task?.title ?? 'Untitled Task',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: PaxColors.black,
                  ),
                ).withPadding(bottom: 8),
              ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: PaxColors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      TokenBalanceUtil.getLocaleFormattedAmount(
                        num.parse(rewardAmount),
                      ),
                      style: TextStyle(
                        fontSize: 24,
                        color: PaxColors.deepPurple,
                        fontWeight: FontWeight.w900,
                        height: 1, // Tighter line height
                        letterSpacing:
                            -0.5, // Tighter letter spacing for numbers
                      ),
                    ).withPadding(right: 8),
                    SvgPicture.asset(
                      'lib/assets/svgs/currencies/${CurrencySymbolUtil.getNameForCurrency(task?.rewardCurrencyId)}.svg',
                      height: 25,
                    ),
                  ],
                ),
              ),
            ],
          ).withPadding(bottom: 8),

          Visibility(
            visible: _shouldShowDetails(context, task?.actionText),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.clock,
                      size: 16,
                      color: PaxColors.black,
                    ).withPadding(right: 8),
                    Text(
                      estimatedTime,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 13,
                        color: PaxColors.black,
                      ),
                    ),
                  ],
                ).withPadding(right: 8),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.chartSimple,
                      size: 16,
                      color: PaxColors.black,
                    ).withPadding(right: 8),
                    Text(
                      difficultyLevel,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 13,
                        color: PaxColors.black,
                      ),
                    ),
                  ],
                ).withPadding(right: 8),

                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.calendar,
                      size: 16,
                      color: PaxColors.black,
                    ).withPadding(right: 8),
                    Text(
                      daysRemaining,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 13,
                        color: PaxColors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ).withPadding(bottom: 12),
          ),

          Visibility(
            visible: _shouldShowDetails(context, task?.actionText),
            child: Row(
              children: [
                // Button(
                //   enableFeedback: false,
                //   style: const ButtonStyle.outline(density: ButtonDensity.dense)
                //       .withBackgroundColor(
                //         color: PaxColors.green.withValues(alpha: 0.2),
                //       )
                //       .withBorder(border: Border.all(color: Colors.green))
                //       .withBorderRadius(
                //         borderRadius: BorderRadius.circular(20),
                //       ),
                //   // onPressed: () {},
                //   child: Text(
                //     task?.actionText ?? 'General',
                //     style: TextStyle(
                //       fontWeight: FontWeight.w900,
                //       fontSize: 12,
                //       color: PaxColors.green,
                //     ),
                //   ),
                // ).withPadding(right: 8),
                Button(
                  enableFeedback: false,
                  style: const ButtonStyle.outline(density: ButtonDensity.dense)
                      .withBackgroundColor(
                        color: PaxColors.blue.withValues(alpha: 0.2),
                      )
                      .withBorder(border: Border.all(color: PaxColors.blue))
                      .withBorderRadius(
                        borderRadius: BorderRadius.circular(20),
                      ),
                  // onPressed: () {},
                  child: Text(
                    task?.category ?? 'General',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: PaxColors.blue,
                    ),
                  ),
                ).withPadding(right: 8),

                Button(
                  enableFeedback: false,
                  style: const ButtonStyle.outline(density: ButtonDensity.dense)
                      .withBackgroundColor(
                        color: PaxColors.blue.withValues(alpha: 0.2),
                      )
                      .withBorder(border: Border.all(color: PaxColors.blue))
                      .withBorderRadius(
                        borderRadius: BorderRadius.circular(20),
                      ),
                  // onPressed: () {},
                  child: Text(
                    "${task?.paymentTerms} payment",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: PaxColors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

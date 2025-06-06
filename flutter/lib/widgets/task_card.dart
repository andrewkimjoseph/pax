import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/models/firestore/screening/screening_model.dart';
import 'package:pax/models/firestore/task/task_model.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/local/task_context/main_task_context_provider.dart';
import 'package:pax/providers/local/task_context/screening_context_provider.dart';
import 'package:pax/providers/local/task_master_provider.dart';
import 'package:pax/providers/local/task_master_server_id_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/currency_symbol.dart';
import 'package:pax/utils/token_balance_util.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class TaskCard extends ConsumerWidget {
  const TaskCard(this.task, {this.screening, super.key});

  final Task task;

  final Screening? screening;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate days remaining if deadline exists
    String daysRemaining = '-- days';
    if (task.deadline != null) {
      final difference = task.deadline!.toDate().difference(DateTime.now());
      final days = difference.inDays;
      daysRemaining =
          days > 0 ? '$days ${days == 1 ? 'day' : 'days'}' : 'Expired';
    }

    // Format reward amount
    String rewardAmount = '--';
    if (task.rewardAmountPerParticipant != null) {
      // Using NumberFormat for proper currency formatting
      rewardAmount = task.rewardAmountPerParticipant!.toStringAsFixed(2);
    }

    // Format estimated time
    String estimatedTime = '-- min';
    if (task.estimatedTimeOfCompletionInMinutes != null) {
      estimatedTime = '${task.estimatedTimeOfCompletionInMinutes} min';
    }

    // Get difficulty level with fallback
    String difficultyLevel = task.levelOfDifficulty ?? 'Not specified';

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                task.title ?? 'Untitled Task',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                  color: PaxColors.black,
                ),
              ).withPadding(bottom: 8, right: 16).expanded(),

              // Spacer(),
              Text(
                TokenBalanceUtil.getLocaleFormattedAmount(
                  num.parse(rewardAmount),
                ),
                style: TextStyle(
                  fontSize: 20,
                  color: PaxColors.green,
                  fontWeight: FontWeight.bold,
                ),
              ).withPadding(right: 4),
              SvgPicture.asset(
                'lib/assets/svgs/currencies/${CurrencySymbolUtil.getNameForCurrency(task.rewardCurrencyId)}.svg',
                height: 25,
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
                  SvgPicture.asset(
                    'lib/assets/svgs/difficulty_level_icon.svg',
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
                  SvgPicture.asset(
                    'lib/assets/svgs/days_available_icon.svg',
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
                  task.type ?? 'General',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: PaxColors.green,
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
                  task.category ?? 'General',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: PaxColors.otherBlue,
                  ),
                ),
              ),
            ],
          ).withPadding(bottom: 12),

          SizedBox(
            width: double.infinity,
            child: Button(
              onPressed: () async {
                ref
                    .read(taskContextProvider.notifier)
                    .setTaskContext(task.id, task);

                final serverWalletId = await ref
                    .read(taskMasterRepositoryProvider)
                    .fetchServerWalletId(task.id);

                ref
                    .read(taskMasterServerIdProvider.notifier)
                    .setServerId(serverWalletId);

                if (screening?.txnHash != null) {
                  ref
                      .read(screeningContextProvider.notifier)
                      .setScreening(screening!);
                }

                ref.read(analyticsProvider).taskTapped({
                  "taskId": task.id,
                  "taskTitle": task.title,
                  "taskType": task.type,
                  "taskCategory": task.category,
                  "taskMasterServerWalletId": serverWalletId,
                });

                if (screening?.txnHash != null) {
                  if (context.mounted) {
                    context.push('/task-itself');
                  }
                } else {
                  if (context.mounted) {
                    context.push('/task-summary');
                  }
                }
              },
              style: const ButtonStyle.primary(density: ButtonDensity.normal)
                  .withBorderRadius(borderRadius: BorderRadius.circular(7))
                  .withBackgroundColor(
                    color:
                        screening?.txnHash != null
                            ? PaxColors.blue
                            : PaxColors.deepPurple,
                  ),

              child: Text(
                screening?.txnHash != null ? 'Go to task' : 'Check it out',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color:
                      screening?.txnHash != null
                          ? PaxColors.white
                          : PaxColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

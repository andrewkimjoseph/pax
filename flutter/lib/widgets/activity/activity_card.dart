import 'package:flutter/material.dart' show InkWell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/models/local/activity_model.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/local/claim_reward_context_provider.dart';
import 'package:pax/providers/local/task_context/repository_providers.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/activity_type.dart';
import 'package:pax/utils/currency_symbol.dart';
import 'package:pax/utils/time_formatter.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:collection/collection.dart';

class ActivityCard extends ConsumerStatefulWidget {
  const ActivityCard(this.activity, {super.key, required this.allActivities});

  final Activity activity;
  final List<Activity> allActivities;

  @override
  ConsumerState<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends ConsumerState<ActivityCard> {
  @override
  void initState() {
    super.initState();
  }

  void _callBackFn() async {
    final activityIsRewarded =
        widget.activity.taskCompletion != null &&
        widget.allActivities.any(
          (activity) =>
              activity.reward != null &&
              activity.reward?.txnHash != null &&
              activity.reward?.taskCompletionId ==
                  widget.activity.taskCompletion?.id,
        );

    final isTaskComplete = widget.activity.isComplete;
    final taskId = widget.activity.taskCompletion?.taskId;
    final screeningId = widget.activity.taskCompletion?.screeningId;
    final taskCompletionId = widget.activity.taskCompletion?.id;

    // Find the matching reward in allActivities
    final matchingReward = widget.allActivities.firstWhereOrNull(
      (a) =>
          a.reward != null &&
          a.reward?.taskCompletionId == taskCompletionId &&
          a.reward?.txnHash != null,
    );

    final task = await ref.read(tasksRepositoryProvider).getTaskById(taskId);

    final amount = task?.rewardAmountPerParticipant;
    final tokenId = task?.rewardCurrencyId;
    final numberOfCooldownHours = task?.numberOfCooldownHours ?? 0;
    final timeCompleted = widget.activity.taskCompletion?.timeCompleted;
    final timeCreated = widget.activity.taskCompletion?.timeCreated;
    final isValid = widget.activity.taskCompletion?.isValid;

    ref
        .read(claimRewardContextProvider.notifier)
        .setContext(
          screeningId: screeningId,
          taskId: taskId,
          taskCompletionId: taskCompletionId,
          amount: amount,
          tokenId: tokenId,
          txnHash: matchingReward?.reward?.txnHash,
          taskIsCompleted: isTaskComplete,
          numberOfCooldownHours: numberOfCooldownHours,
          timeCompleted: timeCompleted,
          timeCreated: timeCreated,
          isValid: isValid,
        );

    if (!isTaskComplete) {
      ref.read(analyticsProvider).incompleteTaskCompletionTapped({
        "taskId": taskId,
        "screeningId": screeningId,
      });
    } else if (!activityIsRewarded) {
      ref.read(analyticsProvider).unrewardedTaskCompletionTapped({
        "taskId": taskId,
        "screeningId": screeningId,
        "taskCompletionId": taskCompletionId,
      });
    }

    if (mounted) {
      context.push("/claim-reward");
    }
  }

  @override
  Widget build(BuildContext context) {
    final activityIsClaimed =
        widget.activity.taskCompletion != null &&
        widget.allActivities.any(
          (activity) =>
              activity.reward != null &&
              activity.reward?.txnHash != null &&
              activity.reward?.taskCompletionId ==
                  widget.activity.taskCompletion?.id,
        );

    final isTaskComplete = widget.activity.isComplete;
    final isTaskCompletion = widget.activity.taskCompletion != null;
    final isValid = widget.activity.taskCompletion?.isValid;
    final isExpired = widget.activity.isExpired;

    return InkWell(
      onTap: isTaskCompletion && isValid != false ? () => _callBackFn() : null,
      child: Container(
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
              widget.activity.getIcon(),
              color: PaxColors.lilac,
            ).withPadding(left: 4, right: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          '${widget.activity.type.singularName} ',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: PaxColors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Visibility(
                        visible:
                            widget.activity.reward != null ||
                            widget.activity.withdrawal != null,
                        child: Row(
                          children: [
                            Text(
                              widget.activity.getAmount() ?? '0',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ).withPadding(right: 4),

                            if (widget.activity.getCurrencyId() != null)
                              SvgPicture.asset(
                                'lib/assets/svgs/currencies/${CurrencySymbolUtil.getNameForCurrency(widget.activity.getCurrencyId())}.svg',
                                height:
                                    widget.activity.getCurrencyId() == 1
                                        ? 20
                                        : 16,
                              ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: isTaskCompletion,
                        child: Row(
                          children: [
                            OutlineBadge(
                              child: Row(
                                children: [
                                  Text(
                                    isValid == false
                                        ? 'Invalid'
                                        : activityIsClaimed
                                        ? 'Claimed'
                                        : isTaskComplete
                                        ? 'Unclaimed'
                                        : isExpired
                                        ? 'Expired'
                                        : 'Incomplete',
                                  ).withPadding(right: 4),
                                  FaIcon(
                                    activityIsClaimed
                                        ? FontAwesomeIcons.solidCircleCheck
                                        : FontAwesomeIcons.solidCircleXmark,
                                    size: 16,
                                    color:
                                        activityIsClaimed
                                            ? PaxColors.green
                                            : isValid == false
                                            ? PaxColors.red
                                            : (isTaskComplete)
                                            ? PaxColors.orange
                                            : isExpired
                                            ? PaxColors.red
                                            : PaxColors.orange,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).withPadding(bottom: 8),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTaskCompletion
                            ? isTaskComplete
                                ? 'You have completed a task'
                                : isExpired
                                ? 'You have an expired task'
                                : 'You have an incomplete task'
                            : widget.activity.reward != null
                            ? 'You have earned a reward'
                            : 'You have made a withdrawal',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                          color: PaxColors.black,
                        ),
                      ).withPadding(bottom: 8),

                      Text(
                        widget.activity.formattedTimestamp,
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
      ),
    );
  }
}

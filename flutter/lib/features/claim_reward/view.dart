import 'package:flutter/material.dart' show Divider, InkWell;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/route/home_selected_index_provider.dart';
import 'package:pax/providers/route/root_selected_index_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/services/reward_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;
import 'package:pax/providers/local/claim_reward_context_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pax/utils/token_balance_util.dart';
import 'package:pax/utils/currency_symbol.dart';
import 'package:pax/widgets/toast.dart';

class ClaimRewardView extends ConsumerStatefulWidget {
  const ClaimRewardView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ClaimRewardViewState();
}

class _ClaimRewardViewState extends ConsumerState<ClaimRewardView> {
  bool isClaiming = false;

  /// Checks if the cooldown period has elapsed
  /// Returns true if the user can claim the reward (cooldown has passed)
  bool _canClaimReward({
    required int numberOfCooldownDays,
    required DateTime? timeCompleted,
  }) {
    if (numberOfCooldownDays == 0) return true;
    if (timeCompleted == null) return false;

    final cooldownEndDate = timeCompleted.add(
      Duration(days: numberOfCooldownDays),
    );
    final now = DateTime.now();

    return now.isAfter(cooldownEndDate) ||
        now.isAtSameMomentAs(cooldownEndDate);
  }

  /// Gets the remaining time until cooldown expires
  String _getRemainingCooldownTime({
    required int numberOfCooldownDays,
    required DateTime? timeCompleted,
  }) {
    if (timeCompleted == null) return '';

    final cooldownEndDate = timeCompleted.add(
      Duration(days: numberOfCooldownDays),
    );
    final now = DateTime.now();
    final difference = cooldownEndDate.difference(now);

    if (difference.isNegative) return '';

    final days = difference.inDays;
    final hours = difference.inHours.remainder(24);
    final minutes = difference.inMinutes.remainder(60);

    if (days > 0) {
      return '$days day${days > 1 ? 's' : ''}, $hours hour${hours != 1 ? 's' : ''}';
    } else if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''}, $minutes minute${minutes != 1 ? 's' : ''}';
    } else {
      return '$minutes minute${minutes != 1 ? 's' : ''}';
    }
  }

  Future<void> _claimReward(BuildContext context) async {
    setState(() {
      isClaiming = true;
    });
    final claimContext = ref.read(claimRewardContextProvider);
    if (claimContext == null) {
      _showErrorDialog('No claim context found.');
      setState(() {
        isClaiming = false;
      });
      return;
    }
    final taskId = claimContext.taskId;
    final screeningId = claimContext.screeningId;
    final taskCompletionId = claimContext.taskCompletionId;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => PopScope(
            canPop: false,
            child: AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator().withPadding(bottom: 24),
                  Text(
                    'Please wait while we process your claim...',
                    style: TextStyle(
                      color: PaxColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
    );

    try {
      ref.read(analyticsProvider).claimRewardTapped({
        "taskId": taskId,
        "screeningId": screeningId,
        "taskCompletionId": taskCompletionId,
      });

      if (taskCompletionId == null) {
        _showErrorDialog('No task completion ID found.');
        setState(() {
          isClaiming = false;
        });
        return;
      }
      await ref
          .read(rewardServiceProvider)
          .rewardParticipant(taskCompletionId: taskCompletionId);
      ref.read(analyticsProvider).claimRewardComplete({
        "taskId": taskId,
        "screeningId": screeningId,
        "taskCompletionId": taskCompletionId,
      });
      if (!context.mounted) return;
      context.pop(); // Close loading dialog
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (dialogContext) => PopScope(
              canPop: false,
              child: AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'lib/assets/svgs/withdrawal_complete.svg',
                    ).withPadding(bottom: 8),

                    Text(
                      'Reward Claimed!',
                      style: TextStyle(
                        color: PaxColors.deepPurple,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ).withPadding(bottom: 8),

                    Text(
                      'Your reward has been added to your wallet!',
                      style: TextStyle(
                        color: PaxColors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: MediaQuery.of(dialogContext).size.width / 2.5,
                      child: PrimaryButton(
                        child: const Text('OK'),
                        onPressed: () => dialogContext.go("/home"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );
    } catch (e) {
      if (!context.mounted) return;
      context.pop(); // Close loading dialog
      ref.read(analyticsProvider).claimRewardFailed({
        "taskId": taskId,
        "screeningId": screeningId,
        "taskCompletionId": taskCompletionId,
        "error": e.toString().substring(0, e.toString().length.clamp(0, 99)),
      });
      _showErrorDialog('Failed to claim reward: $e');
    } finally {
      setState(() {
        isClaiming = false;
      });
    }
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text('Claim Reward Error'),
            content: Text(
              errorMessage,
              maxLines: 3,
              style: TextStyle(color: PaxColors.black),
            ),
            actions: [
              OutlineButton(
                onPressed: () => dialogContext.go("/home"),
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _goHome(BuildContext context) {
    final claimContext = ref.read(claimRewardContextProvider);
    final taskCompletionId = claimContext?.taskCompletionId;

    ref.read(analyticsProvider).goHomeToCompleteTaskTapped({
      "taskCompletionId": taskCompletionId,
    });
    ref.read(rootSelectedIndexProvider.notifier).setIndex(0);
    ref.read(claimRewardContextProvider.notifier).clear();
    ref.read(homeSelectedIndexProvider.notifier).setIndex(1);
    context.go("/home");
  }

  @override
  Widget build(BuildContext context) {
    final claimContext = ref.watch(claimRewardContextProvider);
    final taskCompletionId = claimContext?.taskCompletionId;
    final amount = claimContext?.amount;
    final tokenId = claimContext?.tokenId;
    final txnHash = claimContext?.txnHash;
    final taskIsCompleted = claimContext?.taskIsCompleted;
    final numberOfCooldownDays = claimContext?.numberOfCooldownDays ?? 0;
    final timeCompleted = claimContext?.timeCompleted?.toDate();
    final isValid = claimContext?.isValid ?? true;

    final canClaim = _canClaimReward(
      numberOfCooldownDays: numberOfCooldownDays,
      timeCompleted: timeCompleted,
    );

    final remainingCooldownTime = _getRemainingCooldownTime(
      numberOfCooldownDays: numberOfCooldownDays,
      timeCompleted: timeCompleted,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      headers: [
        AppBar(
          padding: EdgeInsets.all(8),
          leading: [],
          backgroundColor: PaxColors.white,
        ).withPadding(top: 16),
      ],
      footers: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              Divider().withPadding(top: 10, bottom: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Button(
                  style: ButtonStyle.primary(),
                  onPressed:
                      (txnHash != null && txnHash.isNotEmpty) ||
                              (!canClaim && taskIsCompleted == true) ||
                              (isValid == false && taskIsCompleted == true)
                          ? null
                          : () {
                            if (isClaiming) return;

                            if (taskIsCompleted == false) {
                              _goHome(context);
                            } else {
                              _claimReward(context);
                            }
                          },
                  child:
                      isClaiming
                          ? const CircularProgressIndicator()
                          : Text(
                            taskIsCompleted == false
                                ? 'Complete Task'
                                : (txnHash != null && txnHash.isNotEmpty)
                                ? 'Claimed'
                                : isValid == false
                                ? 'Invalid Submission'
                                : !canClaim
                                ? 'Cooldown Active'
                                : 'Claim Reward',
                            style: Theme.of(context).typography.base.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              color: PaxColors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ).withPadding(bottom: 32),
      ],
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset('lib/assets/svgs/task_complete.svg'),
                  // Only show reward amount if task is valid or not yet completed
                  if (isValid != false || taskIsCompleted == false)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          taskIsCompleted == false
                              ? "You will earn"
                              : "You earned",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ).withPadding(bottom: 16, top: 16),
                        // Placeholder for reward amount and currency
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              amount != null
                                  ? TokenBalanceUtil.getLocaleFormattedAmount(
                                    amount,
                                  )
                                  : '--',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.normal,
                              ),
                            ).withPadding(right: 4),
                            if (tokenId != null)
                              SvgPicture.asset(
                                'lib/assets/svgs/currencies/${CurrencySymbolUtil.getNameForCurrency(tokenId)}.svg',
                                height: tokenId == 1 ? 25 : 20,
                              ),
                          ],
                        ),
                      ],
                    ).withPadding(bottom: 12),
                  // Only show task completion ID if task is valid or not yet completed
                  if (taskCompletionId != null &&
                      (isValid != false || taskIsCompleted == false))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Task Completion ID: ${taskCompletionId.substring(0, 8)}...",
                          style: TextStyle(
                            fontSize: 12,
                            color: PaxColors.darkGrey,
                          ),
                        ),
                        SizedBox(width: 8),
                        InkWell(
                          onTap: () async {
                            await Clipboard.setData(
                              ClipboardData(text: taskCompletionId),
                            );
                            if (context.mounted) {
                              showToast(
                                context: context,
                                location: ToastLocation.topCenter,
                                builder:
                                    (context, overlay) => Toast(
                                      toastColor: PaxColors.green,
                                      text: 'Task Completion ID copied',
                                      trailingIcon:
                                          FontAwesomeIcons.solidCircleCheck,
                                    ),
                              );
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: PaxColors.deepPurple.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FaIcon(
                              FontAwesomeIcons.copy,
                              size: 12,
                              color: PaxColors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ).withPadding(top: 16),

                  // Show cooldown information if there's a cooldown, task is completed, and task is valid
                  if (numberOfCooldownDays > 0 &&
                      taskIsCompleted == true &&
                      isValid != false)
                    Container(
                      margin: EdgeInsets.only(top: 24),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            canClaim
                                ? PaxColors.green.withValues(alpha: 0.1)
                                : PaxColors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: canClaim ? PaxColors.green : PaxColors.red,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                canClaim
                                    ? Icons.check_circle
                                    : Icons.access_time,
                                color:
                                    canClaim ? PaxColors.green : PaxColors.red,
                                size: 20,
                              ).withPadding(right: 8),
                              Text(
                                canClaim
                                    ? 'Cooldown Complete'
                                    : 'Cooldown Active',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      canClaim
                                          ? PaxColors.green
                                          : PaxColors.red,
                                ),
                              ),
                            ],
                          ).withPadding(bottom: canClaim ? 0 : 8),
                          if (!canClaim && remainingCooldownTime.isNotEmpty)
                            Text(
                              'You can claim this reward in $remainingCooldownTime',
                              style: TextStyle(
                                fontSize: 14,
                                color: PaxColors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          if (canClaim)
                            Text(
                              'You can now claim your reward!',
                              style: TextStyle(
                                fontSize: 14,
                                color: PaxColors.black,
                              ),
                              textAlign: TextAlign.center,
                            ).withPadding(top: 8),
                        ],
                      ),
                    ),

                  // Show invalid submission notice if isValid is false
                  if (isValid == false && taskIsCompleted == true)
                    Container(
                      margin: EdgeInsets.only(top: 24),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: PaxColors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: PaxColors.red, width: 1),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: PaxColors.red,
                                size: 20,
                              ).withPadding(right: 8),
                              Text(
                                'Invalid submission.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: PaxColors.red,
                                ),
                              ),
                            ],
                          ).withPadding(bottom: 8),
                          Text(
                            'Your task submission cannot be rewarded. Copy the task completion ID and contact support.',
                            style: TextStyle(
                              fontSize: 14,
                              color: PaxColors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class ClaimRewardView extends ConsumerStatefulWidget {
  const ClaimRewardView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ClaimRewardViewState();
}

class _ClaimRewardViewState extends ConsumerState<ClaimRewardView> {
  bool isClaiming = false;

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
                      (txnHash != null && txnHash.isNotEmpty)
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
                  if (taskCompletionId != null)
                    Text(
                      "Task Completion ID: ${taskCompletionId.substring(0, 8)}...",
                      style: TextStyle(fontSize: 12, color: PaxColors.darkGrey),
                    ).withPadding(top: 16),
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

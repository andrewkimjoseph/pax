import 'package:flutter/material.dart' show InkWell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';
import 'package:pax/providers/local/task_context/task_context_provider.dart';
import 'package:pax/providers/local/task_master_server_id_provider.dart';
import 'package:pax/providers/local/screening_state_provider.dart';
import 'package:pax/services/screening_service.dart';
import 'package:pax/services/blockchain/blockchain_service.dart';
import 'package:pax/utils/token_address_util.dart';
import 'package:pax/widgets/other_task_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Consumer;
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:pax/theming/colors.dart';

class TaskSummaryView extends ConsumerStatefulWidget {
  const TaskSummaryView({super.key});

  @override
  ConsumerState<TaskSummaryView> createState() => _TaskSummaryViewState();
}

class _TaskSummaryViewState extends ConsumerState<TaskSummaryView> {
  bool isLoading = true;
  bool _isProcessingScreening = false;

  @override
  void initState() {
    super.initState();
    // Reset screening state when the view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(screeningProvider.notifier).reset();
    });
  }

  void _showWithdrawalMethodDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Add a Withdrawal Method'),
            content: const Text(
              'To continue with tasks, you need to add a withdrawal method first. This is where your rewards will be sent.',
            ),
            actions: [
              // SecondaryButton(
              //   onPressed: () {
              //     Navigator.of(dialogContext).pop();
              //     // Go back to home
              //     context.pop();
              //   },
              //   child: const Text('Later'),
              // ),
              Align(
                alignment: Alignment.center,
                child: PrimaryButton(
                  onPressed: () {
                    final participantId =
                        ref.read(participantProvider).participant?.id;

                    ref.read(analyticsProvider).addWithdrawalMethodTapped({
                      "participantId": participantId,
                    });

                    Navigator.of(dialogContext).pop();
                    // Pop back to home first, then push withdrawal methods
                    context.pop();
                    context.push('/withdrawal-methods');
                  },
                  child: const Text('Add Withdrawal Method'),
                ),
              ),
            ],
          ),
    );
  }

  // Method to handle screening process
  Future<void> _processScreening(BuildContext context) async {
    if (_isProcessingScreening) return;
    if (!mounted) return;

    ref.read(analyticsProvider).continueWithTaskTapped();
    final currentTask = ref.read(taskContextProvider)?.task;
    if (currentTask == null) {
      if (!mounted) return;
      _showErrorDialog(context, 'Task not found');
      return;
    }

    final taskMasterServerWalletId = ref.read(taskMasterServerIdProvider);
    final serverWalletId = ref.read(paxAccountProvider).account?.serverWalletId;
    final participant = ref.read(participantProvider).participant;

    final paxAccount = ref.watch(paxAccountProvider).account;

    final participantId = ref.read(participantProvider).participant?.id;
    final taskManagerContractAddress = currentTask.managerContractAddress;

    final hasDeployedPaxAccount = paxAccount?.contractAddress != null;

    final participantIsComplete =
        (participant?.country != null &&
            participant?.dateOfBirth != null &&
            participant?.gender != null);

    final participantIsCompletelyComplete =
        participantIsComplete && hasDeployedPaxAccount;

    // If participant is not completely complete, show dialog and return
    if (!participantIsCompletelyComplete) {
      _showWithdrawalMethodDialog();
      return;
    }

    if (!mounted) return;
    setState(() {
      _isProcessingScreening = true;
    });

    // Show loading dialog
    if (!mounted) return;
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
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Letting you in...'),
                ],
              ),
            ),
          ),
    );

    try {
      if (!mounted) return;

      final hasBalance = await BlockchainService.hasSufficientBalance(
        taskManagerContractAddress!,
        TokenAddressUtil.getAddressForCurrency(currentTask.rewardCurrencyId!),
        currentTask.rewardAmountPerParticipant!.toDouble(),
        TokenAddressUtil.getDecimalsForCurrency(currentTask.rewardCurrencyId!),
      );

      if (!hasBalance) {
        throw Exception('Task manager contract has insufficient balance');
      }

      ref.read(analyticsProvider).screeningStarted({
        "taskId": currentTask.id,
        "taskManagerContractAddress": taskManagerContractAddress,
        "taskMasterServerWalletId": taskMasterServerWalletId,
      });

      if (!mounted) return;
      await ref
          .read(screeningServiceProvider)
          .screenParticipant(
            serverWalletId: serverWalletId!,
            taskId: currentTask.id,
            participantId: participantId!,
            taskManagerContractAddress: taskManagerContractAddress,
            taskMasterServerWalletId: taskMasterServerWalletId!,
          );

      if (!mounted) return;

      if (!context.mounted) return;
      // Dismiss loading dialog and navigate on success
      context.pop();

      String nextRoute = "";

      if (currentTask.actionText == 'Check Out App') {
        nextRoute = '/tasks/check-out-app';
      }

      if (currentTask.actionText == 'Fill A Form') {
        nextRoute = '/tasks/fill-a-form';
      }

      context.push(nextRoute);
    } catch (e) {
      if (!mounted) return;
      ref.read(analyticsProvider).screeningFailed({
        "taskId": currentTask.id,
        "taskManagerContractAddress": taskManagerContractAddress,
        "taskMasterServerWalletId": taskMasterServerWalletId,
        "error": e.toString(),
      });

      if (context.mounted) {
        // Dismiss loading dialog and show error
        context.pop();
        _showErrorDialog(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingScreening = false;
        });
      }
    }
  }

  // Error dialog
  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text('Screening failed'),
            content: Text(
              errorMessage,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              OutlineButton(
                onPressed: () {
                  context.pop();
                  context.pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTask = ref.watch(taskContextProvider)?.task;
    return Scaffold(
      headers: [
        AppBar(
          padding: EdgeInsets.all(8),
          backgroundColor: PaxColors.white,
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  context.pop();
                },
                child: SvgPicture.asset('lib/assets/svgs/arrow_left_long.svg'),
              ),
              Spacer(),
              Text(
                "${currentTask?.id.substring(0, 8)}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              Spacer(),
            ],
          ),
        ).withPadding(top: 16),
        Divider(color: PaxColors.lightGrey),
      ],
      footers: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 16),
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  // Use FormErrorBuilder for button state management
                  child: PrimaryButton(
                    onPressed:
                        _isProcessingScreening
                            ? null
                            : () => _processScreening(context),
                    child:
                        _isProcessingScreening
                            ? CircularProgressIndicator(onSurface: true)
                            : Text(
                              'Continue with task',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color: PaxColors.white,
                              ),
                            ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ],
      child: Column(
        children: [
          InkWell(
            onTap: () {
              context.push(
                '/tasks/task-summary/image-photo-view',
                extra: "lib/assets/images/tasks_by_canvassing.png",
              );
            },
            child: Container(
              height: 250, // Adjust height as needed
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "lib/assets/images/tasks_by_canvassing.png",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Divider(),
          OtherTaskCard().withPadding(all: 4),

          // Instructions Card
          if (currentTask?.instructions != null &&
              currentTask!.instructions!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: PaxColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: PaxColors.lightGrey.withValues(alpha: 0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: PaxColors.lightGrey.withValues(alpha: 0.15),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.listUl,
                        size: 18,
                        color: PaxColors.deepPurple,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Instructions",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: PaxColors.deepPurple,
                        ),
                      ),
                      Spacer(),
                      Visibility(
                        visible:
                            currentTask.actionText == 'Check Out Web App' ||
                            currentTask.actionText == 'Check Out Mobile App',
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: PaxColors.deepPurple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Preview",
                            style: TextStyle(
                              fontSize: 12,
                              color: PaxColors.deepPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: PaxColors.lightGrey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: PaxColors.lightGrey.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentTask.instructions!
                              .split('\n')
                              .take(2)
                              .join('\n'),
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 15,
                            height: 1.5,
                            color: PaxColors.black.withValues(alpha: 0.85),
                          ),
                        ),
                        if (currentTask.instructions!.split('\n').length >
                            2) ...[
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: PaxColors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: PaxColors.lightGrey.withValues(
                                      alpha: 0.5,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "See more when you continue",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: PaxColors.deepPurple,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    FaIcon(
                                      FontAwesomeIcons.angleRight,
                                      size: 12,
                                      color: PaxColors.deepPurple,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
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

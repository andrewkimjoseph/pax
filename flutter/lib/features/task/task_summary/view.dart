import 'package:flutter/material.dart' show InkWell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';
import 'package:pax/providers/local/task_context/main_task_context_provider.dart';
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
  ConsumerState<TaskSummaryView> createState() => _TaskViewState();
}

class _TaskViewState extends ConsumerState<TaskSummaryView> {
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

  // Method to handle screening process
  Future<void> _processScreening(BuildContext context) async {
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
    final participantId = ref.read(participantProvider).participant?.id;
    final taskManagerContractAddress = currentTask.managerContractAddress;

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
      context.go('/task-itself');
    } catch (e) {
      if (!mounted) return;
      ref.read(analyticsProvider).screeningFailed({
        "taskId": currentTask.id,
        "taskManagerContractAddress": taskManagerContractAddress,
        "taskMasterServerWalletId": taskMasterServerWalletId,
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
        return AlertDialog(
          title: Text('Screening failed'),
          content: Text(
            errorMessage,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
                context.pop();
              },
              child: Text('OK'),
            ),
          ],
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
          Container(
            height: 250, // Adjust height as needed
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/assets/images/tasks_by_canvassing.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Divider(),
          OtherTaskCard().withPadding(all: 4),
        ],
      ),
    );
  }
}

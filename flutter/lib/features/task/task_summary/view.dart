import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';
import 'package:pax/providers/local/task_context/main_task_context_provider.dart';
import 'package:pax/providers/local/task_master_server_id_provider.dart';
import 'package:pax/providers/local/screening_state_provider.dart';
import 'package:pax/services/screening_service.dart';
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
    final currentTask = ref.read(taskContextProvider)?.task;
    if (currentTask == null) {
      _showErrorDialog(context, 'Task not found');
      return;
    }

    final taskMasterServerWalletId = ref.read(taskMasterServerIdProvider);
    final serverWalletId = ref.read(paxAccountProvider).account?.serverWalletId;
    final participantId = ref.read(participantProvider).participant?.id;
    final taskManagerContractAddress = currentTask.managerContractAddress;

    setState(() {
      _isProcessingScreening = true;
    });

    // Call screening service
    try {
      await ref
          .read(screeningServiceProvider)
          .screenParticipant(
            serverWalletId: serverWalletId!,
            taskId: currentTask.id,
            participantId: participantId!,
            taskManagerContractAddress: taskManagerContractAddress!,
            taskMasterServerWalletId: taskMasterServerWalletId!,
          );

      // Show processing dialog
      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => _buildProcessingDialog(dialogContext),
        );
      }
    } catch (e) {
      if (context.mounted) {
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

  // Dialog showing processing state
  Widget _buildProcessingDialog(BuildContext dialogContext) {
    return Consumer(
      builder: (context, ref, _) {
        final screeningState = ref.watch(screeningProvider);

        // Handle different screening states
        if (screeningState.state == ScreeningState.complete) {
          // Dismiss the dialog after a short delay and navigate
          Future.delayed(Duration(milliseconds: 500), () {
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
              dialogContext.go('/task-itself');
            }
          });
        } else if (screeningState.state == ScreeningState.error) {
          // Dismiss the dialog after a short delay
          Future.delayed(Duration(milliseconds: 500), () {
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
              _showErrorDialog(
                dialogContext,
                screeningState.errorMessage ?? 'An unknown error occurred',
              );
            }
          });
        } else if (screeningState.state == ScreeningState.loading) {
          // Show loading indicator
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Letting you in...'),
              ],
            ),
          );
        }

        // Default case - show loading indicator
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Letting you in...'),
            ],
          ),
        );
      },
    );
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
              onPressed: () => Navigator.of(dialogContext).pop(),
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
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanDown: (details) {
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

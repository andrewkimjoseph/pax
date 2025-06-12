import 'package:flutter/material.dart' show InkWell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/providers/local/task_context/screening_context_provider.dart';
import 'package:pax/providers/local/reward_state_provider.dart';
import 'package:pax/services/reward_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Consumer;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:pax/theming/colors.dart';
import 'package:pax/providers/local/task_context/main_task_context_provider.dart';
import 'package:pax/providers/local/task_completion_state_provider.dart';
import 'package:pax/services/task_completion_service.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';

class TaskItselfView extends ConsumerStatefulWidget {
  const TaskItselfView({super.key});

  @override
  ConsumerState<TaskItselfView> createState() => _TaskItselfViewState();
}

class _TaskItselfViewState extends ConsumerState<TaskItselfView> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Reset task completion state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(taskCompletionProvider.notifier).reset();
      ref.read(rewardStateProvider.notifier).reset();
    });

    // Initialize the WebViewController with empty URL
    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                setState(() {
                  isLoading = true;
                });
              },
              onPageFinished: (String url) {
                setState(() {
                  isLoading = false;
                });
                // ref.read(analyticsProvider).taskLoadingComplete({
                //   "taskUrl": url,
                // });
              },
              onNavigationRequest: (NavigationRequest request) {
                // Check if the URL is a callback from the task
                if (request.url.startsWith('thepaxtask://')) {
                  // Handle the callback - mark task as complete
                  _handleTaskCompletion();
                  return NavigationDecision.prevent;
                }
                // Allow the WebView to handle regular web URLs
                return NavigationDecision.navigate;
              },
            ),
          );

    // Load the task URL after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTaskUrl();
    });
  }

  void _loadTaskUrl() {
    // Get task from context provider
    final taskContext = ref.read(taskContextProvider);
    final currentTask = taskContext?.task;
    final currentParticipant = ref.read(participantProvider).participant;

    if (currentTask == null || currentTask.link == null) {
      _showErrorDialog('Task or task link not found');
      return;
    }

    // Get the URL from the task
    final taskUrl = currentTask.link!;

    // Parse the original URI
    Uri uri = Uri.parse(taskUrl);

    // Add the authId query parameter to the existing parameters
    Map<String, dynamic> queryParams = Map<String, String>.from(
      uri.queryParameters,
    );
    queryParams['authId'] = currentParticipant?.id;
    // Create a new URI with the updated query parameters
    Uri updatedUri = uri.replace(queryParameters: queryParams);

    // Load the URL in the WebView
    controller.loadRequest(updatedUri);
  }

  // Handle task completion
  void _handleTaskCompletion() {
    final taskContext = ref.read(taskContextProvider);
    final currentTask = taskContext?.task;

    final screening = ref.read(screeningContextProvider)?.screening;

    if (currentTask == null) {
      _showErrorDialog('Task not found');
      return;
    }

    if (screening == null) {
      _showErrorDialog('Screening not found');
      return;
    }

    // Show dialog and start the completion process
    showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (dialogContext) => _buildCompletionDialog(
            dialogContext,
            screening.id,
            currentTask.id,
          ),
    );

    // Start the task completion process
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(taskCompletionServiceProvider)
          .markTaskAsComplete(
            screeningId: screening.id,
            taskId: currentTask.id,
          );
    });
  }

  // Dialog showing completion and rewarding process
  Widget _buildCompletionDialog(
    BuildContext dialogContext,
    String screeningId,
    String taskId,
  ) {
    return PopScope(
      canPop: false,
      child: Consumer(
        builder: (context, ref, _) {
          final completionState = ref.watch(taskCompletionProvider);
          final rewardState = ref.watch(rewardStateProvider);

          // If task completion is complete, start the rewarding process
          if (completionState.state == TaskCompletionState.complete &&
              rewardState.state == RewardState.initial) {
            // Get the task completion ID from the result
            final taskCompletionId = completionState.result?.taskCompletionId;

            ref.read(analyticsProvider).taskCompletionComplete({
              "taskId": taskId,
              "screeningId": screeningId,
              "taskCompletionId": taskCompletionId,
            });

            if (taskCompletionId != null) {
              // Schedule rewarding after the build cycle
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(analyticsProvider).rewardingStarted({
                  "taskId": taskId,
                  "screeningId": screeningId,
                  "taskCompletionId": taskCompletionId,
                });

                ref
                    .read(rewardServiceProvider)
                    .rewardParticipant(taskCompletionId: taskCompletionId);
              });
            }
          }

          // Check for reward completion or errors
          if (rewardState.state == RewardState.complete) {
            // Dismiss the dialog after a short delay and navigate
            Future.delayed(Duration(milliseconds: 500), () {
              if (dialogContext.mounted) {
                dialogContext.pop();
                context.pushReplacement('/task-complete');
              }
            });
          } else if (rewardState.state == RewardState.error) {
            final taskCompletionId = completionState.result?.taskCompletionId;

            ref.read(analyticsProvider).rewardingFailed({
              "taskId": taskId,
              "screeningId": screeningId,
              "taskCompletionId": taskCompletionId,
            });

            // Dismiss the dialog after a short delay
            Future.delayed(Duration(milliseconds: 500), () {
              if (dialogContext.mounted) {
                dialogContext.pop();
                _showErrorDialog(
                  rewardState.errorMessage ??
                      'An unknown error occurred during rewarding',
                );
              }
            });
          } else if (completionState.state == TaskCompletionState.error) {
            // Dismiss the dialog after a short delay
            Future.delayed(Duration(milliseconds: 500), () {
              if (dialogContext.mounted) {
                dialogContext.pop();
                _showErrorDialog(
                  completionState.errorMessage ?? 'An unknown error occurred',
                );
              }
            });
          }

          // Show appropriate loading message based on state
          String message = 'Processing...';
          if (completionState.state == TaskCompletionState.processing) {
            message = 'Completing your task...';
          } else if (rewardState.state == RewardState.rewarding) {
            message = 'Rewarding your account...';
          }

          // Show loading indicator with appropriate message
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator().withPadding(bottom: 24),
                Text(
                  message,
                  style: TextStyle(
                    color: PaxColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text('Task Error'),
            content: Text(errorMessage),
            actions: [
              OutlineButton(
                onPressed: () => context.go("/home"),
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
    final currentTask = ref.read(taskContextProvider)?.task;
    return Scaffold(
      headers: [
        AppBar(
          padding: EdgeInsets.all(8),
          backgroundColor: PaxColors.white,
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  context.go('/home');
                },
                child: SvgPicture.asset('lib/assets/svgs/arrow_left_long.svg'),
              ),
              Spacer(),
              Text(
                "${currentTask?.id.substring(0, 8)}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ).withPadding(right: 16),
              Spacer(),
            ],
          ),
        ).withPadding(top: 16),
        Divider(color: PaxColors.lightGrey),
      ],
      child: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

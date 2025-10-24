import 'package:flutter/material.dart' show InkWell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/providers/local/screening_context/screening_context_provider.dart';
import 'package:pax/widgets/task_timer.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Consumer;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:pax/theming/colors.dart';
import 'package:pax/providers/local/task_context/task_context_provider.dart';
import 'package:pax/providers/local/task_completion_state_provider.dart';
import 'package:pax/services/task_completion_service.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/utils/time_formatter.dart';
import 'package:pax/widgets/optimized_webview.dart';

class FillAFormView extends ConsumerStatefulWidget {
  const FillAFormView({super.key});

  @override
  ConsumerState<FillAFormView> createState() => _TaskItselfViewState();
}

class _TaskItselfViewState extends ConsumerState<FillAFormView> {
  late final WebViewController controller;
  bool isLoading = true;
  bool _isCompleting = false; // Add flag to track completion state

  @override
  void initState() {
    super.initState();
    // Reset task completion state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(taskCompletionProvider.notifier).reset();
    });

    // Initialize the WebViewController with empty URL
    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(PaxColors.white)
          ..setUserAgent(
            'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
          )
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
      _showErrorDialog(context, 'Task or task link not found');
      return;
    }

    // Get the URL from the task
    final taskUrl = currentTask.link!;

    // Parse the original URI
    Uri uri = Uri.parse(taskUrl);

    // Add query parameters to the URL
    Map<String, String?> queryParams = Map<String, String?>.from(
      uri.queryParameters,
    );

    // Add id if available
    if (currentParticipant?.id != null) {
      queryParams['id'] = currentParticipant?.id;
    }

    // Add gender if available
    if (currentParticipant?.gender != null) {
      queryParams['gender'] = currentParticipant?.gender;
    }

    // Add country if available
    if (currentParticipant?.country != null) {
      queryParams['country'] = currentParticipant?.country;
    }
    // Calculate age from dateOfBirth if available
    if (currentParticipant?.dateOfBirth != null) {
      final dateOfBirthAsDateTime = currentParticipant!.dateOfBirth!.toDate();
      final age = calculateAge(dateOfBirthAsDateTime);
      queryParams['age'] = age.toString();
    }
    // Create a new URI with the updated query parameters
    Uri updatedUri = uri.replace(queryParameters: queryParams);

    // Load the URL in the WebView
    controller.loadRequest(updatedUri);
  }

  // Handle task completion
  Future<void> _handleTaskCompletion() async {
    // Prevent multiple completion calls
    if (_isCompleting) return;
    _isCompleting = true;

    try {
      final taskContext = ref.read(taskContextProvider);
      final currentTask = taskContext?.task;
      final screeningContext = ref.read(screeningContextProvider);

      ref.read(analyticsProvider).taskCompletionStarted({
        "taskId": currentTask?.id,
        "screeningId": screeningContext?.screening?.id,
        "taskCompletionId": screeningContext?.screeningResult?.taskCompletionId,
      });

      if (currentTask == null) {
        ref.read(analyticsProvider).taskCompletionFailed({
          "taskId": currentTask?.id,
          "screeningId": screeningContext?.screening?.id,
          "taskCompletionId":
              screeningContext?.screeningResult?.taskCompletionId,
        });
        throw Exception('Task not found');
      }

      if (screeningContext?.screening == null) {
        ref.read(analyticsProvider).taskCompletionFailed({
          "taskId": currentTask.id,
          "screeningId": screeningContext?.screening?.id,
        });
        throw Exception('Screening not found');
      }

      // Show dialog and start the completion process
      showDialog(
        barrierDismissible: false,
        context: context,
        builder:
            (dialogContext) => _buildCompletionDialog(
              dialogContext,
              screeningContext?.screening?.id,
              currentTask.id,
            ),
      );

      // Start the task completion process
      await ref
          .read(taskCompletionServiceProvider)
          .markTaskAsComplete(
            screeningId: screeningContext?.screening?.id,
            taskId: currentTask.id,
          );
    } catch (e) {
      _isCompleting = false; // Reset flag on error
      if (mounted) {
        _showErrorDialog(context, e.toString());
      }
    }
  }

  // Dialog showing completion process (without rewarding)
  Widget _buildCompletionDialog(
    BuildContext dialogContext,
    String? screeningId,
    String taskId,
  ) {
    return PopScope(
      canPop: false,
      child: Consumer(
        builder: (context, ref, _) {
          final completionState = ref.watch(taskCompletionProvider);

          // Check for completion or errors
          if (completionState.state == TaskCompletionState.complete) {
            final taskCompletionId = completionState.result?.taskCompletionId;

            ref.read(analyticsProvider).taskCompletionComplete({
              "taskId": taskId,
              "screeningId": screeningId,
              "taskCompletionId": taskCompletionId,
            });

            // Dismiss the dialog after a short delay and navigate
            Future.delayed(Duration(milliseconds: 500), () {
              if (dialogContext.mounted) {
                if (dialogContext.canPop()) {
                  dialogContext.pop();
                }
                context.pushReplacement('/tasks/task-complete');
              }
            });
          } else if (completionState.state == TaskCompletionState.error) {
            // Dismiss the dialog after a short delay
            Future.delayed(Duration(milliseconds: 500), () {
              if (dialogContext.mounted) {
                dialogContext.pop();
                _showErrorDialog(
                  context,
                  completionState.errorMessage ?? 'An unknown error occurred',
                );
              }
            });
          }

          // Show loading indicator with appropriate message
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator().withPadding(bottom: 24),
                Text(
                  'Marking task as completed...',
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

  // Error dialog
  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text('Task Error'),
            content: Text(
              errorMessage,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
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
              Consumer(
                builder: (context, ref, _) {
                  final screening =
                      ref.watch(screeningContextProvider)?.screening;
                  if (screening?.timeCreated != null) {
                    return TaskTimer(
                      screeningTimeCreated: screening!.timeCreated!.toDate(),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
          ),
        ).withPadding(top: 16),
        Divider(color: PaxColors.lightGrey),
      ],
      child: PopScope(
        canPop: false,
        child: Stack(
          children: [
            OptimizedWebView(controller: controller, isLoading: isLoading),
            if (isLoading) Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

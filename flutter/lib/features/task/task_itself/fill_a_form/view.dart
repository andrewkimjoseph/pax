import 'package:flutter/material.dart' show InkWell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/providers/local/screening_context/screening_context_provider.dart';
import 'package:pax/widgets/task_timer.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Consumer;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
  InAppWebViewController? _webViewController;
  bool isLoading = true;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(taskCompletionProvider.notifier).reset();
    });
  }

  void _loadTaskUrl() {
    final taskContext = ref.read(taskContextProvider);
    final currentTask = taskContext?.task;
    final currentParticipant = ref.read(participantProvider).participant;

    if (currentTask == null || currentTask.link == null) {
      _showErrorDialog(context, 'Task or task link not found');
      return;
    }

    final taskUrl = currentTask.link!;
    Uri uri = Uri.parse(taskUrl);

    Map<String, String?> queryParams = Map<String, String?>.from(
      uri.queryParameters,
    );

    if (currentParticipant?.id != null) {
      queryParams['id'] = currentParticipant?.id;
    }
    if (currentParticipant?.gender != null) {
      queryParams['gender'] = currentParticipant?.gender;
    }
    if (currentParticipant?.country != null) {
      queryParams['country'] = currentParticipant?.country;
    }
    if (currentParticipant?.dateOfBirth != null) {
      final dateOfBirthAsDateTime = currentParticipant!.dateOfBirth!.toDate();
      final age = calculateAge(dateOfBirthAsDateTime);
      queryParams['age'] = age.toString();
    }

    Uri updatedUri = uri.replace(queryParameters: queryParams);

    _webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(updatedUri.toString())),
    );
  }

  Future<void> _handleTaskCompletion() async {
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

      await ref
          .read(taskCompletionServiceProvider)
          .markTaskAsComplete(
            screeningId: screeningContext?.screening?.id,
            taskId: currentTask.id,
          );
    } catch (e) {
      _isCompleting = false;
      if (mounted) {
        _showErrorDialog(context, e.toString());
      }
    }
  }

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

          if (completionState.state == TaskCompletionState.complete) {
            final taskCompletionId = completionState.result?.taskCompletionId;

            ref.read(analyticsProvider).taskCompletionComplete({
              "taskId": taskId,
              "screeningId": screeningId,
              "taskCompletionId": taskCompletionId,
            });

            Future.delayed(Duration(milliseconds: 500), () {
              if (dialogContext.mounted) {
                if (dialogContext.canPop()) {
                  dialogContext.pop();
                }
                context.pushReplacement('/tasks/task-complete');
              }
            });
          } else if (completionState.state == TaskCompletionState.error) {
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
            OptimizedWebView(
              onWebViewCreated: (controller) {
                _webViewController = controller;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _loadTaskUrl();
                });
              },
              onLoadStart: (controller, url) {
                setState(() {
                  isLoading = true;
                });
              },
              onLoadStop: (controller, url) {
                setState(() {
                  isLoading = false;
                });
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url?.toString() ?? '';
                if (url.startsWith('thepaxtask://')) {
                  _handleTaskCompletion();
                  return NavigationActionPolicy.CANCEL;
                }
                return NavigationActionPolicy.ALLOW;
              },
              isLoading: isLoading,
            ),
            if (isLoading) Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

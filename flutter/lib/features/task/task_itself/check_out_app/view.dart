import 'package:flutter/material.dart' show InkWell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/providers/local/task_context/task_context_provider.dart';
import 'package:pax/providers/local/screening_context/screening_context_provider.dart';
import 'package:pax/providers/local/task_completion_state_provider.dart';
import 'package:pax/services/task_completion_service.dart';
import 'package:pax/utils/time_formatter.dart';
import 'package:pax/utils/url_handler.dart';
import 'package:pax/widgets/other_task_card.dart';
import 'package:pax/widgets/task_timer.dart';
import 'package:pax/widgets/check_out_product_drawer.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Consumer;
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:pax/theming/colors.dart';

class CheckOutAppView extends ConsumerStatefulWidget {
  const CheckOutAppView({super.key});

  @override
  ConsumerState<CheckOutAppView> createState() => _CheckOutAppViewState();
}

class _CheckOutAppViewState extends ConsumerState<CheckOutAppView> {
  bool isLoading = true;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    // Reset task completion state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(taskCompletionProvider.notifier).reset();
    });
  }

  // Open confirmation drawer
  void _openConfirmationDrawer() {
    openDrawer(
      context: context,
      expands: false,
      builder: (context) {
        return CheckOutProductDrawer(onMarkCompleted: _handleTaskCompletion);
      },
      position: OverlayPosition.bottom,
    );
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

  // Handle feedback form click
  void _handleFeedbackFormClick(BuildContext context, String feedbackUrl) {
    final taskContext = ref.read(taskContextProvider);
    final screeningContext = ref.read(screeningContextProvider);
    final currentParticipant = ref.read(participantProvider).participant;

    // Parse the original URI
    Uri uri = Uri.parse(feedbackUrl);

    // Add query parameters
    Map<String, String?> queryParams = Map<String, String?>.from(
      uri.queryParameters,
    );

    // Add participant info first
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

    // Add task-related IDs last
    final taskCompletionId =
        ref.read(taskCompletionProvider).result?.taskCompletionId;
    if (taskCompletionId != null) {
      queryParams['taskCompletionId'] = taskCompletionId;
    }
    queryParams['taskId'] = taskContext!.task.id;
    if (screeningContext?.screening?.id != null) {
      queryParams['screeningId'] = screeningContext!.screening!.id;
    }

    // Create updated URI with all parameters
    Uri updatedUri = uri.replace(queryParameters: queryParams);

    UrlHandler.launchCustomTab(context, updatedUri.toString());
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
              ),
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
      footers: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 16),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (currentTask?.link != null &&
                  currentTask!.link!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: PrimaryButton(
                      onPressed:
                          _isCompleting
                              ? null
                              : () => UrlHandler.launchCustomTab(
                                context,
                                currentTask.link!,
                              ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.link,
                            size: 18,
                            color: PaxColors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Open product link',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: PaxColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (currentTask?.feedback != null &&
                  currentTask!.feedback!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: PrimaryButton(
                      onPressed:
                          _isCompleting
                              ? null
                              : () => _handleFeedbackFormClick(
                                context,
                                currentTask.feedback!,
                              ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.solidCommentDots,
                            size: 18,
                            color: PaxColors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Open feedback form',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: PaxColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlineButton(
                    onPressed:
                        _isCompleting ? null : () => _openConfirmationDrawer(),
                    child:
                        _isCompleting
                            ? CircularProgressIndicator(onSurface: true)
                            : Text(
                              'Mark task as completed',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color: PaxColors.deepPurple,
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
      child: PopScope(
        canPop: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image Section
              InkWell(
                onTap: () {
                  context.push(
                    '/tasks/check-out-app/image-photo-view',
                    extra: "lib/assets/images/tasks_by_canvassing.png",
                  );
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        "lib/assets/images/tasks_by_canvassing.png",
                      ),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),

              // Task Card Section
              OtherTaskCard().withPadding(horizontal: 4),

              // Content Section
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instructions Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
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
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            currentTask?.instructions ??
                                "No instructions provided.",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 15,
                              height: 1.5,
                              color: PaxColors.black.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ).withPadding(bottom: 12),

                    // Video Guide Card
                    // if (currentTask?.feedback != null &&
                    //     currentTask!.feedback!.isNotEmpty)
                    //   Container(
                    //     width: double.infinity,
                    //     padding: EdgeInsets.all(16),
                    //     decoration: BoxDecoration(
                    //       color: PaxColors.white,
                    //       borderRadius: BorderRadius.circular(12),
                    //       border: Border.all(
                    //         color: PaxColors.lightGrey.withValues(alpha: 0.5),
                    //         width: 1,
                    //       ),
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: PaxColors.lightGrey.withValues(
                    //             alpha: 0.15,
                    //           ),
                    //           spreadRadius: 0,
                    //           blurRadius: 8,
                    //           offset: Offset(0, 2),
                    //         ),
                    //       ],
                    //     ),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Row(
                    //           children: [
                    //             Icon(
                    //               Icons.play_circle_outline_rounded,
                    //               size: 22,
                    //               color: PaxColors.deepPurple,
                    //             ),
                    //             SizedBox(width: 8),
                    //             Text(
                    //               "Video Guide",
                    //               style: TextStyle(
                    //                 fontWeight: FontWeight.w600,
                    //                 fontSize: 18,
                    //                 color: PaxColors.deepPurple,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //         SizedBox(height: 12),
                    //         Row(
                    //           children: [
                    //             Expanded(
                    //               child: InkWell(
                    //                 onTap: () {
                    //                   UrlHandler.launchCustomTab(
                    //                     context,
                    //                     currentTask.feedback!,
                    //                   );
                    //                 },
                    //                 child: Text(
                    //                   currentTask.feedback ?? "",
                    //                   style: TextStyle(
                    //                     fontWeight: FontWeight.normal,
                    //                     fontSize: 14,
                    //                     color: PaxColors.blue,
                    //                     decoration: TextDecoration.underline,
                    //                   ),
                    //                   maxLines: 2,
                    //                   overflow: TextOverflow.ellipsis,
                    //                 ),
                    //               ),
                    //             ),
                    //             SizedBox(width: 12),
                    //             InkWell(
                    //               onTap: () async {
                    //                 if (currentTask.feedback != null &&
                    //                     currentTask.feedback!.isNotEmpty) {
                    //                   await Clipboard.setData(
                    //                     ClipboardData(
                    //                       text: currentTask.feedback!,
                    //                     ),
                    //                   );
                    //                   if (context.mounted) {
                    //                     showToast(
                    //                       context: context,
                    //                       location: ToastLocation.topCenter,
                    //                       builder:
                    //                           (context, overlay) => Toast(
                    //                             toastColor: PaxColors.green,
                    //                             text: 'Video link copied',
                    //                             trailingIcon:
                    //                                 FontAwesomeIcons
                    //                                     .solidCircleCheck,
                    //                           ),
                    //                     );
                    //                   }
                    //                 }
                    //               },
                    //               child: Container(
                    //                 padding: EdgeInsets.all(8),
                    //                 decoration: BoxDecoration(
                    //                   color: PaxColors.deepPurple.withValues(
                    //                     alpha: 0.1,
                    //                   ),
                    //                   borderRadius: BorderRadius.circular(8),
                    //                 ),
                    //                 child: FaIcon(
                    //                   FontAwesomeIcons.copy,
                    //                   size: 14,
                    //                   color: PaxColors.deepPurple,
                    //                 ),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ],
                    //     ),
                    //   ).withPadding(bottom: 12),

                    // Payment Terms Card
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

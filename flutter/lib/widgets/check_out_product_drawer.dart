import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/local/screening_context/screening_context_provider.dart';
import 'package:pax/providers/local/task_context/task_context_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pax/theming/colors.dart';

class CheckOutProductDrawer extends ConsumerStatefulWidget {
  const CheckOutProductDrawer({required this.onMarkCompleted, super.key});

  final VoidCallback onMarkCompleted;

  @override
  ConsumerState<CheckOutProductDrawer> createState() =>
      _CheckOutProductDrawerState();
}

class _CheckOutProductDrawerState extends ConsumerState<CheckOutProductDrawer> {
  CheckboxState _checkedOutProductState = CheckboxState.unchecked;
  CheckboxState _filledFeedbackFormState = CheckboxState.unchecked;

  bool get _canMarkCompleted =>
      _checkedOutProductState == CheckboxState.checked &&
      _filledFeedbackFormState == CheckboxState.checked;

  @override
  Widget build(BuildContext context) {
    final taskId = ref.read(taskContextProvider)?.task.id;
    final screeningId = ref.read(screeningContextProvider)?.screening?.id;
    final taskCompletionId =
        ref.read(screeningContextProvider)?.screeningResult?.taskCompletionId;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PaxColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            'Confirm Task Completion',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: PaxColors.black,
            ),
          ).withPadding(bottom: 12),

          // Subtitle
          Text(
            'Please confirm you have completed the following:',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 15,
              color: PaxColors.black.withValues(alpha: 0.7),
            ),
          ).withPadding(bottom: 16),

          // Caution message
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PaxColors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: PaxColors.red.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.triangleExclamation,
                  size: 16,
                  color: PaxColors.red,
                ).withPadding(right: 8, top: 2),
                Expanded(
                  child: Text(
                    'All task submissions are reviewed. Invalid submissions may result in account disabling.',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: PaxColors.red,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ).withPadding(bottom: 24),

          // Checkbox 1: Checked out the product
          Checkbox(
            state: _checkedOutProductState,
            onChanged: (value) {
              setState(() {
                _checkedOutProductState = value;
              });
            },
            trailing: Text(
              'I have checked out the product in the link',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 15,
                color: PaxColors.black,
              ),
            ),
          ).withPadding(bottom: 24),

          // Checkbox 2: Filled in the feedback form
          Checkbox(
            state: _filledFeedbackFormState,
            onChanged: (value) {
              setState(() {
                _filledFeedbackFormState = value;
              });
            },
            trailing: Text(
              'I have filled in the feedback form',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 15,
                color: PaxColors.black,
              ),
            ),
          ).withPadding(bottom: 40),

          // Mark as completed button (less prominent)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlineButton(
              onPressed:
                  _canMarkCompleted
                      ? () {
                        ref.read(analyticsProvider).completeTaskTapped({
                          "taskId": taskId,
                          "screeningId": screeningId,
                          "taskCompletionId": taskCompletionId,
                        });

                        closeOverlay(context);
                        widget.onMarkCompleted();
                      }
                      : null,
              child: Text(
                'Complete task',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  color: PaxColors.deepPurple,
                ),
              ),
            ),
          ).withPadding(bottom: 12),

          // Continue button (prominent)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: PrimaryButton(
              onPressed: () {
                ref.read(analyticsProvider).continueDoingTheTaskTapped({
                  "taskId": taskId,
                  "screeningId": screeningId,
                  "taskCompletionId": taskCompletionId,
                });
                closeOverlay(context);
              },
              child: Text(
                'Continue doing the task',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  color: PaxColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

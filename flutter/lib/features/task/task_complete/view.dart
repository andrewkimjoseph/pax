// ignore_for_file: unused_import

import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:pax/features/home/dashboard/view.dart';
import 'package:pax/features/home/tasks/view.dart';
import 'package:pax/features/onboarding/view_model.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/providers/local/activity_providers.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/providers/local/task_context/main_task_context_provider.dart';
import 'package:pax/providers/local/task_completion_state_provider.dart';
import 'package:pax/utils/currency_symbol.dart';
import 'package:pax/utils/token_balance_util.dart';
import 'package:pax/widgets/account/account_option_card.dart';
import 'package:pax/widgets/help_and_support.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_confetti/flutter_confetti.dart';

class TaskCompleteView extends ConsumerStatefulWidget {
  const TaskCompleteView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TaskCompleteViewState();
}

class _TaskCompleteViewState extends ConsumerState<TaskCompleteView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Display confetti animation after UI has rendered
      Confetti.launch(
        context,
        options: const ConfettiOptions(
          colors: PaxColors.orangeToPinkGradient,
          particleCount: 100,
          spread: 70,
          y: 0.6,
        ),
      );

      // Clear states after a delay
      Future.delayed(Duration(seconds: 3), () {
        ref.read(taskContextProvider.notifier).clear();
        ref.read(taskCompletionProvider.notifier).reset();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Get task and completion information
    final taskContext = ref.read(taskContextProvider);
    final currentTask = taskContext?.task;
    final taskCompletion = ref.read(taskCompletionProvider);

    // Determine reward amount to display
    final String rewardAmount =
        "${currentTask?.rewardAmountPerParticipant}"; // Default fallback

    return Scaffold(
      resizeToAvoidBottomInset: false,
      headers: [
        AppBar(
          padding: EdgeInsets.all(8),
          leading: [],
          backgroundColor: PaxColors.white,
          // child: Row(children: [Icon(Icons.close), Spacer()]),
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
                child: PrimaryButton(
                  onPressed: () {
                    ref.read(analyticsProvider).okOnTaskCompleteTapped({
                      "taskId": currentTask?.id,
                      "taskTitle": currentTask?.title,
                      "taskCompletionId":
                          taskCompletion.result?.taskCompletionId,
                    });
                    context.pushReplacement('/home');
                  },
                  child: Text(
                    'OK',
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

      // Use Column as the main container
      child: Column(
        children: [
          // Fixed-size content area (not scrollable)
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset('lib/assets/svgs/task_complete.svg'),

                  // Reduced padding
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "You just earned",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ).withPadding(bottom: 16, top: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Text(
                            TokenBalanceUtil.getLocaleFormattedAmount(
                              num.parse(rewardAmount),
                            ),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.normal,
                            ),
                          ).withPadding(right: 4),
                          SvgPicture.asset(
                            'lib/assets/svgs/currencies/${CurrencySymbolUtil.getNameForCurrency(currentTask?.rewardCurrencyId ?? 1)}.svg',
                            height: 25,
                          ),
                        ],
                      ),
                    ],
                  ).withPadding(bottom: 12), // Reduced padding
                  // Display task completion ID if available (optional)
                  if (taskCompletion.result?.taskCompletionId != null)
                    Text(
                      "Completion ID: ${taskCompletion.result!.taskCompletionId.substring(0, 8)}...",
                      style: TextStyle(fontSize: 12, color: PaxColors.darkGrey),
                    ).withPadding(top: 16),

                  Spacer(),
                ],
              ),
            ),
          ),

          // Fixed button at the bottom
        ],
      ),
    );
  }
}

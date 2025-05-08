// ignore_for_file: unused_import

import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:pax/features/home/dashboard/view.dart';
import 'package:pax/features/home/tasks/view.dart';
import 'package:pax/features/onboarding/view_model.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/widgets/account_option_card.dart';
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
  String? genderValue;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Display dialog after UI has rerendered
      Confetti.launch(
        context,
        options: const ConfettiOptions(
          colors: PaxColors.orangeToPinkGradient,
          particleCount: 100,
          spread: 70,
          y: 0.6,
        ),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                      ).withPadding(bottom: 16),
                      Text(
                        "G\$ 0.01",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ).withPadding(bottom: 12), // Reduced padding

                  Spacer(),
                ],
              ),
            ),
          ),

          // Fixed button at the bottom
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
                      context.pushReplacement('/');

                      // Confetti.launch(
                      //   context,
                      //   options: const ConfettiOptions(
                      //     colors: PaxColors.orangeToPinkGradient,
                      //     particleCount: 100,
                      //     spread: 70,
                      //     y: 0.6,
                      //   ),
                      // );
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
          ),
        ],
      ),
    );
  }
}

// String? selectedValue;
// @override
// Widget build(BuildContext context) {
//   return 
// }


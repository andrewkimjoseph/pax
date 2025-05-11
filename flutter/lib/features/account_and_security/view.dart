// ignore_for_file: unused_import

import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:pax/features/home/achievements/view.dart';
import 'package:pax/features/home/dashboard/view.dart';
import 'package:pax/features/home/tasks/view.dart';
import 'package:pax/features/onboarding/view_model.dart';
import 'package:pax/widgets/account_and_security_card.dart';
import 'package:pax/widgets/account_option_card.dart';
import 'package:pax/widgets/help_and_support.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../theming/colors.dart' show PaxColors;
import '../../utils/clipper.dart';

class AccountAndSecurityView extends ConsumerStatefulWidget {
  const AccountAndSecurityView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HelpAndSupportViewState();
}

class _HelpAndSupportViewState extends ConsumerState<AccountAndSecurityView> {
  String? selectedValue;
  String? genderValue;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                "Account & Security",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ).withPadding(right: 16),
              Spacer(),
            ],
          ),
        ).withPadding(top: 16),
        Divider(color: PaxColors.lightGrey),
      ],

      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: PaxColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PaxColors.lightLilac, width: 1),
              ),
              child: Column(
                spacing: 24,
                children: [
                  GestureDetector(
                    onPanDown: (details) {
                      openDrawer(
                        context: context,
                        transformBackdrop: false,
                        expands: false,
                        builder: (context) {
                          return Container(
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Delete account",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ).withPadding(bottom: 8),

                                    Divider().withPadding(top: 8, bottom: 8),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Are you sure you want to delete your account?",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ).withPadding(top: 8, bottom: 32),

                                    Divider().withPadding(top: 8, bottom: 8),
                                  ],
                                ).withPadding(left: 16, right: 16),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.4,
                                      height: 48,
                                      child: Button(
                                        style: const ButtonStyle.outline()
                                            .withBackgroundColor(
                                              color: PaxColors.lightGrey,
                                              // hoverColor: Colors.purple,
                                            )
                                            .withBorder(
                                              border: Border.all(
                                                color: Colors.transparent,
                                              ),
                                            ),
                                        onPressed: () {
                                          closeDrawer(context);

                                          // Handle skip action
                                          // onboardingViewModel.jumpToPage(2);
                                        },
                                        child: Text(
                                          'Cancel',
                                          style: Theme.of(
                                            context,
                                          ).typography.base.copyWith(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14,
                                            color:
                                                PaxColors
                                                    .deepPurple, // The purple color from your images
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.4,
                                      height: 48,
                                      child: PrimaryButton(
                                        onPressed: () {
                                          context.pushReplacement(
                                            '/onboarding',
                                          );
                                          // if (onboardingViewModel.isLastPage) {
                                          //   // Handle completion
                                          //   onboardingViewModel.completeOnboarding();
                                          // } else {
                                          //   // Go to next page
                                          //   onboardingViewModel.goToNextPage();
                                          // }
                                        },
                                        child: Text(
                                          'Yes, delete',
                                          style: Theme.of(
                                            context,
                                          ).typography.base.copyWith(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14,
                                            color:
                                                PaxColors
                                                    .white, // The purple color from your images
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ).withPadding(bottom: 32);
                        },
                        position: OverlayPosition.bottom,
                      );
                    },
                    child: AccountAndSecurityCard('Delete Account'),
                  ),

                  // GestureDetector(
                  //   onPanDown: (details) {
                  //     context.push("/help-and-support/contact-support");
                  //   },
                  //   child: HelpAndSupportCard('Contact Support'),
                  // ),
                  // HelpAndSupportCard('Privacy Policy'),
                  // HelpAndSupportCard('Terms of Service'),
                  // HelpAndSupportCard('About Us'),
                ],
              ),
            ),
          ],
        ),
      ).withPadding(all: 8),
    );
  }
}

// String? selectedValue;
// @override
// Widget build(BuildContext context) {
//   return 
// }


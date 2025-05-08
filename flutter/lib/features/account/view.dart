import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/features/account_and_security/view.dart';
import 'package:pax/widgets/account_option_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;

import '../../theming/colors.dart' show PaxColors;

class AccountView extends ConsumerStatefulWidget {
  const AccountView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountViewState();
}

class _AccountViewState extends ConsumerState<AccountView> {
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
          header: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Account',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  color: PaxColors.black, // The purple color from your images
                ),
              ),
            ],
          ),
        ),
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Text(
                                '854',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: PaxColors.black,
                                ),
                              ).withPadding(bottom: 4),
                              Text(
                                'Completed Surveys',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  color: PaxColors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Text(
                                "G\$ 100",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: PaxColors.black,
                                ),
                              ).withPadding(bottom: 4),
                              Text(
                                'Lifetime Earnings',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  color: PaxColors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ).withPadding(bottom: 8, top: 8),
                ],
              ),
            ).withPadding(bottom: 8),
            Container(
              padding: EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: PaxColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PaxColors.lightLilac, width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Avatar(
                        initials: Avatar.getInitials('sunarya-thito'),
                        provider: const NetworkImage(
                          'https://avatars.githubusercontent.com/u/64018564?v=4',
                        ),
                      ).withPadding(right: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Andrew Kim',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: PaxColors.black,
                            ),
                          ).withPadding(bottom: 4),
                          Text(
                            'andrewk@thecanvassing@xyz',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: PaxColors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).withPadding(bottom: 8, top: 8),

                  Divider().withPadding(top: 8, bottom: 16),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     SvgPicture.asset(
                  //       'lib/assets/svgs/clock_icon.svg',
                  //     ).withPadding(right: 8),
                  //     Expanded(
                  //       child: Text(
                  //         'My Profile',
                  //         style: TextStyle(
                  //           fontSize: 16,
                  //           color: PaxColors.black,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ).withPadding(bottom: 8),
                  //     ),
                  //     Icon(Icons.arrow_forward_ios_outlined).withPadding(left: 8),
                  //   ],
                  // ).withPadding(bottom: 8),
                  GestureDetector(
                    onPanDown: (details) {
                      context.push("/profile");
                    },
                    child: AccountOptionCard(
                      'profile',
                      true,
                    ).withPadding(bottom: 28),
                  ),
                  GestureDetector(
                    onPanDown: (details) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountAndSecurityView(),
                        ),
                      );
                    },
                    child: AccountOptionCard(
                      'account',
                      true,
                    ).withPadding(bottom: 28),
                  ),
                  GestureDetector(
                    onPanDown: (details) {
                      context.push("/payment-methods");
                    },
                    child: AccountOptionCard(
                      'payment_methods',
                      true,
                    ).withPadding(bottom: 28),
                  ),
                  GestureDetector(
                    onPanDown: (details) {
                      context.push("/help-and-support");
                    },
                    child: AccountOptionCard(
                      'help_and_support',
                      true,
                    ).withPadding(bottom: 28),
                  ),

                  GestureDetector(
                    onPanDown: (details) {
                      open(context, 0);
                    },
                    child: AccountOptionCard('logout', true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).withPadding(all: 8),
    );
  }

  void open(BuildContext context, int count) {
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Logout",
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Are you sure you want to log out?",
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 48,
                    child: Button(
                      style: const ButtonStyle.outline()
                          .withBackgroundColor(
                            color: PaxColors.lightGrey,
                            // hoverColor: Colors.purple,
                          )
                          .withBorder(
                            border: Border.all(color: Colors.transparent),
                          ),
                      onPressed: () {
                        closeDrawer(context);

                        // Handle skip action
                        // onboardingViewModel.jumpToPage(2);
                      },
                      child: Text(
                        'Cancel',
                        style: Theme.of(context).typography.base.copyWith(
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
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 48,
                    child: PrimaryButton(
                      onPressed: () {
                        context.pushReplacement('/onboarding');
                        // if (onboardingViewModel.isLastPage) {
                        //   // Handle completion
                        //   onboardingViewModel.completeOnboarding();
                        // } else {
                        //   // Go to next page
                        //   onboardingViewModel.goToNextPage();
                        // }
                      },
                      child: Text(
                        'Yes, Logout',
                        style: Theme.of(context).typography.base.copyWith(
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
  }
}

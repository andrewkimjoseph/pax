import 'package:flutter/material.dart' show Divider, InkWell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/features/account_and_security/view.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/providers/local/activity_providers.dart';
import 'package:pax/utils/token_balance_util.dart';
import 'package:pax/widgets/account/account_option_card.dart';
import 'package:pax/widgets/toast.dart';
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
    final participant = ref.watch(participantProvider).participant;
    final tasksCount = ref.watch(totalTaskCompletionsProvider);
    // Use with: tasksCount.when(data: (count) => Text('$count'), ...)

    // Access total G$ earned
    final totalGoodDollars = ref.watch(totalGoodDollarTokensEarnedProvider);
    return Scaffold(
      headers: [
        AppBar(
          padding: EdgeInsets.all(8),
          height: 50,

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
                              tasksCount
                                  .when(
                                    data:
                                        (count) => Text(
                                          count.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: PaxColors.black,
                                          ),
                                        ),
                                    loading:
                                        () => Text(
                                          '...',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: PaxColors.black,
                                          ),
                                        ),
                                    error:
                                        (_, __) => Text(
                                          '0',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: PaxColors.black,
                                          ),
                                        ),
                                  )
                                  .withPadding(bottom: 4),
                              Text(
                                'Completed Tasks',
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
                              totalGoodDollars
                                  .when(
                                    data:
                                        (amount) => Row(
                                          children: [
                                            Text(
                                              TokenBalanceUtil.getLocaleFormattedAmount(
                                                amount,
                                              ),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: PaxColors.black,
                                              ),
                                            ).withPadding(right: 2),
                                            SvgPicture.asset(
                                              'lib/assets/svgs/currencies/good_dollar.svg',
                                              height: 20,
                                            ),
                                          ],
                                        ),
                                    loading:
                                        () => Text(
                                          "G\$ ...",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: PaxColors.black,
                                          ),
                                        ),
                                    error:
                                        (_, __) => Text(
                                          "G\$ 0.00",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: PaxColors.black,
                                          ),
                                        ),
                                  )
                                  .withPadding(bottom: 4),
                              Text(
                                'Lifetime G\$ Earnings',
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
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                PaxColors.deepPurple, // Change color as needed
                            width: 2.5, // Adjust border thickness as needed
                          ),
                        ),
                        child: Avatar(
                          initials: Avatar.getInitials(
                            participant?.displayName?.split(" ").first ??
                                "Participant",
                          ),
                          provider:
                              participant != null
                                  ? NetworkImage(participant.profilePictureURI!)
                                  : null,
                        ),
                      ).withPadding(right: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            participant?.displayName ?? "",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: PaxColors.black,
                            ),
                          ).withPadding(bottom: 4),
                          Text(
                            participant?.emailAddress ?? "",
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
                  InkWell(
                    onTap: () {
                      context.push("/profile");
                    },
                    child: AccountOptionCard(
                      'profile',
                      true,
                    ).withPadding(bottom: 28),
                  ),
                  InkWell(
                    onTap: () {
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
                  InkWell(
                    onTap: () {
                      context.push("/payment-methods");
                    },
                    child: AccountOptionCard(
                      'payment_methods',
                      true,
                    ).withPadding(bottom: 28),
                  ),
                  InkWell(
                    onTap: () {
                      context.push("/help-and-support");
                    },
                    child: AccountOptionCard(
                      'help_and_support',
                      true,
                    ).withPadding(bottom: 28),
                  ),

                  InkWell(
                    onTap: () {
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
                      onPressed: () async {
                        closeDrawer(context);

                        // Show toast immediately before starting the logout process
                        showSuccessToast(context);

                        // Small delay to ensure toast is visible before redirect
                        await Future.delayed(const Duration(milliseconds: 300));

                        // Then initiate logout
                        ref.read(authProvider.notifier).signOut();
                      },
                      child: Text(
                        'Yes, Logout',
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
            ],
          ),
        ).withPadding(bottom: 32);
      },
      position: OverlayPosition.bottom,
    );
  }

  void showSuccessToast(BuildContext toastContext) {
    showToast(
      context: context,
      location: ToastLocation.topCenter,
      builder:
          (context, overlay) => Toast(
            leadingIcon: FontAwesomeIcons.google,
            toastColor: PaxColors.green,
            text: 'Sign-out complete',
            trailingIcon: FontAwesomeIcons.solidCircleCheck,
          ),
    );
  }
}

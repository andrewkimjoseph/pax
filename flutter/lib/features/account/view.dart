import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' show Divider, InkWell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/providers/local/activity_providers.dart';
import 'package:pax/utils/token_balance_util.dart';
import 'package:pax/widgets/account/account_option_card.dart';
import 'package:pax/widgets/logout/logout_drawer.dart';
import 'package:pax/widgets/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/auth/auth_provider.dart';

import '../../theming/colors.dart' show PaxColors;

class AccountView extends ConsumerStatefulWidget {
  const AccountView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountViewState();
}

class _AccountViewState extends ConsumerState<AccountView> {
  bool isLoggingOut = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final participantState = ref.watch(participantProvider);
    final participant = participantState.participant;
    final tasksCount = ref.watch(totalTaskCompletionsProvider);
    final totalGoodDollars = ref.watch(totalGoodDollarTokensEarnedProvider);

    // final version = ref
    //     .watch(appVersionConfigProvider)
    //     .when(
    //       data: (data) => data.currentVersion,
    //       loading: () => '...',
    //       error: (_, __) => '...',
    //     );

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
                  color: PaxColors.black,
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
              padding: EdgeInsets.all(8),
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
                            color: PaxColors.deepPurple,
                            width: 2.5,
                          ),
                        ),
                        child: Avatar(
                          initials: Avatar.getInitials(
                            participant?.displayName?.split(" ").first ??
                                "Participant",
                          ),
                          provider:
                              participant != null
                                  ? CachedNetworkImageProvider(
                                    participant.profilePictureURI!,
                                  )
                                  : null,
                        ),
                      ).withPadding(right: 8),
                      Expanded(
                        child: Column(
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
                      ),
                    ],
                  ).withPadding(bottom: 8, top: 8),
                  Divider().withPadding(top: 8, bottom: 16),
                  InkWell(
                    onTap: () {
                      ref.read(analyticsProvider).myProfileTapped();
                      context.push("/profile");
                    },
                    child: AccountOptionCard(
                      'profile',
                      true,
                    ).withPadding(bottom: 28),
                  ),
                  // InkWell(
                  //   onTap: () {
                  //     ref.read(analyticsProvider).accountAndSecurityTapped();
                  //     context.push('/account-and-security');
                  //   },
                  //   child: AccountOptionCard(
                  //     'account',
                  //     true,
                  //   ).withPadding(bottom: 28),
                  // ),
                  InkWell(
                    onTap: () {
                      ref.read(analyticsProvider).paymentMethodsTapped();
                      context.push("/payment-methods");
                    },
                    child: AccountOptionCard(
                      'payment_methods',
                      true,
                    ).withPadding(bottom: 28),
                  ),
                  InkWell(
                    onTap: () {
                      ref.read(analyticsProvider).helpAndSupportTapped();
                      context.push("/help-and-support");
                    },
                    child: AccountOptionCard(
                      'help_and_support',
                      true,
                    ).withPadding(bottom: 28),
                  ),
                  InkWell(
                    onTap: () {
                      ref.read(analyticsProvider).logoutTapped();
                      _showLogoutDrawer(context);
                    },
                    child: AccountOptionCard('logout', true),
                  ),
                ],
              ),
            ),

            // Text(
            //   "Pax - v$version",
            //   style: TextStyle(
            //     fontWeight: FontWeight.normal,
            //     fontSize: 12,
            //     color: PaxColors.black,
            //   ),
            // ).withPadding(top: 8).withAlign(Alignment.centerLeft),
          ],
        ),
      ).withPadding(horizontal: 8, bottom: 8),
    );
  }

  void _showLogoutDrawer(BuildContext rootContext) {
    openDrawer(
      context: rootContext,
      transformBackdrop: false,
      expands: false,
      barrierDismissible: false,
      builder: (drawerContext) {
        return LogOutDrawer(
          onClose: () => closeDrawer(drawerContext),
          rootContext: rootContext,
          onLogoutConfirmed: () async {
            showSuccessToast(rootContext);
            await Future.delayed(const Duration(milliseconds: 2000));
            await ref.read(authProvider.notifier).signOut();
            ref.read(analyticsProvider).logoutComplete();
          },
        );
      },
      position: OverlayPosition.bottom,
    );
  }

  void showSuccessToast(BuildContext toastContext) {
    showToast(
      context: toastContext,
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

// ignore_for_file: unused_import

import 'package:flutter/material.dart' show Divider, InkWell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:pax/features/home/achievements/view.dart';
import 'package:pax/features/home/dashboard/view.dart';
import 'package:pax/features/home/tasks/view.dart';
import 'package:pax/features/onboarding/view_model.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/providers/account/account_deletion_provider.dart';
import 'package:pax/providers/route/selected_index_provider.dart';
import 'package:pax/widgets/account/account_and_security_card.dart';
import 'package:pax/widgets/account/account_option_card.dart';
import 'package:pax/widgets/help_and_support.dart';
import 'package:pax/widgets/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pax/exports/shadcn.dart' hide Divider;

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
    // Reset the deletion state when the view is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accountDeletionProvider.notifier).resetState();
    });
  }

  void _showDeleteAccountDrawer() {
    openDrawer(
      context: context,
      transformBackdrop: false,
      expands: false,
      builder: (context) {
        return DeleteAccountDrawer(onClose: () => closeDrawer(context));
      },
      position: OverlayPosition.bottom,
    );
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
              InkWell(
                onTap: () {
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
        Divider().withPadding(top: 8),
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
                  InkWell(
                    onTap: _showDeleteAccountDrawer,
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
        ).withPadding(all: 8),
      ),
    );
  }
}

class DeleteAccountDrawer extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const DeleteAccountDrawer({super.key, required this.onClose});

  @override
  ConsumerState<DeleteAccountDrawer> createState() =>
      _DeleteAccountDrawerState();
}

class _DeleteAccountDrawerState extends ConsumerState<DeleteAccountDrawer> {
  bool _hasShownToast = false;

  @override
  void initState() {
    super.initState();
    _hasShownToast = false;
  }

  @override
  Widget build(BuildContext context) {
    final deletionState = ref.watch(accountDeletionProvider);

    // Handle success state
    if (deletionState.state == AccountDeletionState.success &&
        !_hasShownToast) {
      _hasShownToast = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Reset the selected index
        ref.read(selectedIndexProvider.notifier).reset();

        showToast(
          context: context,
          location: ToastLocation.topCenter,
          builder:
              (context, overlay) => Toast(
                toastColor: PaxColors.green,
                text: "Account successfully deleted",
                trailingIcon: FontAwesomeIcons.solidCircleCheck,
              ),
        );

        // Navigate to onboarding after a short delay to show the toast
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            context.go('/onboarding');
          }
        });
      });
    }

    // Handle error state
    if (deletionState.state == AccountDeletionState.error &&
        deletionState.errorMessage != null &&
        !_hasShownToast) {
      _hasShownToast = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showToast(
          context: context,
          location: ToastLocation.topCenter,
          builder:
              (context, overlay) => Toast(
                toastColor:
                    deletionState.errorMessage!.contains("withdraw all funds")
                        ? PaxColors.orange
                        : PaxColors.red,
                text: deletionState.errorMessage!,
                trailingIcon: FontAwesomeIcons.triangleExclamation,
              ),
        );
        widget.onClose();
      });
    }

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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "Are you sure you want to delete your account?",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
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
                      .withBackgroundColor(color: PaxColors.lightGrey)
                      .withBorder(
                        border: Border.all(color: Colors.transparent),
                      ),
                  onPressed: widget.onClose,
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).typography.base.copyWith(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      color: PaxColors.deepPurple,
                    ),
                  ),
                ),
              ),

              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 48,
                child: PrimaryButton(
                  onPressed:
                      deletionState.isDeleting
                          ? null
                          : () async {
                            await ref
                                .read(accountDeletionProvider.notifier)
                                .deleteAccount();
                          },
                  child:
                      deletionState.isDeleting
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  onSurface: true,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Processing...',
                                style: Theme.of(
                                  context,
                                ).typography.base.copyWith(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  color: PaxColors.white,
                                ),
                              ),
                            ],
                          )
                          : Text(
                            'Yes, delete',
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
  }
}

// String? selectedValue;
// @override
// Widget build(BuildContext context) {
//   return 
// }


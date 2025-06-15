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
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';
import 'package:pax/providers/auth/auth_provider.dart';
import 'package:pax/providers/account/account_deletion_provider.dart';
import 'package:pax/providers/route/root_selected_index_provider.dart';
import 'package:pax/widgets/account/account_and_security_card.dart';
import 'package:pax/widgets/account/account_option_card.dart';
import 'package:pax/widgets/delete_account/delete_account_drawer.dart';
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
      _AccountAndSecurityView();
}

class _AccountAndSecurityView extends ConsumerState<AccountAndSecurityView> {
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
                    onTap: showDeleteAccountDrawer,
                    child: AccountAndSecurityCard('Delete Account'),
                  ),
                ],
              ),
            ),
          ],
        ).withPadding(all: 8),
      ),
    );
  }

  void showDeleteAccountDrawer() {
    openDrawer(
      context: context,
      transformBackdrop: false,
      expands: false,
      barrierDismissible: false,
      backdropBuilder: (context) {
        return PopScope(canPop: false, child: SizedBox.shrink());
      },
      builder: (drawerContext) {
        return DeleteAccountDrawer(
          onClose: () => closeDrawer(drawerContext),
          rootContext: context,
        );
      },
      position: OverlayPosition.bottom,
    );
  }
}

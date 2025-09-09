// ignore_for_file: unused_import

import 'package:flutter/material.dart' show Divider, InkWell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:pax/features/home/achievements/view.dart';
import 'package:pax/features/home/dashboard/view.dart';
import 'package:pax/features/home/tasks/view.dart';
import 'package:pax/features/onboarding/view_model.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/secret_constants.dart';
import 'package:pax/utils/url_handler.dart';
import 'package:pax/widgets/account/account_option_card.dart';
import 'package:pax/widgets/canvassing_x_gooddollar.dart';
import 'package:pax/widgets/help_and_support.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';

import '../../theming/colors.dart' show PaxColors;
import '../../utils/clipper.dart';

class CanvassingXGoodDollarView extends ConsumerStatefulWidget {
  const CanvassingXGoodDollarView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CanvassingXGoodDollarViewState();
}

class _CanvassingXGoodDollarViewState
    extends ConsumerState<CanvassingXGoodDollarView> {
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
              InkWell(
                onTap: () {
                  context.pop();
                },
                child: SvgPicture.asset('lib/assets/svgs/arrow_left_long.svg'),
              ),
              Spacer(),
              Text(
                "Canvassing x GoodDollar",
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
                  InkWell(
                    onTap: _onGoodWalletTapped,
                    child: CanvassingXGoodDollarCard(
                      'GoodWallet',
                      'lib/assets/svgs/wallets/goodwallet.svg',
                    ),
                  ).withPadding(top: 8),

                  InkWell(
                    onTap: _onGoodPaxAppTapped,
                    child: CanvassingXGoodDollarCard(
                      'Good Pax App',
                      'lib/assets/svgs/currencies/good_dollar.svg',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).withPadding(horizontal: 8, bottom: 8),
    );
  }

  void _onGoodWalletTapped() {
    ref.read(analyticsProvider).goodWalletTapped({
      "inviteCode": goodWalletInviteCode,
    });
    UrlHandler.launchCustomTab(context, goodWalletInviteLink);
  }

  void _onGoodPaxAppTapped() {
    ref.read(analyticsProvider).goodPaxAppTapped({"link": goodPaxAppLink});
    UrlHandler.launchInExternalBrowser(goodPaxAppLink);
  }
}

// String? selectedValue;
// @override
// Widget build(BuildContext context) {
//   return 
// }


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
import 'package:pax/utils/url_handler.dart';
import 'package:pax/widgets/account/account_option_card.dart';
import 'package:pax/widgets/help_and_support.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';

import '../../theming/colors.dart' show PaxColors;
import '../../utils/clipper.dart';

class HelpAndSupportView extends ConsumerStatefulWidget {
  const HelpAndSupportView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HelpAndSupportViewState();
}

class _HelpAndSupportViewState extends ConsumerState<HelpAndSupportView> {
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
                "Help & Support",
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
                    onTap: _onFaqTapped,
                    child: HelpAndSupportCard('FAQ'),
                  ),

                  InkWell(
                    onTap: _onContactSupportTapped,
                    child: HelpAndSupportCard('Contact Support'),
                  ),
                  InkWell(
                    onTap: _onPrivacyPolicyTapped,
                    child: HelpAndSupportCard('Privacy Policy'),
                  ),
                  InkWell(
                    onTap: _onTermsOfServiceTapped,
                    child: HelpAndSupportCard('Terms of Service'),
                  ),
                  InkWell(
                    onTap: _onAboutUsTapped,
                    child: HelpAndSupportCard('About Us'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).withPadding(horizontal: 8, bottom: 8),
    );
  }

  void _onFaqTapped() {
    ref.read(analyticsProvider).faqTapped();
    context.push("/help-and-support/faq");
  }

  void _onContactSupportTapped() {
    ref.read(analyticsProvider).contactSupportTapped();
    context.push("/help-and-support/contact-support");
  }

  void _onPrivacyPolicyTapped() {
    ref.read(analyticsProvider).privacyPolicyTapped();
    UrlHandler.launchInAppWebView(
      context,
      "https://canvassing.notion.site/Privacy-Policy-9446d085f6f3473087868007d931247c?pvs=74",
    );
  }

  void _onTermsOfServiceTapped() {
    ref.read(analyticsProvider).termsOfServiceTapped();
    UrlHandler.launchInAppWebView(
      context,
      "https://canvassing.notion.site/Terms-of-Service-1285e1ccc593808f8d1df0b444c36b85?pvs=74",
    );
  }

  void _onAboutUsTapped() {
    ref.read(analyticsProvider).aboutUsTapped();
    UrlHandler.launchInAppWebView(
      context,
      "https://optimistic-volunteers-396150.framer.app/",
    );
  }
}

// String? selectedValue;
// @override
// Widget build(BuildContext context) {
//   return 
// }


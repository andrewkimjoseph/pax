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

import '../../theming/colors.dart' show PaxColors;
import '../../utils/clipper.dart';

class HelpAndSupportView extends ConsumerStatefulWidget {
  const HelpAndSupportView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HelpAndSupportViewState();
}

class _HelpAndSupportViewState extends ConsumerState<HelpAndSupportView> {
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
                    onTap: () {
                      context.push("/help-and-support/faq");
                    },
                    child: HelpAndSupportCard('FAQ'),
                  ),

                  InkWell(
                    onTap: () {
                      context.push("/help-and-support/contact-support");
                    },
                    child: HelpAndSupportCard('Contact Support'),
                  ),
                  InkWell(
                    onTap: () {
                      UrlHandler.launchInAppWebView(
                        context,
                        "https://canvassing.notion.site/Privacy-Policy-9446d085f6f3473087868007d931247c?pvs=74",
                      );
                    },
                    child: HelpAndSupportCard('Privacy Policy'),
                  ),
                  InkWell(
                    onTap: () {
                      UrlHandler.launchInAppWebView(
                        context,
                        "https://canvassing.notion.site/Terms-of-Service-1285e1ccc593808f8d1df0b444c36b85?pvs=74",
                      );
                    },
                    child: HelpAndSupportCard('Terms of Service'),
                  ),
                  InkWell(
                    onTap: () {
                      UrlHandler.launchInAppWebView(
                        context,
                        "https://optimistic-volunteers-396150.framer.app/",
                      );
                    },
                    child: HelpAndSupportCard('About Us'),
                  ),
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


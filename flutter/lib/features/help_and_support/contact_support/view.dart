// ignore_for_file: unused_import

import 'package:flutter/material.dart' show Divider, InkWell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:pax/features/home/achievements/view.dart';
import 'package:pax/features/home/dashboard/view.dart';
import 'package:pax/features/home/tasks/view.dart';
import 'package:pax/features/onboarding/view_model.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/url_handler.dart';
import 'package:pax/widgets/account/account_option_card.dart';
import 'package:pax/widgets/contact_support_card.dart';
import 'package:pax/widgets/help_and_support.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ContactSupportView extends ConsumerStatefulWidget {
  const ContactSupportView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ContactSupportViewState();
}

class _ContactSupportViewState extends ConsumerState<ContactSupportView> {
  String? genderValue;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final participant = ref.read(participantProvider).participant;
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
                "Contact Support",
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
                      UrlHandler.launchInAppWebView(
                        context,
                        "https://tally.so/r/nGy7V2?authId=${participant?.id}",
                      );
                    },
                    child: ContactSupportCard(
                      'Raise a Ticket',
                      'customer_support',
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      UrlHandler.launchInAppWebView(
                        context,
                        "https://thecanvassing.xyz",
                      );
                    },
                    child: ContactSupportCard('Website', 'website'),
                  ),

                  // InkWell(
                  //   onTap: () {
                  //   },
                  //   child: ContactSupportCard('Whatsapp', 'whatsapp'),
                  // ),
                  InkWell(
                    onTap: () {
                      UrlHandler.launchInExternalBrowser(
                        "https://x.com/thecanvassing",
                      );
                    },
                    child: ContactSupportCard('X', 'x'),
                  ),

                  // GestureDetector(
                  //   // onPanDown: (details) {
                  //   //   context.push("/help-and-support/contact-support");
                  //   // },
                  //   child: ContactSupportCard('Instagram', 'instagram'),
                  // ),

                  // HelpAndSupportCard('Contact Support'),
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


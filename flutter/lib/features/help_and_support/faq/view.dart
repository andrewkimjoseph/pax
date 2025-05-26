// ignore_for_file: unused_import

import 'package:flutter/material.dart' show InkWell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:pax/data/faqs.dart';
import 'package:pax/exports/shadcn.dart';
import 'package:pax/models/faq.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/widgets/faq_accordion_item.dart';
import 'package:pax/widgets/account/account_option_card.dart';
import 'package:pax/widgets/help_and_support.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class FAQView extends ConsumerStatefulWidget {
  const FAQView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FAQViewState();
}

class _FAQViewState extends ConsumerState<FAQView> {
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
          padding: const EdgeInsets.all(8),
          backgroundColor: PaxColors.white,
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  context.pop();
                },
                child: SvgPicture.asset('lib/assets/svgs/arrow_left_long.svg'),
              ),
              const Spacer(),
              const Text(
                "FAQ",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ).withPadding(right: 16),
              const Spacer(),
            ],
          ),
        ).withPadding(top: 16),
        const Divider(color: PaxColors.lightGrey),
      ],
      child: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                Accordion(
                  items:
                      FAQs.faqs
                          .map((faq) => FAQAccordionItem(faq: faq))
                          .toList(),
                ),
              ],
            ).withPadding(horizontal: 8),
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




import 'package:pax/exports/shadcn.dart';
import 'package:pax/models/faq.dart';
import 'package:flutter/gestures.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/regex.dart';
import 'package:pax/utils/url_handler.dart';

class FAQAccordionItem extends StatelessWidget {
  final FAQ faq;

  const FAQAccordionItem({super.key, required this.faq});

  @override
  Widget build(BuildContext context) {
    final isLink = urlRegex.hasMatch(faq.answer.trim());
    return AccordionItem(
      trigger: AccordionTrigger(
        child: Text(
          faq.question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      content:
          isLink
              ? RichText(
                text: TextSpan(
                  text: faq.answer,
                  style: DefaultTextStyle.of(context).style.copyWith(
                    color: PaxColors.linkBlue,
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                  ),
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () {
                          UrlHandler.launchInAppWebView(
                            context,
                            faq.answer.trim(),
                          );
                        },
                ),
              )
              : Text(faq.answer),
    );
  }
}

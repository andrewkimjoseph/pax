// ignore_for_file: unused_import

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:pax/exports/shadcn.dart';
import 'package:pax/features/onboarding/view_model.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/widgets/account_option_card.dart';
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
                "FAQ",
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
            Column(
              children: [
                const Accordion(
                  items: [
                    AccordionItem(
                      trigger: AccordionTrigger(
                        child: Text(
                          'How many times does the platform run surveys?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      content: Text(
                        'Once every day, for three days each week. So, a total of 3 surveys a week.',
                      ),
                    ),

                    AccordionItem(
                      trigger: AccordionTrigger(
                        child: Text(
                          'What time of the day is the survey made available?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      content: Text('From 9 WAT / 11 EAT '),
                    ),

                    AccordionItem(
                      trigger: AccordionTrigger(
                        child: Text(
                          'On which days are surveys available?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      content: Text('Wednesday, Thursday, and Friday'),
                    ),
                    AccordionItem(
                      trigger: AccordionTrigger(
                        child: Text(
                          'How many questions are there for a single survey?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      content: Text(
                        '5 - 10 questions that require little to no typing input.',
                      ),
                    ),
                    AccordionItem(
                      trigger: AccordionTrigger(
                        child: Text(
                          'I have been missing out on survey booking, what could be wrong?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      content: Text(
                        'Survey booking is on a first come, first served basis. Because of the high volumes, once a survey is listed, people rush and thus, the booking closes faster. You just need to be quick enough.',
                      ),
                    ),
                    AccordionItem(
                      trigger: AccordionTrigger(
                        child: Text(
                          'What happens when I book a slot in a survey?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      content: Text(
                        'Survey booking is on a first come, first served basis. Because of the high volumes, once a survey is listed, people rush and thus, the booking closes faster. You just need to be quick enough.',
                      ),
                    ),
                    AccordionItem(
                      trigger: AccordionTrigger(
                        child: Text(
                          'How much money can I make from answering surveys per month?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      content: Text(
                        'If you book and complete all possible surveys in a month, you could make up to 0.12 cUSD, which is enough for airtime.',
                      ),
                    ),
                  ],
                ),
                // const Accordion(
                //   items: [
                //     AccordionItem(
                //       trigger: AccordionTrigger(
                //         child: Text('Lorem ipsum dolor sit amet'),
                //       ),
                //       content: Text(
                //         'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                //         'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                //         'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. '
                //         'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. '
                //         'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                //       ),
                //     ),
                //     AccordionItem(
                //       trigger: AccordionTrigger(
                //         child: Text(
                //           'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua',
                //         ),
                //       ),
                //       content: Text(
                //         'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                //         'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. '
                //         'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. '
                //         'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                //       ),
                //     ),
                //     AccordionItem(
                //       trigger: AccordionTrigger(
                //         child: Text(
                //           'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat',
                //         ),
                //       ),
                //       content: Text(
                //         'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. '
                //         'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. '
                //         'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                //       ),
                //     ),
                //   ],
                // ),
                // Container(
                //   // padding: EdgeInsets.all(8),
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //     color: PaxColors.white,
                //     borderRadius: BorderRadius.circular(12),
                //     border: Border.all(color: PaxColors.lightLilac, width: 1),
                //   ),
                //   child: Collapsible(
                //     children: [
                //       const CollapsibleTrigger(
                //         child: Column(
                //           children: [
                //             Text(
                //               'How many times does the platform run surveys?',
                //             ),
                //           ],
                //         ),
                //       ),

                //       CollapsibleContent(
                //         child: Column(
                //           children: [
                //             Divider(),
                //             const Text(
                //               'Once every day, for three days each week. So, a total of 3 surveys a week',
                //             ),
                //           ],
                //         ).withPadding(horizontal: 16),
                //       ),
                //     ],
                //   ),
                // ).withPadding(vertical: 8),
                // Container(

                //   child: Accordion(
                //     items: [
                //       AccordionItem(
                //         trigger: AccordionTrigger(
                //           child: Text(
                //             'How many times does the platform run surveys?',
                //           ),
                //         ),
                //         content: Text(
                //           'Once every day, for three days each week. So, a total of 3 surveys a week.',
                //         ),
                //       ),
                //     ],
                //   ),
                // ).withPadding(bottom: 8),
                // Accordion(
                //   items: [

                //     Container(
                //       padding: EdgeInsets.all(8),
                //       width: double.infinity,
                //       decoration: BoxDecoration(
                //         color: PaxColors.white,
                //         borderRadius: BorderRadius.circular(12),
                //         border: Border.all(
                //           color: PaxColors.lightLilac,
                //           width: 1,
                //         ),
                //       ),
                //       child: AccordionItem(
                //         trigger: AccordionTrigger(
                //           child: Text('Lorem ipsum dolor sit amet'),
                //         ),
                //         content: Text(
                //           'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                //           'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                //           'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. '
                //           'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. '
                //           'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                //         ),
                //       ),
                //     ),
                //     Container(
                //       padding: EdgeInsets.all(8),
                //       width: double.infinity,
                //       decoration: BoxDecoration(
                //         color: PaxColors.white,
                //         borderRadius: BorderRadius.circular(12),
                //         border: Border.all(
                //           color: PaxColors.lightLilac,
                //           width: 1,
                //         ),
                //       ),
                //       child: AccordionItem(
                //         trigger: AccordionTrigger(
                //           child: Text('Lorem ipsum dolor sit amet'),
                //         ),
                //         content: Text(
                //           'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                //           'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                //           'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. '
                //           'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. '
                //           'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                //         ),
                //       ),
                //     ),
                //   ],
                // ),

                // HelpAndSupportCard('Contact Support'),
                // HelpAndSupportCard('Privacy Policy'),
                // HelpAndSupportCard('Terms of Service'),
                // HelpAndSupportCard('About Us'),
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




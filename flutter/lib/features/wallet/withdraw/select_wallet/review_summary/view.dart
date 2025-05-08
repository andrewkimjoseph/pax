import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';

import 'package:pax/theming/colors.dart';
import 'package:pax/widgets/change_withdrawal_method_card.dart';

import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;

class ReviewSummaryView extends ConsumerStatefulWidget {
  const ReviewSummaryView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ReviewSummaryViewState();
}

class _ReviewSummaryViewState extends ConsumerState<ReviewSummaryView> {
  String? selectedValue;
  String? genderValue;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaxColors.white,
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
                child: SvgPicture.asset(
                  'lib/assets/svgs/arrow_left_long.svg',
                ).withPadding(left: 0),
              ),
              Spacer(),
              Text(
                "Review Summary",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: PaxColors.black),
              ),

              Spacer(),
            ],
          ),
        ).withPadding(top: 16),
      ],

      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Balance Amount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$30.00',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ).withPadding(bottom: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Gas Fee',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Free',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ).withPadding(bottom: 16),

                      Divider(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$30.00',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ).withPadding(vertical: 16),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   crossAxisAlignment: CrossAxisAlignment.end,
                      //   children: [
                      //     Container(
                      //       // padding: EdgeInsets.all(8),
                      //       decoration: BoxDecoration(
                      //         shape: BoxShape.circle,
                      //         border: Border.all(
                      //           color:
                      //               PaxColors.deepPurple, // Change color as needed
                      //           width: 2.5, // Adjust border thickness as needed
                      //         ),
                      //       ),
                      //       child: Avatar(
                      //         size: 70,
                      //         initials: Avatar.getInitials('sunarya-thito'),
                      //         provider: const NetworkImage(
                      //           'https://avatars.githubusercontent.com/u/64018564?v=4',
                      //         ),
                      //       ),
                      //     ),

                      //     SvgPicture.asset('lib/assets/svgs/edit_profile.svg'),
                      //   ],
                      // ).withPadding(bottom: 16, top: 12),
                    ],
                  ),
                ).withPadding(bottom: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Payout to',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ).withPadding(vertical: 16),

                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PaxColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PaxColors.lightLilac, width: 1),
                  ),
                  child: Column(
                    children: [
                      ChangeWithdrawalMethodCard(
                        'minipay',
                        "MiniPay",
                        () =>
                            context.push("/payment-methods/minipay-connection"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Spacer(flex: 2),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),

            color: Colors.white,

            child: Column(
              children: [
                Divider().withPadding(vertical: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: PrimaryButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            // title: const Text('Alert title'),
                            content: Column(
                              children: [
                                SvgPicture.asset(
                                  'lib/assets/svgs/withdrawal_complete.svg',
                                ).withPadding(bottom: 8),

                                const Text(
                                  'Withdrawal Complete!',
                                  style: TextStyle(
                                    color: PaxColors.deepPurple,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ).withPadding(bottom: 8),
                                const Text(
                                  '\$30 has been successfully transferred to your MiniPay account.',
                                  style: TextStyle(
                                    color: PaxColors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ).withPadding(bottom: 8),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width /
                                          2.5,
                                      child: PrimaryButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          context.pop();
                                        },
                                      ),
                                    ),
                                  ],
                                ).withPadding(top: 8),
                              ],
                            ),
                          );
                        },
                      );
                    },

                    child: Text(
                      'Continue',
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
          ).withMargin(bottom: 32),
        ],
      ).withPadding(all: 8),
    );
  }
}

// String? selectedValue;
// @override
// Widget build(BuildContext context) {
//   return 
// }


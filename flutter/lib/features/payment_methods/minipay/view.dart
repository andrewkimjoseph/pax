import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';

import 'package:pax/theming/colors.dart';

import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;
import 'package:url_launcher/url_launcher.dart';

class MiniPayConnectionView extends ConsumerStatefulWidget {
  const MiniPayConnectionView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HelpAndSupportViewState();
}

class _HelpAndSupportViewState extends ConsumerState<MiniPayConnectionView> {
  String? genderValue;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      headers: [
        AppBar(
          padding: EdgeInsets.all(8),
          leading: [],
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
                ).withPadding(left: 16),
              ),
              Spacer(),
              Text(
                "Connect Your MiniPay",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ).withPadding(right: 16),
              Spacer(),
            ],
          ),
        ).withPadding(top: 16),
      ],

      // Use Column as the main container
      child: Column(
        children: [
          // Fixed-size content area (not scrollable)
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SvgPicture.asset(
                      'lib/assets/svgs/minipay.svg',
                      height: 100,
                    ),
                  ),
                  Text(
                    "Enter MiniPay Wallet Address",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ).withPadding(vertical: 16), // Reduced padding

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Wallet address (0x..)",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ).withPadding(bottom: 8),
                      TextField(
                        scrollPhysics: ClampingScrollPhysics(),
                        enabled: true,
                        keyboardType: TextInputType.emailAddress,
                        placeholder: Text(
                          '0xd8224F2063685Cc9D8E11aAA8741aeE9A50',
                          style: TextStyle(
                            color: PaxColors.black,
                            fontSize: 14,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: PaxColors.lightLilac,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        features: [
                          InputFeature.leading(
                            SvgPicture.asset(
                              'lib/assets/svgs/wallet_address.svg',
                              height: 20,
                              width: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).withPadding(bottom: 12), // Reduced padding
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Text(
                  //       "Phone number",
                  //       textAlign: TextAlign.left,
                  //       style: TextStyle(
                  //         fontSize: 12,
                  //         fontWeight: FontWeight.normal,
                  //       ),
                  //     ).withPadding(bottom: 8),
                  //     Container(
                  //       decoration: BoxDecoration(
                  //         color: PaxColors.lightLilac,
                  //         borderRadius: BorderRadius.circular(7),
                  //       ),
                  //       child: FittedBox(
                  //         child: PhoneInput(
                  //           initialValue: PhoneNumber(
                  //             Country.kenya,
                  //             '722978938',
                  //           ),
                  //           initialCountry: Country.kenya,
                  //           onChanged: (value) {
                  //             setState(() {
                  //               _phoneNumber = value;
                  //             });
                  //           },
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ).withPadding(bottom: 12), // Reduced padding
                  Row(
                    children: [
                      Text(
                        "Don't have a wallet address?",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: PaxColors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ).withPadding(right: 2),
                      GestureDetector(
                        onPanDown:
                            (details) =>
                                _launchExternalUrl('https://www.minipay.to/'),

                        child: Row(
                          children: [
                            Text(
                              "Set up a MiniPay wallet",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: PaxColors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.underline,
                              ),
                            ).withPadding(vertical: 4, right: 4),
                            SvgPicture.asset(
                              'lib/assets/svgs/redirect_window.svg',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Row(
                  //   children: [
                  //     Checkbox(
                  //       state: _state,
                  //       onChanged: (value) {
                  //         setState(() {
                  //           _state = value;
                  //         });
                  //       },
                  //       trailing: const Text('Remember me'),
                  //       tristate: true,
                  //     ),
                  //   ],
                  // ),
                  Spacer(),
                ],
              ),
            ),
          ),

          // Fixed button at the bottom
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),

            child: Column(
              children: [
                Divider().withPadding(top: 10, bottom: 10),
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
                                  'lib/assets/svgs/minipay_connected.svg',
                                ).withPadding(bottom: 8),

                                const Text(
                                  'Success!',
                                  style: TextStyle(
                                    color: PaxColors.deepPurple,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ).withPadding(bottom: 8),
                                const Text(
                                  'MiniPay Wallet Connected Successfully',
                                  style: TextStyle(
                                    color: PaxColors.deepPurple,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
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
                      'Connect',
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
          ),
        ],
      ),
    );
  }

  Future<void> _launchExternalUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Show error if URL can't be launched
    }
  }
}

// String? selectedValue;
// @override
// Widget build(BuildContext context) {
//   return 
// }


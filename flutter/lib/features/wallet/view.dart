import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:pax/widgets/payment_method_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;

import '../../theming/colors.dart' show PaxColors;

class WalletView extends ConsumerStatefulWidget {
  const WalletView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WalletViewViewState();
}

class _WalletViewViewState extends ConsumerState<WalletView> {
  String selectedValue = 'good_dollar';
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
                child: SvgPicture.asset(
                  'lib/assets/svgs/arrow_left_long.svg',
                ).withPadding(left: 0),
              ),
              Spacer(),
              Text(
                "Wallet",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),

              Spacer(),
            ],
          ),
        ).withPadding(top: 16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Balance',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 20,
                      color: PaxColors.black,
                    ),
                  ).withPadding(bottom: 8),

                  Row(
                    children: [
                      Text(
                        '17,000,000',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          color: PaxColors.black,
                        ),
                      ).withPadding(right: 8),
                      SvgPicture.asset(
                        'lib/assets/svgs/currencies/$selectedValue.svg',
                        height: 25,
                      ),
                    ],
                  ).withPadding(bottom: 16),

                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: PaxColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Select<String>(
                          // filled: true,
                          // disableHoverEffect: true,
                          itemBuilder: (context, item) {
                            return Row(
                              children: [
                                // Icon(
                                //   Icons.circle,
                                //   size: 12,
                                //   color: PaxColors.blue,
                                // ).withPadding(right: 4),
                                SvgPicture.asset(
                                  'lib/assets/svgs/currencies/$item.svg',

                                  height: 20,
                                ).withPadding(right: 8),
                                Text(item),
                              ],
                            );
                          },

                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedValue = value;
                              });
                            }
                          },
                          value: selectedValue,

                          placeholder: const Text('Change currency'),
                          popup:
                              (context) => SelectPopup(
                                items: SelectItemList(
                                  children: [
                                    SelectItemButton(
                                      value: 'good_dollar',
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            'lib/assets/svgs/currencies/good_dollar.svg',

                                            height: 25,
                                          ).withPadding(right: 4),
                                          Text('GoodDollar (G\$)'),
                                        ],
                                      ),
                                    ),
                                    SelectItemButton(
                                      value: 'celo_dollar',
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            'lib/assets/svgs/currencies/celo_dollar.svg',

                                            height: 19,
                                          ).withPadding(right: 6),
                                          Text('Celo Dollar (cUSD)'),
                                        ],
                                      ).withPadding(left: 4),
                                    ),
                                    SelectItemButton(
                                      value: 'tether_usd',
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            'lib/assets/svgs/currencies/tether_usd.svg',

                                            height: 19,
                                          ).withPadding(right: 6),
                                          Text('Tether USD (USDT)'),
                                        ],
                                      ).withPadding(left: 4),
                                    ),

                                    SelectItemButton(
                                      value: 'usd_coin',
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            'lib/assets/svgs/currencies/usd_coin.svg',

                                            height: 19,
                                          ).withPadding(right: 6),
                                          Text('USD Coin (USDC)'),
                                        ],
                                      ).withPadding(left: 4),
                                    ).withPadding(bottom: 30),
                                  ],
                                ),
                              ),
                        ),
                      ).withPadding(right: 8),

                      Button(
                        style: const ButtonStyle.outline(
                              density: ButtonDensity.normal,
                            )
                            .withBackgroundColor(color: PaxColors.blue)
                            .withBorder(
                              border: Border.all(color: Colors.transparent),
                            ),
                        onPressed: () {
                          context.go('/wallet/withdraw');
                        },
                        child: Text(
                          'Withdraw',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color:
                                PaxColors
                                    .black, // The purple color from your images
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Row(
                  //   children: [
                  //     OutlineButton(
                  //       child: const Text('Cancel'),
                  //       onPressed: () {},
                  //     ),
                  //     const Spacer(),
                  //     PrimaryButton(
                  //       child: const Text('Deploy'),
                  //       onPressed: () {},
                  //     ),
                  //   ],
                  // ),
                ],
              ).withPadding(all: 12),
            ).withPadding(bottom: 8),
            Container(
              padding: EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: PaxColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PaxColors.lightLilac, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Payment Methods',
                    style: TextStyle(fontSize: 20),
                  ).withPadding(bottom: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: PaxColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: PaxColors.lightLilac, width: 1),
                    ),
                    child: Column(
                      children: [
                        PaymentMethodCard(
                          'minipay',
                          "MiniPay Wallet",
                          () => context.push(
                            "/payment-methods/minipay-connection",
                          ),
                        ),
                      ],
                    ),
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


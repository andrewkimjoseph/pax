import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';

import 'package:pax/theming/colors.dart';
import 'package:pax/widgets/withdrawal_option_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;

class SelectWalletView extends ConsumerStatefulWidget {
  const SelectWalletView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectWalletViewState();
}

class _SelectWalletViewState extends ConsumerState<SelectWalletView> {
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
                "Wallets",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),

              Spacer(),
              // Icon(Icons.more_vert),
            ],
          ),
        ).withPadding(top: 16),
        Divider(color: PaxColors.lightGrey),
      ],

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
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PaxColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PaxColors.lightLilac, width: 1),
                  ),
                  child: Column(
                    children: [
                      WithdrawalOptionCard(
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

          Spacer(),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),

            child: Column(
              children: [
                Divider().withPadding(top: 10, bottom: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: PrimaryButton(
                    onPressed: () {
                      context.go(
                        '/wallet/withdraw/select-wallet/review-summary',
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


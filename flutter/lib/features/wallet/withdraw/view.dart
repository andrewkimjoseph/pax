import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';

import 'package:pax/theming/colors.dart';

import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;

class WithdrawView extends ConsumerStatefulWidget {
  const WithdrawView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WithdrawViewState();
}

class _WithdrawViewState extends ConsumerState<WithdrawView> {
  String? selectedValue;
  String? genderValue;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaxColors.deepPurple,
      headers: [
        AppBar(
          padding: EdgeInsets.all(8),

          backgroundColor: PaxColors.deepPurple,
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanDown: (details) {
                  context.pop();
                },
                child: SvgPicture.asset(
                  colorFilter: ColorFilter.mode(
                    PaxColors.white,
                    BlendMode.srcIn,
                  ),
                  'lib/assets/svgs/arrow_left_long.svg',
                ).withPadding(left: 0),
              ),
              Spacer(),
              Text(
                "Withdraw",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: PaxColors.white),
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
          Text(
            "Enter amount of balance you want to payout",
            style: TextStyle(fontSize: 16, color: PaxColors.white),
          ).withPadding(top: 16),
          Spacer(flex: 1),
          Container(
            padding: EdgeInsets.all(16),
            child: const TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              placeholder: Text('Enter amount'),
              style: TextStyle(
                fontSize: 32,
                color: PaxColors.white,
                fontWeight: FontWeight.bold,
              ),
              border: false,
              cursorColor: PaxColors.white,
            ).withAlign(Alignment.center),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Available balance:",
                style: TextStyle(fontSize: 12, color: PaxColors.white),
              ).withPadding(right: 4),
              Text(
                "\$246.50",
                style: TextStyle(
                  fontSize: 16,
                  color: PaxColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ).withPadding(top: 8),

          Spacer(flex: 2),

          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 16), // Add padding only at the top
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: PrimaryButton(
                      onPressed: () {
                        context.go('/wallet/withdraw/select-wallet');
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
                ),
                // Add extra space at the bottom to ensure it pushes past safe area
                SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// String? selectedValue;
// @override
// Widget build(BuildContext context) {
//   return 
// }


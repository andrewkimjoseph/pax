// ignore_for_file: unused_import

import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:pax/features/home/achievements/view.dart';
import 'package:pax/features/home/dashboard/view.dart';
import 'package:pax/features/home/tasks/view.dart';
import 'package:pax/features/onboarding/view_model.dart';
import 'package:pax/widgets/account_option_card.dart';
import 'package:pax/widgets/payment_method_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../theming/colors.dart' show PaxColors;
import '../../utils/clipper.dart';

class PaymentMethodsView extends ConsumerStatefulWidget {
  const PaymentMethodsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PaymentMethodsViewState();
}

class _PaymentMethodsViewState extends ConsumerState<PaymentMethodsView> {
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
                "Payment Methods",
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
                        PaymentMethodCard(
                          'minipay',
                          "MiniPay",
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


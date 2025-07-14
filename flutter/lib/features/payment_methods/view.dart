import 'package:flutter/material.dart' show Divider, InkWell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/db/payment_method/payment_method_provider.dart';
import 'package:pax/widgets/payment_method_cards/minipay_payment_method_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;
import 'package:pax/utils/remote_config_constants.dart';
import 'package:pax/providers/remote_config/remote_config_provider.dart';
import 'package:flutter/foundation.dart';

import '../../theming/colors.dart' show PaxColors;

class WithdrawalMethodsView extends ConsumerStatefulWidget {
  const WithdrawalMethodsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _WithdrawalMethodsViewState();
}

class _WithdrawalMethodsViewState extends ConsumerState<WithdrawalMethodsView> {
  @override
  Widget build(BuildContext context) {
    final featureFlags = ref.watch(featureFlagsProvider);
    final minipay = ref.watch(primaryWithdrawalMethodProvider);

    return featureFlags.when(
      data: (flags) {
        final isWithdrawalMethodConnectionAvailable =
            flags[RemoteConfigKeys.isWithdrawalMethodConnectionAvailable] ??
            true;
        return Scaffold(
          headers: [
            AppBar(
              padding: EdgeInsets.all(8),
              backgroundColor: PaxColors.white,
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      context.pop();
                    },
                    child: SvgPicture.asset(
                      'lib/assets/svgs/arrow_left_long.svg',
                    ),
                  ),
                  Spacer(),
                  Text(
                    "Withdrawal Methods",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                ],
              ),
            ).withPadding(top: 16),
            Divider(color: PaxColors.lightGrey),
          ],
          child:
              kDebugMode || (isWithdrawalMethodConnectionAvailable == true)
                  ? SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: PaxColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: PaxColors.lightLilac,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              MiniPayPaymentMethodCard(
                                minipay,
                                callBack: () {
                                  ref
                                      .read(analyticsProvider)
                                      .minipayPaymentMethodCardTapped();
                                  context.push(
                                    "/payment-methods/minipay-connection",
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).withPadding(all: 8)
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Linking a withdrawal method is not possible at this time.\nTry again later.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: PaxColors.black),
                      ).withPadding(top: 16),
                    ],
                  ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

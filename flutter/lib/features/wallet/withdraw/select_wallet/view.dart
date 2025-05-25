import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:pax/providers/db/payment_method/payment_method_provider.dart';
import 'package:pax/providers/local/withdraw_context_provider.dart';
import 'package:pax/widgets/withdrawal_option_card.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;

class SelectWalletView extends ConsumerStatefulWidget {
  const SelectWalletView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectWalletViewState();
}

class _SelectWalletViewState extends ConsumerState<SelectWalletView> {
  @override
  Widget build(BuildContext context) {
    // Get available payment methods
    final paymentMethods = ref.watch(paymentMethodsProvider).paymentMethods;

    // Watch the withdraw context
    final withdrawContext = ref.watch(withdrawContextProvider);

    // Button is enabled only when a payment method is selected
    final isContinueEnabled = withdrawContext?.selectedPaymentMethod != null;

    return Scaffold(
      headers: [
        AppBar(
          padding: const EdgeInsets.all(8),
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
              const Spacer(),
              const Text(
                "Select Wallet",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              const Spacer(),
            ],
          ),
        ).withPadding(top: 16),
        const Divider(color: PaxColors.lightGrey),
      ],

      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: PaxColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PaxColors.lightLilac, width: 1),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PaxColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PaxColors.lightLilac, width: 1),
                  ),
                  child: Column(
                    children: [
                      // Show payment methods if available
                      if (paymentMethods.isNotEmpty)
                        ...paymentMethods.map(
                          (method) => WalletOptionCard(method),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              children: [
                const Divider().withPadding(top: 10, bottom: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: PrimaryButton(
                    // Enable button only when a payment method is selected
                    enabled: isContinueEnabled,
                    onPressed:
                        isContinueEnabled
                            ? () {
                              context.push(
                                '/wallet/withdraw/select-wallet/review-summary',
                              );
                            }
                            : null,
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

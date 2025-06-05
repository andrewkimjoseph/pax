import 'package:flutter/material.dart' show InkWell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pax/models/firestore/payment_method/payment_method.dart';
import 'package:pax/providers/local/withdraw_context_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:intl/intl.dart';

class WalletOptionCard extends ConsumerWidget {
  const WalletOptionCard(this.paymentMethod, {super.key});

  final WithdrawalMethod paymentMethod;

  void _toggleSelection(WidgetRef ref, bool isSelected) {
    if (isSelected) {
      // If currently selected, unselect it
      ref.read(withdrawContextProvider.notifier).setSelectedPaymentMethod(null);
    } else {
      // If not selected, select it
      ref
          .read(withdrawContextProvider.notifier)
          .setSelectedPaymentMethod(paymentMethod);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withdrawContext = ref.watch(withdrawContextProvider);

    // Determine if this payment method is currently selected
    final isSelected =
        withdrawContext?.selectedPaymentMethod?.id == paymentMethod.id;

    return InkWell(
      onTap: () => _toggleSelection(ref, isSelected),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: SvgPicture.asset(
              'lib/assets/svgs/${paymentMethod.name.toLowerCase()}.svg',
              height: 48,
            ),
          ).withPadding(right: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    toBeginningOfSentenceCase(paymentMethod.name),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: PaxColors.black,
                    ),
                  ),
                ],
              ).withPadding(bottom: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '${paymentMethod.walletAddress.substring(0, 20)}...',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: PaxColors.lilac,
                    ),
                  ),
                ],
              ).withPadding(bottom: 8),
            ],
          ),
          const Spacer(),
          Checkbox(
            state: isSelected ? CheckboxState.checked : CheckboxState.unchecked,
            onChanged: (_) => _toggleSelection(ref, isSelected),
          ),
        ],
      ),
    );
  }
}

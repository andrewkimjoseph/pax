import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pax/models/firestore/payment_method/payment_method.dart';
import 'package:pax/providers/local/select_payment_method_provider.dart';
import 'package:pax/providers/local/withdraw_context_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:intl/intl.dart';

// Create a state provider to track the selected payment method I
class WalletOptionCard extends ConsumerStatefulWidget {
  const WalletOptionCard(this.paymentMethod, {super.key});

  final PaymentMethod paymentMethod;

  @override
  ConsumerState<WalletOptionCard> createState() => _WalletOptionCardState();
}

class _WalletOptionCardState extends ConsumerState<WalletOptionCard> {
  CheckboxState _state = CheckboxState.unchecked;

  @override
  void initState() {
    super.initState();
    // Check if this payment method is already selected in the context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final withdrawContext = ref.read(withdrawContextProvider);
      if (withdrawContext?.selectedPaymentMethod?.id ==
          widget.paymentMethod.id) {
        setState(() {
          _state = CheckboxState.checked;
        });

        ref
            .read(selectedPaymentMethodIdProvider.notifier)
            .select(widget.paymentMethod.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedMethodId = ref.watch(selectedPaymentMethodIdProvider);

    // Update checkbox state if this is the selected method
    if (selectedMethodId == widget.paymentMethod.id &&
        _state == CheckboxState.unchecked) {
      _state = CheckboxState.checked;
    } else if (selectedMethodId != widget.paymentMethod.id &&
        _state == CheckboxState.checked) {
      _state = CheckboxState.unchecked;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: SvgPicture.asset(
            'lib/assets/svgs/${widget.paymentMethod.name}.svg',
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
                  toBeginningOfSentenceCase(widget.paymentMethod.name),
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
                  '${widget.paymentMethod.walletAddress.substring(0, 20)}...',

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
          state: _state,
          onChanged: (value) {
            setState(() {
              _state = value;
            });

            // Handle checkbox state change
            if (value == CheckboxState.checked) {
              // Update the selected payment method in the context
              ref
                  .read(withdrawContextProvider.notifier)
                  .setSelectedPaymentMethod(widget.paymentMethod);

              // Update the selected payment method ID
              ref
                  .read(selectedPaymentMethodIdProvider.notifier)
                  .select(widget.paymentMethod.id);
            } else if (selectedMethodId == widget.paymentMethod.id) {
              // Clear selection
              ref.read(selectedPaymentMethodIdProvider.notifier).clear();
            }
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/models/firestore/payment_method/payment_method.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:intl/intl.dart';

// Create a state provider to track the selected payment method I
class ChangeWithdrawalMethodCard extends ConsumerStatefulWidget {
  const ChangeWithdrawalMethodCard(this.paymentMethod, {super.key});

  final PaymentMethod paymentMethod;

  @override
  ConsumerState<ChangeWithdrawalMethodCard> createState() =>
      _ChangeWithdrawalMethodCardState();
}

class _ChangeWithdrawalMethodCardState
    extends ConsumerState<ChangeWithdrawalMethodCard> {
  @override
  Widget build(BuildContext context) {
    // Update checkbox state if this is the selected method
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: SvgPicture.asset(
            'lib/assets/svgs/${widget.paymentMethod.name.toLowerCase()}.svg',
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
        InkWell(
          onTap: () {
            ref.read(analyticsProvider).changePaymentMethodTapped({
              "paymentMethodName": widget.paymentMethod.name,
              "paymentMethodId": widget.paymentMethod.id,
            });
            context.pop();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                child: Row(children: [Text('Change')]).withPadding(bottom: 8),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

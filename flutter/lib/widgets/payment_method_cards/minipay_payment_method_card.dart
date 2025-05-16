import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pax/providers/db/payment_method/payment_method_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class MiniPayPaymentMethodCard extends ConsumerWidget {
  const MiniPayPaymentMethodCard(
    this.option,
    this.paymentMethodName,
    this.callBack, {
    super.key,
  });

  final String option;

  final String paymentMethodName;

  final VoidCallback callBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minipay = ref.read(primaryPaymentMethodProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(7),

          child: SvgPicture.asset('lib/assets/svgs/$option.svg', height: 48),
        ).withPadding(right: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  paymentMethodName,

                  style: TextStyle(
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
                  minipay?.walletAddress != null
                      ? '${minipay!.walletAddress.substring(0, 20)}...'
                      : 'Dollar stablecoin wallet',

                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: PaxColors.lilac,
                  ),
                ),
              ],
            ).withPadding(bottom: 8),
          ],
        ),
        Spacer(),
        // Spacer(flex: 1),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              child: Row(
                children: [
                  PrimaryButton(
                    density: ButtonDensity.dense,
                    onPressed: minipay?.walletAddress != null ? null : callBack,
                    child: Text(
                      minipay?.walletAddress != null ? "Connected" : "Connect",
                    ),
                  ),
                ],
              ).withPadding(bottom: 8),
            ),
          ],
        ),
      ],
    );
  }
}

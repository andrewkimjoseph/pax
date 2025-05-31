import 'package:flutter/material.dart';
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
    final minipay = ref.watch(primaryPaymentMethodProvider);

    return InkWell(
      onTap: minipay?.walletAddress != null ? null : callBack,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: PaxColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PaxColors.lightLilac, width: 1),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: SvgPicture.asset(
                'lib/assets/svgs/$option.svg',
                height: 48,
              ),
            ).withPadding(right: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    paymentMethodName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: PaxColors.black,
                    ),
                  ).withPadding(bottom: 8),
                  Text(
                    minipay?.walletAddress != null
                        ? '${minipay!.walletAddress.substring(0, 15)}${'.' * 6}'
                        : 'Dollar stablecoin wallet',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: PaxColors.lilac,
                    ),
                  ),
                ],
              ),
            ),
            PrimaryButton(
              density: ButtonDensity.dense,
              onPressed: minipay?.walletAddress != null ? null : callBack,
              child: Text(
                minipay?.walletAddress != null ? "Connected" : "Connect",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pax/models/firestore/payment_method/payment_method.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class GoodWalletWithdrawalMethodCard extends ConsumerWidget {
  const GoodWalletWithdrawalMethodCard(
    this.goodWallet, {
    required this.callBack,
    super.key,
  });

  final VoidCallback callBack;
  final WithdrawalMethod? goodWallet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: goodWallet?.walletAddress != null ? null : callBack,
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
                'lib/assets/svgs/wallets/goodwallet.svg',
                height: 48,
              ),
            ).withPadding(right: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "GoodWallet",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: PaxColors.black,
                    ),
                  ).withPadding(bottom: 8),
                  Text(
                    goodWallet?.walletAddress != null
                        ? '${goodWallet!.walletAddress.substring(0, 15)}${'.' * 3}'
                        : 'Multi-chain wallet',
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
              onPressed: goodWallet?.walletAddress != null ? null : callBack,
              child: Text(
                goodWallet?.walletAddress != null ? "Connected" : "Connect",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

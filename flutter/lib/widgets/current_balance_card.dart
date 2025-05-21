import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:pax/extensions/tooltip.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';
import 'package:pax/providers/local/activity_provider.dart';
import 'package:pax/providers/local/reward_currency_context.dart';
import 'package:pax/providers/local/withdraw_context_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/currency_symbol.dart';
import 'package:pax/utils/gradient_border.dart';
import 'package:pax/utils/token_balance_util.dart';
import 'package:pax/widgets/select_currency_button.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class CurrentBalanceCard extends ConsumerStatefulWidget {
  const CurrentBalanceCard(this.nextLocation, {super.key});

  final String nextLocation;

  @override
  ConsumerState<CurrentBalanceCard> createState() => _CurrentBalanceCardState();
}

class _CurrentBalanceCardState extends ConsumerState<CurrentBalanceCard> {
  @override
  Widget build(BuildContext context) {
    final paxAccount = ref.watch(paxAccountProvider);
    final selectedCurrency =
        ref.watch(rewardCurrencyContextProvider).selectedCurrency;
    final tokenId = TokenBalanceUtil.getTokenIdForCurrency(selectedCurrency);
    final currentBalance = paxAccount.account?.balances[tokenId];

    // Listen to the rewards stream
    final participantId = paxAccount.account?.id;
    ref.listen(rewardsStreamProvider(participantId), (previous, current) {
      // When the rewards change (any change), update the balances
      if (previous != current && current.hasValue) {
        // Update balance from blockchain
        ref.read(paxAccountProvider.notifier).syncBalancesFromBlockchain();
      }
    });

    return Container(
      decoration: ShapeDecoration(
        shape: GradientBorder(
          gradient: LinearGradient(
            colors: PaxColors.orangeToPinkGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          width: 2,
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Current Balance',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 20,
                  color: PaxColors.black,
                ),
              ).withPadding(bottom: 8),
            ],
          ),

          Row(
            children: [
              Text(
                TokenBalanceUtil.getFormattedBalanceByCurrency(
                  paxAccount.account?.balances,
                  selectedCurrency,
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  color: PaxColors.black,
                ),
              ).withPadding(right: 8),
              SvgPicture.asset(
                'lib/assets/svgs/currencies/$selectedCurrency.svg',
                height: 25,
              ),
            ],
          ).withPadding(bottom: 16),

          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.375,
                decoration: BoxDecoration(
                  color: PaxColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Select<String>(
                  itemBuilder: (context, item) {
                    return Row(
                      children: [
                        SvgPicture.asset(
                          'lib/assets/svgs/currencies/$item.svg',
                          height: 20,
                        ).withPadding(right: 8),
                        Text(CurrencySymbolUtil.getSymbolForCurrency(item)),
                      ],
                    );
                  },
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(rewardCurrencyContextProvider.notifier)
                          .setSelectedCurrency(value);

                      ref
                          .read(withdrawContextProvider.notifier)
                          .setWithdrawContext(
                            tokenId ?? 1,
                            currentBalance ?? 0,
                          );
                    }
                  },
                  value: selectedCurrency,
                  placeholder: const Text('Change currency'),
                  popup:
                      (context) => SelectPopup(
                        items: SelectItemList(
                          children: [
                            SelectCurrencyButton('good_dollar'),
                            SelectCurrencyButton('celo_dollar'),
                            SelectCurrencyButton('tether_usd'),
                            SelectCurrencyButton(
                              'usd_coin',
                            ).withPadding(bottom: kIsWeb ? 0 : 30),
                          ],
                        ),
                      ),
                ),
              ).withPadding(right: 8),

              Button(
                style:
                    const ButtonStyle.primary(density: ButtonDensity.normal)
                        .withBackgroundColor(color: PaxColors.deepPurple)
                        .withBorder(),
                onPressed:
                    currentBalance != null && currentBalance > 0
                        ? () async {
                          ref
                              .read(rewardCurrencyContextProvider.notifier)
                              .setSelectedCurrency(selectedCurrency);

                          ref
                              .read(withdrawContextProvider.notifier)
                              .setWithdrawContext(tokenId ?? 1, currentBalance);
                          context.go(widget.nextLocation);
                        }
                        : null,
                child: Text(
                  'Wallet',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: PaxColors.white,
                  ),
                ),
              ).withToolTip('Check out your wallet.'),
            ],
          ),
        ],
      ).withPadding(all: 12),
    );
  }
}

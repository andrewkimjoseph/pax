import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:pax/extensions/tooltip.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';
import 'package:pax/providers/local/reward_currency_context.dart';
import 'package:pax/providers/local/reward_state_provider.dart';
import 'package:pax/providers/local/withdraw_context_provider.dart';
import 'package:pax/providers/local/withdrawal_provider.dart';
import 'package:pax/providers/remote_config/remote_config_provider.dart';
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
    final participantId = paxAccount.account?.id;

    // Use the balance update provider
    ref.watch(balanceUpdateProvider(participantId));

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
                            SelectCurrencyButton(
                              'celo_dollar',
                            ).withPadding(bottom: kIsWeb ? 0 : 30),
                            // SelectCurrencyButton('tether_usd'),
                            // SelectCurrencyButton(
                            //   'usd_coin',
                            // ),
                          ],
                        ),
                      ),
                ),
              ).withPadding(right: 8),

              ref
                  .watch(featureFlagsProvider)
                  .when(
                    data: (flags) {
                      final isWalletAvailable =
                          flags['is_wallet_available'] ?? false;
                      if (!isWalletAvailable) return const SizedBox.shrink();

                      return Button(
                        style:
                            const ButtonStyle.primary(
                                  density: ButtonDensity.normal,
                                )
                                .withBackgroundColor(
                                  color: PaxColors.deepPurple,
                                )
                                .withBorder(),
                        onPressed:
                            currentBalance != null && currentBalance > 0
                                ? () async {
                                  ref
                                      .read(
                                        rewardCurrencyContextProvider.notifier,
                                      )
                                      .setSelectedCurrency(selectedCurrency);

                                  ref
                                      .read(withdrawContextProvider.notifier)
                                      .setWithdrawContext(
                                        tokenId ?? 1,
                                        currentBalance,
                                      );

                                  if (widget.nextLocation == "/wallet") {
                                    ref
                                        .read(analyticsProvider)
                                        .homeWalletTapped({
                                          "selectedCurrency": selectedCurrency,
                                          "currentBalance": currentBalance,
                                          "tokenId": tokenId,
                                          "toLocation": widget.nextLocation,
                                        });
                                  } else {
                                    ref
                                        .read(analyticsProvider)
                                        .walletWithdrawTapped({
                                          "selectedCurrency": selectedCurrency,
                                          "currentBalance": currentBalance,
                                          "tokenId": tokenId,
                                          "toLocation": widget.nextLocation,
                                        });
                                  }
                                  context.push(widget.nextLocation);
                                }
                                : null,
                        child: Text(
                          widget.nextLocation == "/wallet"
                              ? "Wallet"
                              : "Withdraw",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: PaxColors.white,
                          ),
                        ),
                      ).withToolTip('Check out your wallet.');
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
            ],
          ),
        ],
      ).withPadding(all: 12),
    );
  }
}

// Create a new provider to handle balance updates
final balanceUpdateProvider = Provider.family<void, String?>((
  ref,
  participantId,
) {
  // This will run whenever the rewards stream changes
  ref.watch(rewardsStreamProvider(participantId));

  // This will run whenever the withdrawals stream changes
  ref.watch(withdrawalsStreamProvider(participantId));

  // Schedule the balance sync for the next frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (participantId != null) {
      if (kDebugMode) {
        print("syncing balances from blockchain");
      }
      ref.read(paxAccountProvider.notifier).syncBalancesFromBlockchain();
    }
  });
});

import 'package:flutter/material.dart' show InkWell;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pax/providers/analytics/analytics_provider.dart';
import 'package:pax/providers/local/withdraw_context_provider.dart';

import 'package:pax/theming/colors.dart';
import 'package:pax/utils/currency_symbol.dart';
import 'package:pax/utils/token_balance_util.dart';

import 'package:shadcn_flutter/shadcn_flutter.dart';

class WithdrawView extends ConsumerStatefulWidget {
  const WithdrawView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WithdrawViewState();
}

class _WithdrawViewState extends ConsumerState<WithdrawView> {
  // Define a key for the amount field
  final _withdrawalAmountKey = const TextFieldKey(#amount);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final withdrawContext = ref.watch(withdrawContextProvider);
    final balance = withdrawContext?.balance ?? 0;
    final tokenId = withdrawContext?.tokenId ?? 0;

    // Create a proper validator using ValidatorBuilder

    final amountValidator = ConditionalValidator((String? value) {
      // Must return true if valid, false if invalid
      if (value == null || value.isEmpty) {
        return false; // Invalid: empty
      }

      try {
        // Check for more than 6 decimal places
        if (value.contains('.')) {
          final decimalPart = value.split('.')[1];
          if (decimalPart.length > 6) {
            return false; // Invalid: more than 6 decimal places
          }
        }

        // Parse the amount
        final amount = double.parse(value);

        // Valid if: amount > 0 AND amount <= balance
        return amount > 0 && amount <= balance;
      } catch (e) {
        return false; // Invalid: not a number
      }
    }, message: '');

    return Scaffold(
      backgroundColor: PaxColors.deepPurple,
      headers: [
        AppBar(
          padding: const EdgeInsets.all(8),
          backgroundColor: PaxColors.deepPurple,
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  context.pop();
                },
                child: SvgPicture.asset(
                  colorFilter: const ColorFilter.mode(
                    PaxColors.white,
                    BlendMode.srcIn,
                  ),
                  'lib/assets/svgs/arrow_left_long.svg',
                ),
              ),
              const Spacer(),
              const Text(
                "Withdraw",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: PaxColors.white),
              ),
              const Spacer(),
            ],
          ),
        ).withPadding(top: 16),
      ],

      child: Form(
        onSubmit: (context, values) {
          // Get the amount from form values and update the provider
          final String? withdrawalAmountString = values[_withdrawalAmountKey];

          if (withdrawalAmountString != null &&
              withdrawalAmountString.isNotEmpty) {
            try {
              final num amount = double.parse(withdrawalAmountString);
              // Update the amount in the provider
              ref
                  .read(withdrawContextProvider.notifier)
                  .setAmountToWithdraw(amount);

              ref.read(analyticsProvider).continueWithdrawTapped({
                "amount": amount,
                "tokenId": tokenId,
              });

              // Navigate to next screen
              context.push('/wallet/withdraw/select-wallet');
            } catch (e) {
              // Handle parsing error if needed
            }
          }
        },
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Enter amount",
                    style: TextStyle(fontSize: 16, color: PaxColors.white),
                  ).withPadding(right: 4),
                  FaIcon(FontAwesomeIcons.arrowUp19, color: PaxColors.white),
                ],
              ).withPadding(top: 16),

              const Spacer(flex: 1),

              // Wrap TextField with FormField
              Container(
                padding: const EdgeInsets.all(16),
                child: FormField(
                  label: const SizedBox.shrink(),
                  key: _withdrawalAmountKey,
                  validator: amountValidator,
                  showErrors: const {FormValidationMode.submitted},
                  child: TextField(
                    initialValue: TokenBalanceUtil.getLocaleFormattedAmount(
                      balance,
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    placeholder: Text('Enter amount'),
                    style: TextStyle(
                      fontSize: 32,
                      color: PaxColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    border: false,
                    cursorColor: PaxColors.white,
                  ).withAlign(Alignment.center),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Available balance:",
                    style: TextStyle(fontSize: 12, color: PaxColors.white),
                  ).withPadding(right: 4),

                  Text(
                    TokenBalanceUtil.getLocaleFormattedAmount(balance),
                    style: const TextStyle(
                      fontSize: 16,
                      color: PaxColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SvgPicture.asset(
                    'lib/assets/svgs/currencies/${CurrencySymbolUtil.getNameForCurrency(tokenId)}.svg',
                    height: 25,
                  ).withPadding(left: 4),
                ],
              ).withPadding(top: 8),

              const Spacer(flex: 2),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 16),
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        // Use FormErrorBuilder for button state management
                        child: FormErrorBuilder(
                          builder: (context, errors, child) {
                            return PrimaryButton(
                              onPressed:
                                  errors.isEmpty
                                      ? () => context.submitForm()
                                      : null,
                              child: Text(
                                'Continue',
                                style: Theme.of(
                                  context,
                                ).typography.base.copyWith(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  color: PaxColors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pax/models/local/withdrawal_state_model.dart';
import 'package:pax/providers/local/withdraw_context_provider.dart';
import 'package:pax/providers/local/withdrawal_provider.dart';
import 'package:pax/theming/colors.dart';
import 'package:pax/utils/currency_symbol.dart';
import 'package:pax/utils/token_address_util.dart';
import 'package:pax/utils/token_balance_util.dart';
import 'package:pax/widgets/change_withdrawal_method_card.dart';

import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider, Consumer;

class ReviewSummaryView extends ConsumerStatefulWidget {
  const ReviewSummaryView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ReviewSummaryViewState();
}

class _ReviewSummaryViewState extends ConsumerState<ReviewSummaryView> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Reset withdraw provider state after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(withdrawProvider.notifier).resetState();
    });
  }

  // Handle withdrawal process
  Future<void> _processWithdrawal() async {
    final withdrawContext = ref.read(withdrawContextProvider);
    if (withdrawContext == null) {
      _showErrorDialog('Withdrawal details not found');
      return;
    }

    final amountToWithdraw = withdrawContext.amountToWithdraw;
    final tokenId = withdrawContext.tokenId;
    final paymentMethod = withdrawContext.selectedPaymentMethod;

    if (paymentMethod == null) {
      _showErrorDialog('No payment method selected');
      return;
    }

    // Get currency address and decimals for the tokenId
    final currencyAddress = TokenAddressUtil.getAddressForCurrency(tokenId);
    final decimals = TokenAddressUtil.getDecimalsForCurrency(tokenId);

    setState(() {
      _isProcessing = true;
    });

    // Call withdraw provider to process the withdrawal
    ref
        .read(withdrawProvider.notifier)
        .withdrawToPaymentMethod(
          paymentMethodId: paymentMethod.id,
          amountToWithdraw: amountToWithdraw!.toDouble(),
          tokenId: tokenId,
          currencyAddress: currencyAddress,
          decimals: decimals,
        );

    // Show processing dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildProcessingDialog(),
    );

    setState(() {
      _isProcessing = false;
    });
  }

  // Dialog showing processing state
  Widget _buildProcessingDialog() {
    return Consumer(
      builder: (context, ref, _) {
        final withdrawState = ref.watch(withdrawProvider);

        // Handle different withdrawal states
        if (withdrawState.state == WithdrawState.success) {
          // Dismiss the dialog after a short delay
          Future.delayed(Duration(milliseconds: 500), () {
            if (context.mounted) {
              context.pop();
            }

            _showSuccessDialog();
          });
        } else if (withdrawState.state == WithdrawState.error) {
          // Dismiss the dialog after a short delay
          Future.delayed(Duration(milliseconds: 500), () {
            if (context.mounted) {
              context.pop();
            }
            _showErrorDialog(
              withdrawState.errorMessage ?? 'An unknown error occurred',
            );
          });
        }

        // Show loading indicator
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Processing your withdrawal...'),
            ],
          ),
        );
      },
    );
  }

  // Success dialog
  void _showSuccessDialog() {
    final withdrawContext = ref.read(withdrawContextProvider);
    final amountToWithdraw = withdrawContext?.amountToWithdraw ?? 0;

    final paymentMethod = withdrawContext?.selectedPaymentMethod;

    final tokenId = withdrawContext?.tokenId;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'lib/assets/svgs/withdrawal_complete.svg',
              ).withPadding(bottom: 8),

              const Text(
                'Withdrawal Complete!',
                style: TextStyle(
                  color: PaxColors.deepPurple,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ).withPadding(bottom: 8),

              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        TokenBalanceUtil.getLocaleFormattedAmount(
                          amountToWithdraw,
                        ),
                        style: TextStyle(
                          color: PaxColors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SvgPicture.asset(
                        'lib/assets/svgs/currencies/${CurrencySymbolUtil.getNameForCurrency(tokenId)}.svg',
                        height: 25,
                      ),
                    ],
                  ).withPadding(vertical: 4),
                  Text(
                    'sent to your ${toBeginningOfSentenceCase(paymentMethod?.name)} account!',
                    style: TextStyle(
                      color: PaxColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ).withPadding(vertical: 8),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.5,
                    child: PrimaryButton(
                      child: const Text('OK'),
                      onPressed: () {
                        (context).pop();
                        context.pushReplacement(
                          "/",
                        ); // Go back to previous screen
                      },
                    ),
                  ),
                ],
              ).withPadding(top: 8),
            ],
          ),
        );
      },
    );
  }

  // Error dialog
  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              SvgPicture.asset(
                'lib/assets/svgs/canvassing.svg',
                height: 24,
              ).withPadding(bottom: 16),
              Text(
                'Withdrawal Failed',
                style: TextStyle(fontSize: 16),
              ).withAlign(Alignment.center),
            ],
          ),
          content: Text(
            errorMessage,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            OutlineButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final withdrawContext = ref.watch(withdrawContextProvider);
    final amountToWithdraw = withdrawContext?.amountToWithdraw ?? 1;
    final tokenId = withdrawContext?.tokenId ?? 0;
    final paymentMethod = withdrawContext?.selectedPaymentMethod;

    return Scaffold(
      backgroundColor: PaxColors.white,
      headers: [
        AppBar(
          padding: EdgeInsets.all(8),
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
              Spacer(),
              Text(
                "Review Summary",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: PaxColors.black),
              ),
              Spacer(),
            ],
          ),
        ).withPadding(top: 16),
        Divider(color: PaxColors.lightGrey),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: PaxColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PaxColors.lightLilac, width: 1),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: PaxColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PaxColors.lightLilac, width: 1),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Balance Amount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Text(
                            TokenBalanceUtil.getLocaleFormattedAmount(
                              amountToWithdraw,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: PaxColors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SvgPicture.asset(
                            'lib/assets/svgs/currencies/${CurrencySymbolUtil.getNameForCurrency(tokenId)}.svg',
                            height: 25,
                          ).withPadding(left: 4),
                        ],
                      ).withPadding(bottom: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Gas Fee',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Free',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ).withPadding(bottom: 16),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Text(
                            TokenBalanceUtil.getLocaleFormattedAmount(
                              amountToWithdraw,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: PaxColors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SvgPicture.asset(
                            'lib/assets/svgs/currencies/${CurrencySymbolUtil.getNameForCurrency(tokenId)}.svg',
                            height: 25,
                          ).withPadding(left: 4),
                        ],
                      ).withPadding(vertical: 16),
                    ],
                  ),
                ).withPadding(bottom: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Payout to',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ).withPadding(vertical: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PaxColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PaxColors.lightLilac, width: 1),
                  ),
                  child: Column(
                    children:
                        paymentMethod != null
                            ? [ChangeWithdrawalMethodCard(paymentMethod)]
                            : [Text('No payment method selected')],
                  ),
                ),
              ],
            ),
          ),
          Spacer(flex: 2),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            color: Colors.white,
            child: Column(
              children: [
                Divider().withPadding(vertical: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: PrimaryButton(
                    // Disable button during processing
                    onPressed: _isProcessing ? null : _processWithdrawal,
                    child:
                        _isProcessing
                            ? CircularProgressIndicator(onSurface: true)
                            : Text(
                              'Withdraw',
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

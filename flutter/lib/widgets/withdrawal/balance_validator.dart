// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart' show SvgPicture;
// import 'package:go_router/go_router.dart';
// import 'package:pax/providers/local/withdraw_context_provider.dart';

// import 'package:pax/theming/colors.dart';
// import 'package:pax/utils/token_balance_util.dart';

// import 'package:shadcn_flutter/shadcn_flutter.dart';

// // Custom validator for checking if amount is less than or equal to balance
// class BalanceValidator extends Validator<String> {
//   final num balance;

//   const BalanceValidator({required this.balance});

//   @override
//   String? validate(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Amount is required';
//     }

//     try {
//       final amount = double.parse(value);
//       if (amount <= 0) {
//         return 'Amount must be greater than zero';
//       }
//       if (amount > balance) {
//         return 'Amount exceeds available balance';
//       }
//       return null;
//     } catch (e) {
//       return 'Please enter a valid number';
//     }
//   }
// }

// class WithdrawView extends ConsumerStatefulWidget {
//   const WithdrawView({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _WithdrawViewState();
// }

// class _WithdrawViewState extends ConsumerState<WithdrawView> {
//   // Define form field key
//   final _amountKey = const TextFieldKey('amount');

//   @override
//   Widget build(BuildContext context) {
//     final withdrawContext = ref.watch(withdrawContextProvider);
//     final balance = withdrawContext?.balance ?? 0;

//     return Scaffold(
//       backgroundColor: PaxColors.deepPurple,
//       headers: [
//         AppBar(
//           padding: const EdgeInsets.all(8),
//           backgroundColor: PaxColors.deepPurple,
//           child: Row(
//             children: [
//               GestureDetector(
//                 behavior: HitTestBehavior.translucent,
//                 onPanDown: (details) {
//                   context.pop();
//                 },
//                 child: SvgPicture.asset(
//                   colorFilter: const ColorFilter.mode(
//                     PaxColors.white,
//                     BlendMode.srcIn,
//                   ),
//                   'lib/assets/svgs/arrow_left_long.svg',
//                 ),
//               ),
//               const Spacer(),
//               const Text(
//                 "Withdraw",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 20, color: PaxColors.white),
//               ),
//               const Spacer(),
//             ],
//           ),
//         ).withPadding(top: 16),
//       ],

//       child: GestureDetector(
//         onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
//         child: Form(
//           onSubmit: (context, values) {
//             // Get the amount from form values
//             String? amount = _amountKey[values];
//             // Navigate to the next screen
//             context.go('/wallet/withdraw/select-wallet');
//           },
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const Text(
//                 "Enter amount of balance you want to payout",
//                 style: TextStyle(fontSize: 16, color: PaxColors.white),
//               ).withPadding(top: 16),
//               const Spacer(flex: 1),
              
//               // Amount input field using FormField
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 child: FormField(
//                   key: _amountKey,
//                   // Use custom validator to check against balance
//                   validator: BalanceValidator(balance: balance),
//                   child: TextField(
//                     keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                     textAlign: TextAlign.center,
//                     placeholder: const Text('Enter amount'),
//                     style: const TextStyle(
//                       fontSize: 32,
//                       color: PaxColors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     border: false,
//                     cursorColor: PaxColors.white,
//                     // Use shadcn's built-in filtering capabilities
//                     features: [
//                       TextFieldFeature.number(decimal: true),
//                     ],
//                   ),
//                 ),
//               ),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     "Available balance:",
//                     style: TextStyle(fontSize: 12, color: PaxColors.white),
//                   ).withPadding(right: 4),
//                   Text(
//                     TokenBalanceUtil.getLocaleFormattedAmount(balance),
//                     style: const TextStyle(
//                       fontSize: 16,
//                       color: PaxColors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ).withPadding(top: 8),

//               const Spacer(flex: 2),

//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.only(top: 16),
//                 color: Colors.white,
//                 child: Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: SizedBox(
//                         width: double.infinity,
//                         height: 48,
//                         // Use FormErrorBuilder to disable button when there are errors
//                         child: FormErrorBuilder(
//                           builder: (context, errors, child) {
//                             return PrimaryButton(
//                               // Button is enabled only when there are no errors
//                               onPressed: errors.isEmpty 
//                                   ? () => context.submitForm() 
//                                   : null,
//                               child: Text(
//                                 'Continue',
//                                 style: Theme.of(context).typography.base.copyWith(
//                                   fontWeight: FontWeight.normal,
//                                   fontSize: 14,
//                                   color: PaxColors.white,
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                     // Add extra space at the bottom to ensure it pushes past safe area
//                     const SizedBox(height: 50),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
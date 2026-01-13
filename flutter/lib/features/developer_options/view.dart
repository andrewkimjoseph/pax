// import 'package:flutter/material.dart' show Divider, InkWell;
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart' show SvgPicture;
// import 'package:go_router/go_router.dart';
// import 'package:pax/theming/colors.dart';
// import 'package:pax/widgets/help_and_support.dart';
// import 'package:shadcn_flutter/shadcn_flutter.dart' hide Divider;

// class DeveloperOptionsView extends ConsumerStatefulWidget {
//   const DeveloperOptionsView({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _DeveloperOptionsViewState();
// }

// class _DeveloperOptionsViewState extends ConsumerState<DeveloperOptionsView> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       headers: [
//         AppBar(
//           padding: EdgeInsets.all(8),
//           backgroundColor: PaxColors.white,
//           child: Row(
//             children: [
//               InkWell(
//                 onTap: () {
//                   context.pop();
//                 },
//                 child: SvgPicture.asset('lib/assets/svgs/arrow_left_long.svg'),
//               ),
//               Spacer(),
//               Text(
//                 "Developer Options",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 20),
//               ).withPadding(right: 16),
//               Spacer(),
//             ],
//           ),
//         ).withPadding(top: 16),
//         Divider(color: PaxColors.lightGrey),
//       ],
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               padding: EdgeInsets.all(12),
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: PaxColors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: PaxColors.lightLilac, width: 1),
//               ),
//               child: Column(
//                 spacing: 24,
//                 children: [
//                   InkWell(
//                     onTap: _onTestSubmitForFormsTapped,
//                     child: HelpAndSupportCard('Test Submit for Forms'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ).withPadding(horizontal: 8, bottom: 8),
//     );
//   }

//   void _onTestSubmitForFormsTapped() {
//     context.push("/developer-options/test-submit-for-forms");
//   }
// }

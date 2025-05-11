import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:pax/theming/colors.dart';

class TaskPageView extends StatefulWidget {
  const TaskPageView({super.key});

  @override
  State<TaskPageView> createState() => _TaskPageViewState();
}

class _TaskPageViewState extends State<TaskPageView> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize the WebViewController
    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                setState(() {
                  isLoading = true;
                });
              },
              onPageFinished: (String url) {
                setState(() {
                  isLoading = false;
                });
              },
              onNavigationRequest: (NavigationRequest request) {
                // Check if the URL is a Play Store link or other external link
                if (request.url.startsWith('pax://')) {
                  // Handle the callback from Tally

                  context.pushReplacement('/task/task-complete');

                  // showDialog(
                  //   context: context,
                  //   builder: (context) {
                  //     return AlertDialog(
                  //       // title: const Text('Alert title'),
                  //       content: Column(
                  //         children: [
                  //           SvgPicture.asset(
                  //             'lib/assets/svgs/withdrawal_complete.svg',
                  //           ).withPadding(bottom: 8),

                  //           const Text(
                  //             'Withdrawal Complete!',
                  //             style: TextStyle(
                  //               color: PaxColors.deepPurple,
                  //               fontSize: 28,
                  //               fontWeight: FontWeight.bold,
                  //             ),
                  //           ).withPadding(bottom: 8),
                  //           const Text(
                  //             '\$30 has been successfully transferred to your MiniPay account.',
                  //             style: TextStyle(
                  //               color: PaxColors.black,
                  //               fontSize: 16,
                  //               fontWeight: FontWeight.normal,
                  //             ),
                  //             textAlign: TextAlign.center,
                  //           ).withPadding(bottom: 8),

                  //           Row(
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             children: [
                  //               SizedBox(
                  //                 width:
                  //                     MediaQuery.of(context).size.width / 2.5,
                  //                 child: PrimaryButton(
                  //                   child: const Text('OK'),
                  //                   onPressed: () {
                  //                     context.pop();
                  //                   },
                  //                 ),
                  //               ),
                  //             ],
                  //           ).withPadding(top: 8),
                  //         ],
                  //       ),
                  //     );
                  //   },
                  // ); // Go back to the previous page
                  return NavigationDecision.prevent;
                }
                // Allow the WebView to handle regular web URLs
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse('https://tally.so/r/3yG27p'));
  }

  // Method to launch URLs in external apps

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: SvgPicture.asset(
                  'lib/assets/svgs/arrow_left_long.svg',
                ).withPadding(left: 16),
              ),
              Spacer(),
              Text(
                "Task",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ).withPadding(right: 16),
              Spacer(),
            ],
          ),
        ).withPadding(top: 16),
        Divider(color: PaxColors.lightGrey),
      ],
      child: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

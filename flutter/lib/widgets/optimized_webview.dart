import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Optimized WebView widget with quality improvements for production
class OptimizedWebView extends ConsumerStatefulWidget {
  final WebViewController controller;
  final bool isLoading;
  final Widget? loadingWidget;

  const OptimizedWebView({
    super.key,
    required this.controller,
    this.isLoading = false,
    this.loadingWidget,
  });

  @override
  ConsumerState<OptimizedWebView> createState() => _OptimizedWebViewState();
}

class _OptimizedWebViewState extends ConsumerState<OptimizedWebView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PaxColors.white,
        // Add subtle border to improve visual quality
        border: Border.all(
          color: PaxColors.lightGrey.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: ClipRect(child: WebViewWidget(controller: widget.controller)),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pax/theming/colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Optimized WebView widget using InAppWebView with quality improvements for production
class OptimizedWebView extends ConsumerStatefulWidget {
  final URLRequest? initialUrlRequest;
  final void Function(InAppWebViewController controller)? onWebViewCreated;
  final void Function(InAppWebViewController controller, WebUri? url)? onLoadStart;
  final void Function(InAppWebViewController controller, WebUri? url)? onLoadStop;
  final Future<NavigationActionPolicy?> Function(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  )? shouldOverrideUrlLoading;
  final bool isLoading;
  final Widget? loadingWidget;

  const OptimizedWebView({
    super.key,
    this.initialUrlRequest,
    this.onWebViewCreated,
    this.onLoadStart,
    this.onLoadStop,
    this.shouldOverrideUrlLoading,
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
        border: Border.all(
          color: PaxColors.lightGrey.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: ClipRect(
        child: InAppWebView(
          initialUrlRequest: widget.initialUrlRequest,
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            useWideViewPort: true,
            useOnLoadResource: false,
          ),
          onWebViewCreated: widget.onWebViewCreated,
          onLoadStart: widget.onLoadStart,
          onLoadStop: widget.onLoadStop,
          shouldOverrideUrlLoading: widget.shouldOverrideUrlLoading,
        ),
      ),
    );
  }
}

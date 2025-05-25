import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Handles launching URLs either in an external browser or in-app WebView
class UrlHandler {
  /// Launches a URL in an in-app browser view
  static Future<void> launchInAppBrowserView(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
        throw Exception('Could not launch URL: $url');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Launches a URL in the device's external browser
  static Future<void> launchInExternalBrowser(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch URL: $url');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Launches a URL in an in-app WebView
  static void launchInAppWebView(BuildContext context, String url) {
    if (url.isEmpty) {
      throw ArgumentError('URL cannot be empty');
    }
    context.push('/webview', extra: url);
  }
}

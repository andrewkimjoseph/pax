import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tabs;
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

  // /// Launches a URL in the device's external browser
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

  static void launchInAppWebView(BuildContext context, String url) {
    if (url.isEmpty) {
      throw ArgumentError('URL cannot be empty');
    }
    context.push('/webview', extra: url);
  }

  static Future<void> launchCustomTab(BuildContext context, String url) async {
    if (url.isEmpty) {
      throw ArgumentError('URL cannot be empty');
    }

    final theme = Theme.of(context);

    await custom_tabs.launchUrl(
      Uri.parse(url),
      customTabsOptions: custom_tabs.CustomTabsOptions(
        colorSchemes: custom_tabs.CustomTabsColorSchemes.defaults(
          toolbarColor: theme.colorScheme.primary,
        ),
        shareState: custom_tabs.CustomTabsShareState.off,
        urlBarHidingEnabled: true,
        showTitle: true,
        closeButton: custom_tabs.CustomTabsCloseButton(
          icon: custom_tabs.CustomTabsCloseButtonIcons.back,
        ),
        bookmarksButtonEnabled: false,
        downloadButtonEnabled: false,
      ),
    );
  }
}

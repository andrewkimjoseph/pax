import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

class BranchService {
  static final BranchService _instance = BranchService._internal();
  factory BranchService() => _instance;
  BranchService._internal();

  StreamSubscription<Map>? _linkDataStreamSubscription;
  Function(Map<dynamic, dynamic>)? _deepLinkHandler;
  bool _isListening = false;

  /// Completer to track SDK initialization status
  static final Completer<void> _sdkInitCompleter = Completer<void>();

  /// Whether the Branch SDK has been initialized
  static bool _sdkInitialized = false;

  /// Called when FlutterBranchSdk.init() completes successfully
  static void markSdkInitialized() {
    if (!_sdkInitialized) {
      _sdkInitialized = true;
      if (!_sdkInitCompleter.isCompleted) {
        _sdkInitCompleter.complete();
      }
      if (kDebugMode) {
        print('BranchService: SDK marked as initialized');
      }
    }
  }

  /// Wait for the SDK to be initialized
  static Future<void> waitForSdkInit() => _sdkInitCompleter.future;

  void init({required Function(Map<dynamic, dynamic>) deepLinkHandler}) {
    _deepLinkHandler = deepLinkHandler;
    if (kDebugMode) {
      print('BranchService: Initialized with deep link handler');
    }
  }

  Future<void> listenToDeepLinks() async {
    if (_deepLinkHandler == null) {
      if (kDebugMode) {
        print(
          'BranchService: Error: Deep link handler not set before listening.',
        );
      }
      return;
    }

    if (_isListening) {
      if (kDebugMode) {
        print('BranchService: Already listening to deep links');
      }
      return;
    }

    // Wait for SDK to be initialized before listening
    if (!_sdkInitialized) {
      if (kDebugMode) {
        print('BranchService: Waiting for SDK initialization...');
      }
      await waitForSdkInit();
    }

    if (kDebugMode) {
      print('BranchService: Starting deep link listener');
    }
    _linkDataStreamSubscription = FlutterBranchSdk.listSession().listen(
      (linkData) {
        if (kDebugMode) {
          print('BranchService: Deep link being listened to: $linkData');
        }
        // Only handle deep links if they contain actual link data
        if (linkData.isNotEmpty && linkData['+clicked_branch_link'] == true) {
          _deepLinkHandler?.call(linkData);
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('BranchService: Error receiving deep link: $error');
        }
      },
    );
    _isListening = true;
  }

  void dispose() {
    if (kDebugMode) {
      print('BranchService: Disposing deep link listener');
    }
    _linkDataStreamSubscription?.cancel();
    _deepLinkHandler = null;
    _isListening = false;
  }
}

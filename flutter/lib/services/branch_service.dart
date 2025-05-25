import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

class BranchService {
  static final BranchService _instance = BranchService._internal();
  factory BranchService() => _instance;
  BranchService._internal();

  StreamSubscription<Map>? _linkDataStreamSubscription;
  Function(Map<dynamic, dynamic>)? _deepLinkHandler;
  bool _isInitialized = false;

  void init({required Function(Map<dynamic, dynamic>) deepLinkHandler}) {
    _deepLinkHandler = deepLinkHandler;
    if (kDebugMode) {
      print('BranchService: Initialized with deep link handler');
    }
  }

  void listenToDeepLinks() {
    if (_deepLinkHandler == null) {
      if (kDebugMode) {
        print(
          'BranchService: Error: Deep link handler not set before listening.',
        );
      }
      return;
    }

    if (_isInitialized) {
      if (kDebugMode) {
        print('BranchService: Already listening to deep links');
      }
      return;
    }

    if (kDebugMode) {
      print('BranchService: Starting deep link listener');
    }
    _linkDataStreamSubscription = FlutterBranchSdk.listSession().listen(
      (linkData) {
        if (kDebugMode) {
          print('BranchService: Deep link received: $linkData');
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
    _isInitialized = true;
  }

  void dispose() {
    if (kDebugMode) {
      print('BranchService: Disposing deep link listener');
    }
    _linkDataStreamSubscription?.cancel();
    _deepLinkHandler = null;
    _isInitialized = false;
  }
}

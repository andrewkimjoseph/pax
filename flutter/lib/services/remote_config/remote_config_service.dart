import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:pax/models/remote_config/app_version_config.dart';
import 'dart:convert';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        print('Remote Config Service: Already initialized');
      }
      return;
    }

    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: Duration.zero,
        ),
      );

      await _remoteConfig.fetchAndActivate();
      _isInitialized = true;

      if (kDebugMode) {
        print('Remote Config Service: Successfully initialized');
        print(
          'Remote Config Service: All parameters: ${_remoteConfig.getAll()}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Remote Config Service: Error initializing: $e');
      }
      rethrow;
    }
  }

  Future<AppVersionConfig> getAppVersionConfig() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (kDebugMode) {
        print(
          'Remote Config Service: All parameters: ${_remoteConfig.getAll()}',
        );
      }

      final jsonString = _remoteConfig.getString('app_version_config');
      if (kDebugMode) {
        print('Remote Config Service: Raw config string: $jsonString');
      }

      if (jsonString.isEmpty) {
        throw Exception('App version config not found in remote config');
      }

      final Map<String, dynamic> configMap = json.decode(jsonString);
      if (kDebugMode) {
        print('Remote Config Service: Parsed config map: $configMap');
      }

      return AppVersionConfig.fromJson(configMap);
    } catch (e) {
      if (kDebugMode) {
        print('Remote Config Service: Error getting app version config: $e');
      }
      rethrow;
    }
  }

  Future<void> refreshConfig() async {
    try {
      await _remoteConfig.fetchAndActivate();
      if (kDebugMode) {
        print('Remote Config Service: Config refreshed successfully');
        print(
          'Remote Config Service: All parameters after refresh: ${_remoteConfig.getAll()}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Remote Config Service: Error refreshing config: $e');
      }
      rethrow;
    }
  }
}

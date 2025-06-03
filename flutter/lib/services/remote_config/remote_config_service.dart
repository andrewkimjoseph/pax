import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pax/models/remote_config/app_version_config.dart';
import 'package:pax/models/remote_config/maintenance_config.dart';
import 'dart:convert';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  bool _isInitialized = false;
  DateTime? _lastFetchTime;
  static const _refreshInterval = Duration(seconds: 3);

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

      // Set default values before fetching
      await _remoteConfig.setDefaults({
        'app_version_config': json.encode({
          'minimum_version': '1.0.0',
          'current_version': '1.0.0',
          'force_update': false,
          'update_message': 'A new version is available',
          'update_url':
              'https://play.google.com/store/apps/details?id=app.thepax.android',
        }),
        'maintenance_config': json.encode({
          'is_under_maintenance': false,
          'maintenance_message': 'The app is currently under maintenance',
        }),
        'feature_flags': json.encode({
          'is_wallet_available': true,
          'is_achievements_available': true,
          'are_tasks_available': true,
        }),
      });

      final bool activated = await _remoteConfig.fetchAndActivate();
      _isInitialized = true;
      _lastFetchTime = DateTime.now();

      if (kDebugMode) {
        print('Remote Config Service: Successfully initialized');
        print(
          'Remote Config Service: Config ${activated ? "activated" : "not activated"}',
        );
        print(
          'Remote Config Service: All parameters: ${_remoteConfig.getAll().map((key, value) => MapEntry(key, value.asString()))}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Remote Config Service: Error initializing: $e');
      }
      // Set initialized to true even on error to prevent infinite retry loops
      _isInitialized = true;
      rethrow;
    }
  }

  Future<AppVersionConfig> getAppVersionConfig() async {
    if (!_isInitialized) {
      await initialize();
    }

    // Force refresh if last fetch was more than 3 seconds ago
    if (_lastFetchTime == null ||
        DateTime.now().difference(_lastFetchTime!) > _refreshInterval) {
      await refreshConfig();
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
        // Return default config if no remote config is available
        return AppVersionConfig(
          minimumVersion: '1.0.0',
          currentVersion: '1.0.0',
          forceUpdate: false,
          updateMessage: 'A new version is available',
          updateUrl:
              'https://play.google.com/store/apps/details?id=com.pax.app',
        );
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
      // Return default config on error
      return AppVersionConfig(
        minimumVersion: '1.0.0',
        currentVersion: '1.0.0',
        forceUpdate: false,
        updateMessage: 'A new version is available',
        updateUrl: 'https://play.google.com/store/apps/details?id=com.pax.app',
      );
    }
  }

  Future<MaintenanceConfig> getMaintenanceConfig() async {
    if (!_isInitialized) {
      await initialize();
    }

    // Force refresh if last fetch was more than 3 seconds ago
    if (_lastFetchTime == null ||
        DateTime.now().difference(_lastFetchTime!) > _refreshInterval) {
      await refreshConfig();
    }

    try {
      if (kDebugMode) {
        print(
          'Remote Config Service: All parameters: ${_remoteConfig.getAll()}',
        );
      }

      final jsonString = _remoteConfig.getString('maintenance_config');
      if (kDebugMode) {
        print(
          'Remote Config Service: Raw maintenance config string: $jsonString',
        );
      }

      if (jsonString.isEmpty) {
        // Return default config if no remote config is available
        return MaintenanceConfig(
          isUnderMaintenance: false,
          message: 'The app is currently under maintenance',
        );
      }

      final Map<String, dynamic> configMap = json.decode(jsonString);
      if (kDebugMode) {
        print(
          'Remote Config Service: Parsed maintenance config map: $configMap',
        );
      }

      return MaintenanceConfig.fromJson(configMap);
    } catch (e) {
      if (kDebugMode) {
        print('Remote Config Service: Error getting maintenance config: $e');
      }
      // Return default config on error
      return MaintenanceConfig(
        isUnderMaintenance: false,
        message: 'The app is currently under maintenance',
      );
    }
  }

  Future<void> refreshConfig() async {
    if (!_isInitialized) {
      await initialize();
    }

    int retryCount = 0;
    const maxRetries = 2;
    const retryDelay = Duration(seconds: 5);

    while (retryCount < maxRetries) {
      try {
        if (kDebugMode) {
          print(
            'Remote Config Service: Attempting to fetch config (attempt ${retryCount + 1}/$maxRetries)',
          );
        }

        final bool activated = await _remoteConfig.fetchAndActivate();
        _lastFetchTime = DateTime.now();

        if (kDebugMode) {
          print(
            'Remote Config Service: Config refresh ${activated ? "successful" : "not activated"}',
          );
          print(
            'Remote Config Service: All parameters after refresh: ${_remoteConfig.getAll().map((key, value) => MapEntry(key, value.asString()))}',
          );
        }
        return;
      } catch (e) {
        retryCount++;
        if (kDebugMode) {
          print(
            'Remote Config Service: Error refreshing config (attempt $retryCount/$maxRetries): $e',
          );
          if (e is PlatformException) {
            print('Remote Config Service: Error code: ${e.code}');
            print('Remote Config Service: Error message: ${e.message}');
            print('Remote Config Service: Error details: ${e.details}');
          }
        }

        if (retryCount == maxRetries) {
          if (kDebugMode) {
            print('Remote Config Service: Max retries reached, giving up');
          }
          return;
        }

        await Future.delayed(retryDelay);
      }
    }
  }

  Future<Map<String, bool>> getFeatureFlags() async {
    if (!_isInitialized) {
      await initialize();
    }

    // Force refresh if last fetch was more than 3 seconds ago
    if (_lastFetchTime == null ||
        DateTime.now().difference(_lastFetchTime!) > _refreshInterval) {
      await refreshConfig();
    }

    try {
      final jsonString = _remoteConfig.getString('feature_flags');
      if (kDebugMode) {
        print('Remote Config Service: Raw feature flags string: $jsonString');
      }

      if (jsonString.isEmpty) {
        // Return default config if no remote config is available
        return {
          'is_wallet_available': true,
          'is_achievements_available': true,
          'are_tasks_available': true,
        };
      }

      final Map<String, dynamic> configMap = json.decode(jsonString);
      if (kDebugMode) {
        print('Remote Config Service: Parsed feature flags map: $configMap');
      }

      return {
        'is_wallet_available': configMap['is_wallet_available'] ?? true,
        'is_achievements_available':
            configMap['is_achievements_available'] ?? true,
        'are_tasks_available': configMap['are_tasks_available'] ?? true,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Remote Config Service: Error getting feature flags: $e');
      }
      // Return default config on error
      return {
        'is_wallet_available': true,
        'is_achievements_available': true,
        'are_tasks_available': true,
      };
    }
  }
}

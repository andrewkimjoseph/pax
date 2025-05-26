import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:amplitude_flutter/events/identify.dart';
import 'package:flutter/foundation.dart';

/// A service class that handles all analytics events using Amplitude.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;

  late final Amplitude _amplitude;
  bool _isInitialized = false;

  AnalyticsService._internal();

  /// Initializes the analytics service with the provided API key.
  Future<void> initialize(String apiKey) async {
    if (_isInitialized) {
      if (kDebugMode) print('Analytics Service: Already initialized');
      return;
    }

    try {
      _amplitude = Amplitude(Configuration(apiKey: apiKey));
      _isInitialized = await _amplitude.isBuilt;
      if (kDebugMode) print('Analytics Service: Successfully initialized');
    } catch (e) {
      if (kDebugMode) print('Analytics Service: Error initializing: $e');
    }
  }

  /// Sets the user ID for analytics tracking.
  Future<void> setUserId(String userId) async {
    if (!_isInitialized) return;
    await _amplitude.setUserId(userId);
  }

  /// Logs an event with optional properties.
  Future<void> logEvent(
    String eventName, {
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) return;
    await _amplitude.track(BaseEvent(eventName, eventProperties: properties));
  }

  /// Logs a user property.
  Future<void> identifyUser(Map<String, dynamic> userProperties) async {
    if (!_isInitialized) return;

    final Identify identity = Identify();

    userProperties.forEach((property, value) {
      identity.set(property, value);
    });
    await _amplitude.identify(identity);
  }

  /// Resets the user ID and clears all user properties.
  Future<void> resetUser() async {
    if (!_isInitialized) return;
    await _amplitude.reset();
  }
}

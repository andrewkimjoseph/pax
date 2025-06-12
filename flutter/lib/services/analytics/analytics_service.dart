import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/default_tracking.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:amplitude_flutter/events/identify.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A service class that handles all analytics events using Amplitude.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;

  late final Amplitude _amplitude;

  late final FirebaseAnalytics _firebaseAnalytics;
  bool _isInitialized = false;

  AnalyticsService._internal();

  /// Converts all top-level property values to strings
  Map<String, String> _convertValuesToString(Map<String, dynamic> properties) {
    return Map.fromEntries(
      properties.entries.map((entry) {
        String value;
        if (entry.value == null) {
          value = '';
        } else if (entry.value is DateTime) {
          value = (entry.value as DateTime).toIso8601String();
        } else if (entry.value is Timestamp) {
          value = (entry.value as Timestamp).toDate().toIso8601String();
        } else {
          value = entry.value.toString();
        }
        return MapEntry(entry.key, value);
      }),
    );
  }

  /// Initializes the analytics service with the provided API key.
  Future<void> initialize(String apiKey) async {
    if (_isInitialized) {
      if (kDebugMode) print('Analytics Service: Already initialized');
      return;
    }

    try {
      _amplitude = Amplitude(
        Configuration(
          apiKey: apiKey,
          defaultTracking: DefaultTrackingOptions.all(),
        ),
      );

      _firebaseAnalytics = FirebaseAnalytics.instance;
      _isInitialized = await _amplitude.isBuilt;
      if (kDebugMode) print('Analytics Service: Successfully initialized');
    } catch (e) {
      if (kDebugMode) print('Analytics Service: Error initializing: $e');
    }
  }

  /// Sets the user ID for analytics tracking.
  Future<void> setUserId(String participantId) async {
    if (!_isInitialized) return;
    await _amplitude.setUserId(participantId);
    await _firebaseAnalytics.setUserId(id: participantId);
  }

  /// Logs an event with optional properties.
  Future<void> logEvent(
    String eventName, {
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) return;

    Map<String, String>? convertedProperties;
    if (properties != null) {
      convertedProperties = _convertValuesToString(properties);
    }

    await _amplitude.track(
      BaseEvent(eventName, eventProperties: convertedProperties),
    );
    await _firebaseAnalytics.logEvent(
      name: eventName,
      parameters: convertedProperties,
    );
  }

  /// Logs a user property.
  Future<void> identifyUser(Map<String, dynamic> userProperties) async {
    if (!_isInitialized) return;

    final Identify identity = Identify();
    final convertedProperties = _convertValuesToString(userProperties);

    convertedProperties.forEach((property, value) {
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

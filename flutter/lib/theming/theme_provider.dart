import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pax/theming/color_scheme.dart';
import 'package:pax/theming/typography.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Colors;

/// Provider for accessing and managing the application theme.
///
/// This provider makes the current ThemeData accessible throughout the app
/// and allows components to listen for theme changes.
///
/// Usage example:
/// ```dart
/// final theme = ref.watch(themeProvider);
/// ```
final themeProvider = NotifierProvider<ThemeNotifier, ThemeData>(
  ThemeNotifier.new,
);

/// Houses main theme settings and handles theme switching.
///
/// This notifier manages the application's theme state and provides
/// methods to toggle between light and dark themes.
class ThemeNotifier extends Notifier<ThemeData> {
  /// Light color scheme from PaxColorScheme
  final ColorScheme light = PaxColorScheme.light;

  /// Dark color scheme from PaxColorScheme
  final ColorScheme dark = PaxColorScheme.dark;

  /// Typography configuration using PaxTypography
  final Typography typography = PaxTypography();

  /// Switches to light theme.
  ///
  /// Updates the current theme state with the light color scheme.
  void toggleLight() {
    state = state.copyWith(colorScheme: light);
  }

  /// Switches to dark theme.
  ///
  /// Updates the current theme state with the dark color scheme.
  void toggleDark() {
    state = state.copyWith(colorScheme: dark);
  }

  /// Builds the initial theme data.
  ///
  /// This method is called when the notifier is first created,
  /// establishing the default theme for the application.
  @override
  ThemeData build() {
    return ThemeData(colorScheme: light, typography: typography, radius: 0.7);
  }
}

import 'package:flutter/foundation.dart' show Brightness;
import 'package:flutter/material.dart' show Color, Colors;
import 'package:shadcn_flutter/shadcn_flutter.dart' show ColorScheme;

import 'colors.dart';

/// A custom color scheme implementation for the Pax design system.
///
/// This class provides predefined color schemes for both light and dark modes,
/// as well as additional color constants for specific UI components.
/// All colors are sourced from the PaxColors utility class.
class PaxColorScheme {
  /// Light theme color scheme.
  ///
  /// Defines a complete set of colors optimized for light mode interfaces.
  /// Primary colors use purple tones with orange accent highlights.
  static final ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    background: PaxColors.white, // Main app background
    foreground: PaxColors.black, // Primary text color
    card: PaxColors.lilac, // Standard card background
    cardForeground: PaxColors.white, // Text color on cards
    popover: PaxColors.white, // Popover/modal background
    popoverForeground: PaxColors.deepPurple, // Text on popovers
    primary: PaxColors.deepPurple, // Primary action color (buttons, etc.)
    primaryForeground: PaxColors.white, // Text on primary colored elements
    secondary: Colors.transparent, // Secondary actions background
    secondaryForeground: PaxColors.deepPurple, // Secondary action text
    muted: PaxColors.lightLilac, // De-emphasized UI elements
    mutedForeground: PaxColors.mediumPurple, // Text on muted elements
    accent: PaxColors.orange, // Highlight/accent color
    accentForeground: PaxColors.deepPurple, // Text on accent elements
    destructive: PaxColors.redWithOpacity, // Error/warning actions background
    destructiveForeground: PaxColors.red, // Error/warning text
    border: PaxColors.lightGrey, // Standard border color
    input: PaxColors.lightLilac, // Input field background
    ring: PaxColors.mediumPurple, // Focus ring color
    // Chart colors for data visualization
    chart1: PaxColors.lilac,
    chart2: PaxColors.orange,
    chart3: PaxColors.pink,
    chart4: PaxColors.mediumPurple,
    chart5: PaxColors.deepPurple,
  );

  /// Dark theme color scheme.
  ///
  /// Defines a complete set of colors optimized for dark mode interfaces.
  /// Uses a primarily black and gray palette with colored accents.
  static final ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    background: Colors.black, // Main app background
    foreground: Colors.white, // Primary text color
    card: Colors.grey, // Standard card background
    cardForeground: Colors.white, // Text color on cards
    popover: Colors.grey, // Popover/modal background
    popoverForeground: Colors.white, // Text on popovers
    primary: Colors.grey, // Primary action color
    primaryForeground: Colors.white, // Text on primary colored elements
    secondary: Colors.grey, // Secondary actions background
    secondaryForeground: Colors.white, // Secondary action text
    muted: Colors.grey, // De-emphasized UI elements
    mutedForeground: Colors.black, // Text on muted elements
    accent: Colors.blue, // Highlight/accent color
    accentForeground: Colors.white, // Text on accent elements
    destructive: Colors.red, // Error/warning actions background
    destructiveForeground: Colors.white, // Error/warning text
    border: Colors.grey, // Standard border color
    input: Colors.grey, // Input field background
    ring: Colors.blue, // Focus ring color
    // Chart colors for data visualization
    chart1: Colors.green,
    chart2: Colors.orange,
    chart3: Colors.yellow,
    chart4: Colors.pink,
    chart5: Colors.teal,
  );

  /// Additional specialized colors for specific component variants.
  ///
  /// These colors extend beyond the base ColorScheme to provide options
  /// for custom UI components and states.

  /// Alternative card style with white background and black text
  static const Color card2 = PaxColors.white;
  static const Color card2Foreground = PaxColors.black;

  /// Button outline/stroke color
  static const Color buttonStroke = PaxColors.lilac;

  /// Specialized border color for input fields
  static const Color inputBorder = PaxColors.mediumPurple;

  /// Lighter variant of the destructive color for subtle warnings
  static const Color destructiveLight = PaxColors.whiteWithOpacity;

  /// Gradient colors for card3 component, transitioning from orange to pink
  static const List<Color> card3Gradient = PaxColors.orangeToPinkGradient;
}

// Example gradient color usage

/// Get the starting color of the orange-to-pink gradient (orange)
Color startColor = PaxColors.orangeToPinkGradient.first;

/// Get the ending color of the orange-to-pink gradient (pink)
Color endColor = PaxColors.orangeToPinkGradient.last;

/// Calculate an interpolated color at the middle point of the gradient
/// This creates a smooth transition between the start and end colors
Color? middleColor = Color.lerp(
  PaxColors.orangeToPinkGradient.first,
  PaxColors.orangeToPinkGradient.last,
  0.5, // 0.5 represents the middle position (50%)
);

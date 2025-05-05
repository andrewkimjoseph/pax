import 'package:flutter/material.dart' show TextTheme;
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

/// The default text theme for the Pax design system.
///
/// This text theme uses DM Sans as the primary font family throughout the application.
/// DM Sans is a low-contrast geometric sans-serif design that provides excellent
/// readability across different screen sizes and resolutions.
///
/// The theme uses the current Material 3 text styles:
/// - displayLarge, displayMedium, displaySmall: Used for largest text elements
/// - headlineLarge, headlineMedium, headlineSmall: Used for content headings
/// - titleLarge, titleMedium, titleSmall: Used for emphasized content titles
/// - bodyLarge, bodyMedium, bodySmall: Used for standard body text
/// - labelLarge, labelMedium, labelSmall: Used for UI labels and small text
///
/// Usage example with shadcn_flutter:
/// ```dart
/// // Used as a foundation for PaxTypography
/// PaxTypography typography = PaxTypography();
///
/// // Then used in ThemeData
/// ThemeData(
///   typography: typography,
///   // ...other theme properties
/// )
/// ```
///
/// The TextTheme provides the base styles that are mapped to the shadcn
/// Typography class in PaxTypography for use throughout the application.
final TextTheme paxTextTheme = GoogleFonts.dmSansTextTheme();

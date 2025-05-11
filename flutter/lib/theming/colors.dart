import 'package:flutter/material.dart' show Color;

/// Core color definitions for the Pax design system.
///
/// This class contains all the base colors used throughout the application,
/// organized by color type and usage. These colors serve as the foundation
/// for the PaxColorScheme, which applies these colors to specific UI contexts.
class PaxColors {
  // Private constructor to prevent instantiation
  PaxColors._();

  /// Primary Colors
  /// These colors form the main identity of the Pax brand

  /// Deep purple - primary brand color, used for main actions and important UI elements
  static const Color deepPurple = Color(0xFF363062);

  /// Accent orange - used for highlights, CTAs, and interactive elements
  static const Color orange = Color(0xFFFF9C4C);

  static const Color otherOrange = Color(0xFFFF5F00);

  /// Accent pink - used for secondary highlights and gradients
  static const Color pink = Color(0xFFFF5C86);

  static const Color specialPink = Color(0xFFEC89A7);

  /// Medium purple - used for secondary UI elements and active states
  static const Color mediumPurple = Color(0xFF625C89);

  /// Softer purple shade for backgrounds and non-interactive elements
  static const Color lilac = Color(0xFF9D99B4);

  /// Lightest purple shade for subtle backgrounds and disabled states
  static const Color lightLilac = Color(0xFFCFCED8);

  /// Blue accent - used for links and informational elements
  static const Color blue = Color(0xFF94B9FF);

  static const Color otherBlue = Color(0xFF94B9FF);

  static const Color green = Color(0xFF34A853);

  /// Neutral Colors
  /// Used for text, backgrounds, and borders

  /// Pure white - used for backgrounds in light mode and text in dark mode
  static const Color white = Color(0xFFFFFFFF);

  /// Pure black - used for text in light mode and backgrounds in dark mode
  static const Color black = Color(0xFF000000);

  /// Light grey - used for borders, dividers, and subtle UI elements
  static const Color lightGrey = Color(0xFFDDDDDD);

  /// Light grey - used for borders, dividers, and subtle UI elements
  static const Color darkGrey = Color(0xFF4C4C4C);

  /// Feedback Colors
  /// Used to communicate status and importance

  /// Error/destructive red - used for error states and destructive actions
  static const Color red = Color(0xFFFF0404);

  /// Semi-Transparent Colors
  /// Used for overlays, shadows, and subtle UI effects

  /// Red with 40% opacity - used for error backgrounds and subtle warnings
  static const Color redWithOpacity = Color(0x66FF0404); // 40% opacity

  /// White with 20% opacity - used for highlights on dark backgrounds
  static const Color whiteWithOpacity = Color(0x33FFFFFF); // 20% opacity

  /// Gradients
  /// Predefined color combinations for gradient effects

  /// Orange to pink gradient - used for emphasis and visual interest
  /// Commonly applied to promotional elements and featured content
  static const List<Color> orangeToPinkGradient = [orange, pink];
}

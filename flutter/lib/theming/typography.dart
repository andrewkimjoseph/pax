import 'package:flutter/material.dart' show Colors, FontStyle, FontWeight;
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:shadcn_flutter/shadcn_flutter.dart' show Typography;
import 'text_theme.dart';

/// A custom typography implementation for the Pax design system.
///
/// This class extends the shadcn Typography class to provide a consistent
/// typographic system throughout the application. It maps Flutter's TextTheme
/// to shadcn's Typography structure while maintaining the DM Sans font family.
///
/// The typography system includes:
/// - Size variants (xSmall through x9Large)
/// - Weight variants (thin through black)
/// - Semantic variants (h1-h4, p, blockQuote, etc.)
/// - Style variants (normal, italic)
///
/// Usage example:
/// ```dart
/// ThemeData(
///   typography: PaxTypography(),
///   // ...other theme properties
/// )
/// ```
class PaxTypography extends Typography {
  /// Creates a new PaxTypography instance with DM Sans font family.
  ///
  /// All text styles are derived from the paxTextTheme defined in text_theme.dart,
  /// ensuring consistency across the application.
  PaxTypography()
    : super(
        // Base font families
        sans: paxTextTheme.bodyMedium!.copyWith(fontFamily: 'DM Sans'),
        // Fix: Use appropriate monospace font instead of DM Sans for code
        mono: GoogleFonts.robotoMono(),

        // Size variants
        xSmall: paxTextTheme.labelSmall!,
        small: paxTextTheme.bodySmall!,
        base: paxTextTheme.bodyMedium!,
        large: paxTextTheme.bodyLarge!,
        xLarge: paxTextTheme.titleSmall!,
        x2Large: paxTextTheme.titleMedium!,
        x3Large: paxTextTheme.titleLarge!,
        x4Large: paxTextTheme.headlineSmall!,
        x5Large: paxTextTheme.headlineMedium!,
        x6Large: paxTextTheme.headlineLarge!,
        x7Large: paxTextTheme.displaySmall!,
        x8Large: paxTextTheme.displayMedium!,
        x9Large: paxTextTheme.displayLarge!,

        // Weight variants
        thin: paxTextTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w100),
        extraLight: paxTextTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.w200,
        ),
        light: paxTextTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w300),
        normal: paxTextTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w400),
        medium: paxTextTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
        semiBold: paxTextTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.w600,
        ),
        bold: paxTextTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w700),
        extraBold: paxTextTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.w800,
        ),
        black: paxTextTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w900),

        // Style variants
        italic: paxTextTheme.bodyMedium!.copyWith(fontStyle: FontStyle.italic),

        // Semantic variants (mapping to HTML elements)
        h1: paxTextTheme.displayLarge!,
        h2: paxTextTheme.displayMedium!,
        h3: paxTextTheme.displaySmall!,
        h4: paxTextTheme.headlineMedium!,
        p: paxTextTheme.bodyMedium!,
        blockQuote: paxTextTheme.bodyLarge!.copyWith(
          fontStyle: FontStyle.italic,
        ),
        // Fix: Use monospace font for code
        inlineCode: GoogleFonts.robotoMono(
          textStyle: paxTextTheme.bodyMedium!.copyWith(
            fontFamily: 'Roboto Mono',
          ),
        ),

        // Special variants
        lead: paxTextTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500),
        textLarge: paxTextTheme.bodyLarge!,
        textSmall: paxTextTheme.bodySmall!,
        // Fix: Use a theme-aware color instead of hardcoded grey
        textMuted: paxTextTheme.bodyMedium!.copyWith(
          color: Colors.grey.shade600,
        ),
      );
}

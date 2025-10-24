import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Utility class for responsive design and mobile-first approach
class ResponsiveUtil {
  // Breakpoints for different screen sizes
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;

  /// Check if the current screen is mobile-sized
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if the current screen is tablet-sized
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if the current screen is desktop-sized
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  /// Get responsive font size based on screen size
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    if (isMobile(context)) {
      return baseFontSize;
    } else if (isTablet(context)) {
      return baseFontSize * 1.1;
    } else {
      return baseFontSize * 1.2;
    }
  }

  /// Get responsive width constraint
  static double getMaxWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity; // Full width on mobile
    } else if (isTablet(context)) {
      return 600.0; // Constrained width on tablet
    } else {
      return 400.0; // Even more constrained on desktop
    }
  }

  /// Check if running on web and screen is too large for mobile app
  static bool shouldShowMobileOnlyMessage(BuildContext context) {
    return kIsWeb && !isMobile(context);
  }
}


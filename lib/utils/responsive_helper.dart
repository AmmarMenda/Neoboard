// lib/utils/responsive_helper.dart

import 'package:flutter/material.dart';

class ResponsiveHelper {
  static double getFontSize(BuildContext context, [double baseSize = 16]) {
    final width = MediaQuery.of(context).size.width;
    if (width < 350) return baseSize * 0.85;
    if (width < 450) return baseSize * 0.95;
    if (width < 600) return baseSize;
    if (width < 900) return baseSize * 1.05;
    return baseSize * 1.15;
  }

  static EdgeInsets get defaultPadding {
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  }

  static double getResponsiveSpacing(
    BuildContext context, [
    double baseSpacing = 8,
  ]) {
    final width = MediaQuery.of(context).size.width;
    if (width < 350) return baseSpacing * 0.5;
    if (width < 450) return baseSpacing * 0.75;
    if (width < 600) return baseSpacing;
    if (width < 900) return baseSpacing * 1.25;
    return baseSpacing * 1.5;
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 500;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 500 && width < 900;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  static EdgeInsets getResponsivePadding(
    BuildContext context, [
    double horizontal = 16,
    double vertical = 8,
  ]) {
    double width = MediaQuery.of(context).size.width;
    if (width < 350) {
      return EdgeInsets.symmetric(
        horizontal: horizontal * 0.5,
        vertical: vertical * 0.5,
      );
    } else if (width < 450) {
      return EdgeInsets.symmetric(
        horizontal: horizontal * 0.75,
        vertical: vertical * 0.75,
      );
    } else if (width < 900) {
      return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
    } else {
      return EdgeInsets.symmetric(
        horizontal: horizontal * 1.5,
        vertical: vertical * 1.25,
      );
    }
  }
}

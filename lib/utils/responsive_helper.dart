// utils/responsive_helper.dart
import 'package:flutter/material.dart';

class ResponsiveHelper {
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isSmallScreen(BuildContext context) {
    return getScreenWidth(context) < 600;
  }

  static bool isMediumScreen(BuildContext context) {
    return getScreenWidth(context) >= 600 && getScreenWidth(context) < 1200;
  }

  static bool isLargeScreen(BuildContext context) {
    return getScreenWidth(context) >= 1200;
  }

  // Responsive font sizes
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    double screenWidth = getScreenWidth(context);
    if (screenWidth < 360) return baseSize * 0.8;
    if (screenWidth < 600) return baseSize * 0.9;
    return baseSize;
  }

  // Responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isSmallScreen(context)) return const EdgeInsets.all(8);
    if (isMediumScreen(context)) return const EdgeInsets.all(12);
    return const EdgeInsets.all(16);
  }

  // Responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    if (isSmallScreen(context)) return baseSpacing * 0.75;
    return baseSpacing;
  }

  // Responsive grid count
  static int getGridCount(BuildContext context, double screenWidth) {
    if (screenWidth < 400) return 1;
    if (screenWidth < 600) return 2;
    if (screenWidth < 900) return 3;
    if (screenWidth < 1200) return 4;
    return 5;
  }
}

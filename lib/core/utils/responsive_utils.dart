import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static bool isWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint;

  /// Returns the appropriate cross axis count for grids based on screen width
  static int getCrossAxisCount(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  /// Returns a constrained width for content to prevent over-stretching on wide screens
  static double getPreferredContentWidth(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (isDesktop(context)) return 1200;
    if (isTablet(context)) return 800;
    return width;
  }
}

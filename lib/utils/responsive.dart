import 'package:flutter/material.dart';

class Responsive {
  static double width(BuildContext context) => MediaQuery.of(context).size.width;

  static bool isMobile(BuildContext context) => width(context) < 700;
  static bool isTablet(BuildContext context) =>
      width(context) >= 700 && width(context) < 1024;
  static bool isDesktop(BuildContext context) => width(context) >= 1024;

  static int gridColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 1;
  }

  static double cardWidth(BuildContext context) {
    if (isDesktop(context)) return 260;
    if (isTablet(context)) return 240;
    return 200;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    if (isDesktop(context)) return const EdgeInsets.symmetric(horizontal: 48, vertical: 12);
    if (isTablet(context)) return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    return const EdgeInsets.all(12);
  }
}
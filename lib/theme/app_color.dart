import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColor {
  // --- Light Mode ---
  static const Color primaryColor = Color(0xFF1d7946);
  static const Color secondaryColor = Color(0xFFf5b014);
  static const Color backgroundColor = Color(0xFFFBFBFB);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static Color textColor = Colors.grey.shade800;
  static const Color borderColor = Color(0xFFD8D8D8);

  // --- Dark Mode ---
  static const Color primaryColorDark = Color.fromARGB(
    255,
    0,
    96,
    48,
  ); // Lighter, vibrant green for dark mode visibility
  static const Color backgroundColorDark = Color(
    0xFF121212,
  ); // Deep modern dark
  static const Color surfaceColorDark = Color(
    0xFF1E1E1E,
  ); // Elevated dark surface
  static const Color textColorDark = Color(0xFFE5E5E5);
  static const Color borderColorDark = Color(0xFF333333);

  // --- Dynamic Theme Colors ---
  static Color get globalBorder =>
      Get.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;

  static Color get globalTextSecondary =>
      Get.isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800;
}

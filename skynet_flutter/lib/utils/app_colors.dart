import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryColor = Color(0xFF32DBC6); // Teal Green
  static const Color secondaryColor = Color(0xFF9253E9); // Purple

  // Accent Colors
  static const Color accentColor = Color(0xFFFF5677); // Pinkish Red
  static const Color highlightColor = Color(0xFF4CE8F5); // Aqua Blue

  // Text Colors
  static const Color primaryTextColor = Color(0xFF444444); // Dark Gray
  static const Color secondaryTextColor = Color(0xFF6C6C6C); // Medium Gray
  static const Color lightTextColor = Color(0xFFFFFFFF); // White

  // Background Colors
  static const Color backgroundColor = Color(0xFFF2F2F2); // Light Gray
  static const Color cardBackgroundColor = Color(0xFFFFFFFF); // White

  // Status Colors
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color warningColor = Color(0xFFFFC107); // Amber
  static const Color errorColor = Color(0xFFF44336); // Red

  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [secondaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

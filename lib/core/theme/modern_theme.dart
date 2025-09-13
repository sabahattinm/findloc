import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modern tema renkleri - Icon'daki gradient renklerine dayalı
class ModernTheme {
  // Ana gradient renkleri (icon'dan)
  static const Color primaryGreen = Color(0xFF00D4AA); // Icon'daki yeşil
  static const Color primaryTeal = Color(0xFF00B4D8); // Teal
  static const Color primaryBlue = Color(0xFF1E3A8A); // Icon'daki koyu mavi
  static const Color primaryBlueLight = Color(0xFF3B82F6); // Açık mavi
  static const Color primaryDarkBlue = Color(0xFF0F172A); // Koyu arka plan
  static const Color primaryDarkBlueLight = Color(0xFF1E293B); // Orta koyu

  // Gradient renkleri
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, primaryBlueLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      primaryDarkBlue,
      primaryDarkBlueLight,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Açık tema
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        primary: primaryBlue,
        secondary: primaryTeal,
        tertiary: primaryGreen,
        surface: Colors.white,
        background: const Color(0xFFF8FAFC),
        error: const Color(0xFFE53E3E),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: primaryDarkBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: primaryBlue.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: primaryBlue.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }

  // Koyu tema
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
        primary: primaryBlue,
        secondary: primaryTeal,
        tertiary: primaryGreen,
        surface: const Color(0xFF1A1A2E),
        background: primaryDarkBlue,
        error: const Color(0xFFE53E3E),
      ),
      scaffoldBackgroundColor: primaryDarkBlue,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 12,
        shadowColor: primaryGreen.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: const Color(0xFF16213E),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: primaryGreen.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }

  // Özel gradient container
  static Widget gradientContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? borderRadius,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  // Ana gradient buton
  static Widget gradientButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    double? width,
    double? height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Glow efekti
  static Widget glowContainer({
    required Widget child,
    Color? glowColor,
    double? blurRadius,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (glowColor ?? primaryGreen).withOpacity(0.3),
            blurRadius: blurRadius ?? 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}

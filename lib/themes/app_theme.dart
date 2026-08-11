import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // BELIEVE POS COLORS
  // ============================================================

  static const Color backgroundColor = Color(0xFF080D0F);
  static const Color cardColor = Color(0xFF11171A);
  static const Color cardBorderColor = Color(0xFF252D31);

  static const Color darkGreen = Color(0xFF005C3B);
  static const Color primaryGreen = Color(0xFF16A34A);
  static const Color lightGreen = Color(0xFF22C55E);

  static const Color textWhite = Color(0xFFF5F7F8);
  static const Color textGrey = Color(0xFF9CA6AD);

  // ============================================================
  // MAIN BELIEVE POS THEME
  // ============================================================

  static ThemeData light = ThemeData(
    brightness: Brightness.dark,

    useMaterial3: true,

    primaryColor: primaryGreen,

    scaffoldBackgroundColor: backgroundColor,

    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      secondary: lightGreen,
      surface: cardColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textWhite,
    ),

    // ==========================================================
    // APP BAR
    // ==========================================================

    appBarTheme: const AppBarTheme(
      backgroundColor: darkGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 23,
        fontWeight: FontWeight.bold,
      ),
    ),

    // ==========================================================
    // CARDS
    // ==========================================================

    cardTheme: CardTheme(
      color: cardColor,
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: cardBorderColor,
        ),
      ),
    ),

    // ==========================================================
    // TEXT
    // ==========================================================

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: textWhite,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: textWhite,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: textWhite,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: textWhite,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: textWhite,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: TextStyle(
        color: textWhite,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: textWhite,
      ),
      bodyMedium: TextStyle(
        color: textGrey,
      ),
      bodySmall: TextStyle(
        color: textGrey,
      ),
    ),

    // ==========================================================
    // INPUT FIELDS
    // ==========================================================

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      hintStyle: const TextStyle(
        color: textGrey,
      ),
      labelStyle: const TextStyle(
        color: textGrey,
      ),
      prefixIconColor: textGrey,
      suffixIconColor: textGrey,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: cardBorderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: cardBorderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: primaryGreen,
          width: 2,
        ),
      ),
    ),

    // ==========================================================
    // ELEVATED BUTTONS
    // ==========================================================

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFF20282C),
        disabledForegroundColor: const Color(0xFF667078),
        elevation: 2,
        minimumSize: const Size(
          double.infinity,
          52,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // ==========================================================
    // OUTLINED BUTTONS
    // ==========================================================

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightGreen,
        side: const BorderSide(
          color: primaryGreen,
        ),
        minimumSize: const Size(
          double.infinity,
          52,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    // ==========================================================
    // TEXT BUTTONS
    // ==========================================================

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: lightGreen,
      ),
    ),

    // ==========================================================
    // ICONS
    // ==========================================================

    iconTheme: const IconThemeData(
      color: textWhite,
    ),

    // ==========================================================
    // DIVIDERS
    // ==========================================================

    dividerTheme: const DividerThemeData(
      color: cardBorderColor,
      thickness: 1,
    ),

    // ==========================================================
    // SWITCHES
    // ==========================================================

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGreen;
          }

          return textGrey;
        },
      ),
      trackColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return darkGreen;
          }

          return const Color(0xFF30383D);
        },
      ),
    ),

    // ==========================================================
    // CHECKBOX
    // ==========================================================

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGreen;
          }

          return Colors.transparent;
        },
      ),
      checkColor: WidgetStateProperty.all(
        Colors.white,
      ),
    ),

    // ==========================================================
    // PROGRESS INDICATOR
    // ==========================================================

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryGreen,
    ),

    // ==========================================================
    // FLOATING ACTION BUTTON
    // ==========================================================

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
    ),

    // ==========================================================
    // SNACKBAR
    // ==========================================================

    snackBarTheme: SnackBarThemeData(
      backgroundColor: cardColor,
      contentTextStyle: const TextStyle(
        color: textWhite,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // ============================================================
  // DARK THEME
  //
  // We use the exact same Believe POS design.
  // ============================================================

  static ThemeData dark = light;
}

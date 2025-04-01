import 'package:flutter/material.dart';

// Create MaterialColor from a single Color
MaterialColor createMaterialColor(Color color) {
  List<double> strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
  Map<int, Color> swatch = <int, Color>{};
  // ignore: deprecated_member_use
  final int r = color.red, g = color.green, b = color.blue;

  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }

  // ignore: deprecated_member_use
  return MaterialColor(color.value, swatch);
}

class AppTheme {
  // Define your colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color orange = Color(0xFFB25800);
  static const Color green = Color(0xFF4B941E);
  static const Color lightOrange = Color(0xFFFFEFDF);
  static const Color grey = Color(0xFF666666);
  static const Color navy = Color(0xFF1C274C);
  static const Color red = Color(0xFFFF0004);

  // Create MaterialColor for primary swatch
  static final MaterialColor primarySwatch = createMaterialColor(orange);

  // Theme data
  static ThemeData themeData = ThemeData(
    primarySwatch: primarySwatch,
    fontFamily: 'Poppins',

    // AppBar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      foregroundColor: black,
      elevation: 0,
      iconTheme: IconThemeData(color: orange),
      actionsIconTheme: IconThemeData(color: orange),
    ),

    // Primary and accent colors
    primaryColor: orange,
    colorScheme: ColorScheme.light(
      primary: orange,
      secondary: orange,
      error: red,
      onPrimary: white,
      onSecondary: white,
      onError: white,
      // ignore: deprecated_member_use
      background: white,
      surface: white,
    ),

    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: orange,
        foregroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: orange,
        side: const BorderSide(color: orange),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: orange,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    ),

    // Card theme
    cardTheme: CardTheme(
      color: white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Text theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: orange, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: orange, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: orange, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: orange, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: orange),
      headlineSmall: TextStyle(color: orange),
      titleLarge: TextStyle(color: orange, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: orange),
      titleSmall: TextStyle(color: orange),
      bodyLarge: TextStyle(color: grey),
      bodyMedium: TextStyle(color: grey),
      bodySmall: TextStyle(color: grey),
      labelLarge: TextStyle(color: orange, fontWeight: FontWeight.bold),
      labelMedium: TextStyle(color: orange),
      labelSmall: TextStyle(color: grey),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: orange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: red, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: grey, width: 1),
      ),
      labelStyle: const TextStyle(color: grey),
      hintStyle: const TextStyle(color: grey),
    ),

    // Divider and icon themes
    dividerTheme: const DividerThemeData(
      color: grey,
      thickness: 1,
      space: 1,
    ),
    iconTheme: const IconThemeData(
      color: orange,
      size: 24,
    ),

    // Tab bar theme
    tabBarTheme: const TabBarTheme(
      labelColor: orange,
      unselectedLabelColor: grey,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(width: 2, color: orange),
      ),
    ),

    // Scaffold background color
    scaffoldBackgroundColor: white,
  );
}

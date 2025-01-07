import 'package:flutter/material.dart';

class ThemeColorPage {
  static const Color _lightColor = Color.fromRGBO(44, 0, 0, 0.173);
  static const Color _darkColor = Color.fromARGB(44, 255, 255, 255);

  static ThemeData lightTheme = themeData(lightColorScheme, _lightColor);
  static ThemeData darkTheme = themeData(darkColoScheme, _darkColor);

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      colorScheme: colorScheme,
      canvasColor: colorScheme.inversePrimary,
      scaffoldBackgroundColor: colorScheme.inversePrimary,
      highlightColor: Colors.transparent,
      focusColor: focusColor,
    );
  }

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF7A288A),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color.fromARGB(255, 4, 245, 188),
    onSecondary: Color(0xFF000000),
    surface: Color.fromARGB(255, 64, 185, 245),
    onSurface: Color(0xFF000000),
    error: Color.fromARGB(255, 255, 0, 47),
    onError: Color(0xFFFFFFFF),
  );

  static const ColorScheme darkColoScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF3B0B59),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF6c5ce7),
    onSecondary: Color(0xFF1A1D23),
    surface: Color(0xFF1A1D23),
    onSurface: Color(0xFFFFFFFF),
    error: Color.fromARGB(255, 212, 106, 132),
    onError: Color.fromARGB(255, 0, 0, 0),
  );
}

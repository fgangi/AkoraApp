// coverage:ignore-file
import 'package:flutter/cupertino.dart';

class AppTheme {
  static const Color brandBlue = Color(0xFF0D47A1);
  static const Color accentBlue = Color(0xFF1976D2); // A slightly lighter blue for accents/buttons

  static CupertinoThemeData get cupertinoTheme {
    // Define default text styles to be used by Cupertino widgets
    const CupertinoTextThemeData textTheme = CupertinoTextThemeData(
      primaryColor: brandBlue, // Default color for text that should be tinted with primary color
    );

    return CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: brandBlue,
      primaryContrastingColor: CupertinoColors.white, // Color for text/icons on primaryColor bg
      
      // Background color for the main content area of a CupertinoPageScaffold
      scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,

      // Background color for navigation bars and tab bars
      barBackgroundColor: CupertinoColors.systemGrey6,
      
      textTheme: textTheme,
    );
  }
}
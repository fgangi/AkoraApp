// coverage:ignore-file
import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart'; // Only if you need specific Material colors

class AppTheme {
  // Main brand color from your mockups (page 1 background)
  // Use a color picker to get the exact hex value from your mockup images.
  // This blue seems like a good candidate for primaryColor.
  static const Color brandBlue = Color(0xFF0D47A1); // Example: A deep blue, adjust to your mockup
  static const Color accentBlue = Color(0xFF1976D2); // A slightly lighter blue for accents/buttons

  // You can also define other common colors from Apple's HIG or your design:
  // static final Color systemBackground = CupertinoColors.systemBackground.resolveFrom(null);
  // static final Color secondarySystemBackground = CupertinoColors.secondarySystemBackground.resolveFrom(null);
  // static final Color systemGroupedBackground = CupertinoColors.systemGroupedBackground.resolveFrom(null);
  // static final Color labelColor = CupertinoColors.label.resolveFrom(null);
  // static final Color secondaryLabelColor = CupertinoColors.secondaryLabel.resolveFrom(null);


  static CupertinoThemeData get cupertinoTheme {
    // Define default text styles to be used by Cupertino widgets
    const CupertinoTextThemeData textTheme = CupertinoTextThemeData(
      primaryColor: brandBlue, // Default color for text that should be tinted with primary
      // Example: Customize specific text styles if needed
      // navLargeTitleTextStyle: TextStyle(
      //   fontFamily: 'SFProDisplay', // Example if you add custom fonts
      //   fontSize: 34.0,
      //   fontWeight: FontWeight.bold,
      //   color: CupertinoColors.label, // Default label color
      // ),
      // navTitleTextStyle: TextStyle(
      //   fontFamily: 'SFProText',
      //   fontSize: 17.0,
      //   fontWeight: FontWeight.w600,
      //   color: CupertinoColors.label,
      // ),
      // textStyle: TextStyle( // Default text style
      //   fontFamily: 'SFProText',
      //   fontSize: 17.0,
      //   color: CupertinoColors.label,
      // ),
      // Add more styles like actionTextStyle, tabLabelTextStyle etc.
    );

    return CupertinoThemeData(
      brightness: Brightness.light, // Or Brightness.dark for a dark theme
      primaryColor: brandBlue,
      primaryContrastingColor: CupertinoColors.white, // Color for text/icons on primaryColor bg
      
      // Background color for the main content area of a CupertinoPageScaffold
      scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground, // Common for settings-like screens
      // Or use a custom color:
      // scaffoldBackgroundColor: Color(0xFFF0F0F7), // A light grey often seen in iOS apps

      // Background color for navigation bars and tab bars
      barBackgroundColor: CupertinoColors.systemGrey6, // A very light, almost white, translucent grey
      
      textTheme: textTheme,
      
      // Example of how you might theme buttons directly, though often they pick up primaryColor
      // buttonTheme: CupertinoButtonThemeData(
      //   primaryColor: accentBlue,
      // ),
    );
  }
}
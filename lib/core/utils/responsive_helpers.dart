import 'package:flutter/widgets.dart';

// A simple helper to determine if the screen is large (like a tablet).
bool isTablet(BuildContext context) {
  // You can adjust the breakpoint as needed.
  // 600 is a common breakpoint for 7-inch tablets.
  return MediaQuery.of(context).size.width >= 600;
}
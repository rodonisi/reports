import 'package:flutter/material.dart';

abstract class DrawingConstants {
  // ---------------------------------------------------------------------------
  // - Padding constants
  // ---------------------------------------------------------------------------
  static const verySmallPadding = 4.0;
  static const smallPadding = 8.0;
  static const mediumPadding = 16.0;
  static const largePadding = 32.0;
  static const listViewPadding = const EdgeInsets.only(bottom: 75);

  // ---------------------------------------------------------------------------
  // - AppBar constants
  // ---------------------------------------------------------------------------
  static const twoRowAppBarHeight = 30.0;

  // ---------------------------------------------------------------------------
  // - Divider constants
  // ---------------------------------------------------------------------------
  static const dividerHeight = 0.0;
  static const dividerThickness = 1.0;

  // ---------------------------------------------------------------------------
  // - Sheets constants
  // ---------------------------------------------------------------------------
  static const safeSheetCloseTreshold = 0.4;

  // ---------------------------------------------------------------------------
  // - Adaptive Layout tresholds
  // ---------------------------------------------------------------------------
  static const mediumScreen = 500;
  static const largeScreen = 900;

  // ---------------------------------------------------------------------------
  // - Text Constants
  // ---------------------------------------------------------------------------
  static const boldTextStyle = const TextStyle(fontWeight: FontWeight.bold);
  static const secondaryTextStyle = const TextStyle(color: Colors.grey);
  static const titleTextStyle =
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0);

  // ---------------------------------------------------------------------------
  // - Animation Constants
  // ---------------------------------------------------------------------------
  static const animationDuration = Duration(milliseconds: 200);
}

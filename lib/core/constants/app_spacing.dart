import 'package:flutter/material.dart';

class AppSpacing {
  // --- Verticals ---
  static const gapH4 = SizedBox(height: 4);
  static const gapH8 = SizedBox(height: 8);
  static const gapH12 = SizedBox(height: 12);
  static const gapH16 = SizedBox(height: 16);
  static const gapH20 = SizedBox(height: 20);
  static const gapH24 = SizedBox(height: 24);
  static const gapH32 = SizedBox(height: 32);
  static const gapH40 = SizedBox(height: 40);
  static const gapH48 = SizedBox(height: 48);
  static const gapH64 = SizedBox(height: 64);

  // --- Horizontals ---
  static const gapW4 = SizedBox(width: 4);
  static const gapW8 = SizedBox(width: 8);
  static const gapW12 = SizedBox(width: 12);
  static const gapW16 = SizedBox(width: 16);
  static const gapW20 = SizedBox(width: 20);
  static const gapW24 = SizedBox(width: 24);
  static const gapW32 = SizedBox(width: 32);
  static const gapW40 = SizedBox(width: 40);
  static const gapW48 = SizedBox(width: 48);
  static const gapW64 = SizedBox(width: 64);

  // --- Padding Constants ---
  static const paddingAll8 = EdgeInsets.all(8);
  static const paddingAll16 = EdgeInsets.all(16);
  static const paddingAll24 = EdgeInsets.all(24);

  static const paddingH8 = EdgeInsets.symmetric(horizontal: 8);
  static const paddingH16 = EdgeInsets.symmetric(horizontal: 16);
  static const paddingH24 = EdgeInsets.symmetric(horizontal: 24);

  static const paddingV8 = EdgeInsets.symmetric(vertical: 8);
  static const paddingV16 = EdgeInsets.symmetric(vertical: 16);
  static const paddingV24 = EdgeInsets.symmetric(vertical: 24);

  static const paddingTop8 = EdgeInsets.only(top: 8);
  static const paddingBottom8 = EdgeInsets.only(bottom: 8);
  static const paddingLeft8 = EdgeInsets.only(left: 8);
  static const paddingRight8 = EdgeInsets.only(right: 8);

  // --- Complex Padding ---
  static const paddingH16V8 = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const paddingV16H8 = EdgeInsets.symmetric(horizontal: 8, vertical: 16);

  static const paddingH24V12 =
      EdgeInsets.symmetric(horizontal: 24, vertical: 12);
  static const paddingV24H12 =
      EdgeInsets.symmetric(horizontal: 12, vertical: 24);

  // Common mobile screen padding (e.g. Top Bar / Bottom Nav)
  static const paddingScreenH = EdgeInsets.symmetric(horizontal: 16);
  static const paddingScreenV = EdgeInsets.symmetric(vertical: 16);
  static const paddingScreen =
      EdgeInsets.symmetric(horizontal: 16, vertical: 16);
}

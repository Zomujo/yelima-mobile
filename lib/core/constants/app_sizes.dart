import 'package:flutter/material.dart';

class AppSizes {
  // --- Radius ---
  static const r4 = Radius.circular(4);
  static const r8 = Radius.circular(8);
  static const r12 = Radius.circular(12);
  static const r16 = Radius.circular(16);
  static const r24 = Radius.circular(24);

  static final borderRadius4 = BorderRadius.circular(4);
  static final borderRadius8 = BorderRadius.circular(8);
  static final borderRadius12 = BorderRadius.circular(12);
  static final borderRadius16 = BorderRadius.circular(16);
  static final borderRadius24 = BorderRadius.circular(24);

  // --- Layout Clearances ---
  static double bottomNavClearance(BuildContext context) {
    // 24 (margin) + 52 (nav bar height) + 24 (extra breathing room) + safe area bottom
    return 100.0 + MediaQuery.paddingOf(context).bottom;
  }
}

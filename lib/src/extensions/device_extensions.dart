import 'dart:math' as math;

import 'package:flutter/material.dart';

extension DeviceTypeExtension on BuildContext {
  /// Screen width threshold for mobile vs tablet/foldable
  double get _width => MediaQuery.of(this).size.width;

  bool get isMobile => _width < 600;

  bool get isFoldable => _width >= 600 && _width < 900;

  bool get isTabletOrDesktop => _width >= 900;

  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;
}


extension ContextExtensions on BuildContext {
  double get screenHeight => MediaQuery.of(this).size.height;
  double get screenWidth => MediaQuery.of(this).size.width;

  // Optionally:
  double get topPadding => MediaQuery.of(this).padding.top;
  double get bottomPadding => MediaQuery.of(this).padding.bottom;
}

extension ScaledSizeExtension on BuildContext {
  /// Scales [size] with the screen's shortest side, capped at 450dp so large
  /// screens don't blow it up. Same formula as the host app's responsive
  /// helper; replaces sizer's `.sp`, which needs a `Sizer` widget above it.
  double sp(num size) =>
      size * math.min(MediaQuery.sizeOf(this).shortestSide, 450) / 300;
}

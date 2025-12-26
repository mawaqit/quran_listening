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

import 'package:flutter/material.dart';

import '../../extensions/theme_extension.dart';

/// Compact tappable chip that shows the current playback speed.
///
/// Displays the speed as a formatted label (e.g. `1×`, `0.75×`) inside
/// a pill-shaped container. Tap to cycle to the next speed.
class SpeedChip extends StatelessWidget {
  final double speed;
  final VoidCallback onTap;

  const SpeedChip({required this.speed, required this.onTap, super.key});

  String _label(double s) {
    // Format: hide trailing .0 for clean display (e.g. 1× not 1.0×)
    final formatted =
        s == s.truncateToDouble() ? s.toInt().toString() : s.toString();
    return '$formatted×';
  }

  @override
  Widget build(BuildContext context) {
    final isNormal = speed == 1.0;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: context.colorScheme.primaryFixed.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.colorScheme.primaryFixed,
            width: 1,
          ),
        ),
        child: Text(
          _label(speed),
          style: TextStyle(
            fontSize: 11,
            fontWeight: isNormal ? FontWeight.normal : FontWeight.bold,
            color: context.colorScheme.primaryFixed,
          ),
        ),
      ),
    );
  }
}

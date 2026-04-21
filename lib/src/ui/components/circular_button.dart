import 'package:flutter/material.dart';
import 'package:mawaqit_quran_listening/mawaqit_quran_listening.dart';

class CircularButton extends StatelessWidget {
  final IconData icon;

  final VoidCallback onTap;
  final Color color;
  final Color? iconColor;
  final double size;
  final double? iconSize;
  final Widget? svgIcon;
  final Color? borderColor;
  final String? label;

  const CircularButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 48,
    this.iconSize,
    this.color = Colors.transparent,
    this.iconColor = Colors.grey,
    this.svgIcon,
    this.borderColor,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: borderColor ?? Colors.grey, width: 1),
        ),
        child: svgIcon ?? Icon(icon, color: iconColor, size: iconSize),
      ),
    ).semanticAction(context: context, label: label ?? "",);
  }
}

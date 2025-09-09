import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgImageAsset extends StatelessWidget {
  const SvgImageAsset(this.assetName, {super.key, this.color, this.height, this.width, this.fit = BoxFit.contain});

  final String assetName;
  final Color? color;
  final double? height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetName,
      colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
      height: height,
      width: width,
      fit: fit,
    );
  }
}

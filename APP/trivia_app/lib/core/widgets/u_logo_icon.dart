import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ULogoIcon extends StatelessWidget {
  final double size;

  const ULogoIcon({super.key, this.size = 28.0});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logotipos/elemento_u_logo.svg',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

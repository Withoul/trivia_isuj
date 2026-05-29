import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MonedaIcon extends StatelessWidget {
  final double size;

  const MonedaIcon({super.key, this.size = 28.0});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logotipos/icon_puntos.svg',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InstitutionLogo extends StatelessWidget {
  final double height;

  const InstitutionLogo({super.key, this.height = 100.0});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logotipos/logo_institucion.svg',
      height: height,
      fit: BoxFit.contain,
    );
  }
}

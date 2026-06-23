import 'package:flutter/material.dart';
import 'package:clune/constants/app_assets.dart';

/// Logo de Clune reutilizable en onboarding y pantallas de marca.
class CluneLogo extends StatelessWidget {
  final double size;
  final BorderRadius? borderRadius;

  const CluneLogo({
    super.key,
    this.size = 120,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      AppAssets.logo,
      width: size,
      height: size,
      fit: BoxFit.cover,
    );

    if (borderRadius == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: image,
      );
    }

    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}

import 'package:flutter/material.dart';
import '../core/theme.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  const LogoWidget({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(size * 0.25),
          ),
          child: Icon(
            Icons.sports_tennis_rounded,
            color: AppTheme.primary,
            size: size * 0.55,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'CLUB DE PÁDEL',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: AppTheme.textMedium,
          ),
        ),
        const Text(
          'MUDÉJAR',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
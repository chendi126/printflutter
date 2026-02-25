import 'package:flutter/cupertino.dart';

class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final baseGradient = isDark
        ? const [Color(0xFF12151B), Color(0xFF0D0F14)]
        : const [Color(0xFFE8F1FF), Color(0xFFF5FAFF)];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: baseGradient,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -60,
            child: _blob(
                (isDark ? const Color(0xFF3B5DB7) : const Color(0xFF73A6FF))
                    .withValues(alpha: isDark ? 0.24 : 0.20),
                240),
          ),
          Positioned(
            bottom: -60,
            right: -40,
            child: _blob(
                (isDark ? const Color(0xFF00B3A6) : const Color(0xFF00D1C1))
                    .withValues(alpha: isDark ? 0.22 : 0.18),
                200),
          ),
          Positioned(
            top: 220,
            right: -100,
            child: _blob(
                (isDark ? const Color(0xFFE86CA2) : const Color(0xFFFF7EB3))
                    .withValues(alpha: isDark ? 0.18 : 0.12),
                260),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

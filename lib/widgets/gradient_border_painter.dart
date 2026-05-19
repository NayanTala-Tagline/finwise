import 'package:flutter/material.dart';

/// Custom Painter for Gradient Border
class GradientBorderPainter extends CustomPainter {
  final double strokeWidth;
  final double borderRadius;
  final Gradient gradient;

  GradientBorderPainter({
    required this.strokeWidth,
    required this.borderRadius,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(GradientBorderPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.gradient != gradient;
  }
}

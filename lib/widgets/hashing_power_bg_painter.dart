import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Custom Painter for Hashing Power Background Container
class HashingPowerBgPainter extends CustomPainter {
  final double borderRadius;

  HashingPowerBgPainter({
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    // Dark background with gradient
    final backgroundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF000000), // Dark blue-black at top
        Color(0xFF000000), // Slightly lighter in middle

      ],
      stops: [0.5, 1,],
    );

    final backgroundPaint = Paint()
      ..shader = backgroundGradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rrect, backgroundPaint);

    // Golden glow at the bottom with blur effect
    final glowRect = Rect.fromLTWH(0, size.height * 0.9, size.width, size.height * 0.15);
    
    // Create a gradient that's brightest in center and fades to edges
    final glowGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xff003626),                  // Darkest at left edge
        Color(0xFFF2D024).withOpacity(0.8), // Medium
        Color(0xFFF2D024).withOpacity(1), // Brightest in middle
        Color(0xFFF2D024).withOpacity(0.8), // Medium
        Color(0xff003626),                  // Darkest at right edge
      ],
      stops: [0.0, 0.30, 0.5, 0.7, 1.0],
    );

    final glowPaint = Paint()
      ..shader = glowGradient.createShader(glowRect)
      ..style = PaintingStyle.fill
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 20); // Add blur effect

    // Clip to rounded rectangle before drawing glow
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawRect(glowRect, glowPaint);
    canvas.restore();

    // Subtle border with golden tint at bottom
    final borderGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0.1),
        Color(0xFFF2D024).withOpacity(0.7),
      ],
      stops: [0.0, 1.0],
    );

    final borderPaint = Paint()
      ..shader = borderGradient.createShader(rect)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(HashingPowerBgPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius;
  }
}

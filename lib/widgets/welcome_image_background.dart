import 'package:flutter/material.dart';

  class WelcomeImageBackground extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.saveLayer(Rect.fromLTWH(0, 0, w, h), Paint());

    // =========================
    // 🎨 GRADIENTS (IMPORTANT)
    // =========================

    final bottomPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
         Colors.transparent.withOpacity(0.07),
          Color(0xFF158EFF).withOpacity(0.1),
        ]
        ,stops: [0,0.85],

      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final middlePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent.withOpacity(0.02),
          Color(0xFF158EFF).withOpacity(0.15),
        ]
        ,stops: [0,0.85],

      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final topPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent.withOpacity(0.02),
          Color(0xFF158EFF).withOpacity(0.2),
        ]
        ,stops: [0,0.85],

      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // =========================
    // 🔻 SHAPES (ALIGNED)
    // =========================

    Path bottom = Path()
      ..moveTo(0, h * 0.30)
      ..lineTo(0, h * 0.75)
      ..lineTo(w * 0.5, h)
      ..lineTo(w, h * 0.75)
      ..lineTo(w, h * 0.30)
      ..close();

    Path middle = Path()
      ..moveTo(w * 0.08, h * 0.32)
      ..lineTo(w * 0.08, h * 0.70)
      ..lineTo(w * 0.5, h * 0.91)
      ..lineTo(w * 0.92, h * 0.70)
      ..lineTo(w * 0.92, h * 0.32)
      ..close();

    Path top = Path()
      ..moveTo(w * 0.22, h * 0.40)
      ..lineTo(w * 0.22, h * 0.68)
      ..lineTo(w * 0.5, h * 0.82)
      ..lineTo(w * 0.78, h * 0.68)
      ..lineTo(w * 0.78, h * 0.40)
      ..close();

    // =========================
    // 🖌 DRAW
    // =========================

    canvas.drawPath(bottom, bottomPaint);
    canvas.drawPath(middle, middlePaint);
    canvas.drawPath(top, topPaint);

    // =========================
    // 🔥 TOP FADE (GRADIENT MASK)
    // =========================

    final fadePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent, // 👈 fade top
          Colors.black,
          Colors.black,
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..blendMode = BlendMode.dstIn;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), fadePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
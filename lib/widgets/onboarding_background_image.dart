import 'package:flutter/material.dart';

class NeonTopShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // =========================
    // 🔷 SHAPE PATH
    // =========================




    final path = Path()
      ..moveTo(w * 0.02, h * 0.65)
      ..lineTo(w * 0.10, h * 0.30)
      ..lineTo(w * 0.50, h * 0.12)
      ..lineTo(w * 0.90, h * 0.30)
      ..lineTo(w * 0.98, h * 0.66);


    // =========================
    // 🎨 FILL (LINEAR GRADIENT)
    // =========================

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF091D41),
          Color(0xFF050E20)..withOpacity(0.1),
          Colors.transparent.withOpacity(0.008),
        ],
        stops: [0,0.31,1]
      ).createShader(Rect.fromLTWH(0, 0, w, h));



    final strokePaint = Paint()
      ..shader = RadialGradient(
        radius: 2,
        center: Alignment.center,
        colors: [
          Color(0xFF158EFF).withValues(alpha: 0.6),
          Colors.transparent.withValues(alpha: 0),
        ],
        stops: [0,1]
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, fillPaint);       // fill
     canvas.drawPath(path, strokePaint);     // main


    final topSmallPath = Path()
      ..moveTo(w * 0.26, h * 0.20)   // higher
      ..lineTo(w * 0.50, h * 0.095)   // peak ABOVE big shape
      ..lineTo(w * 0.74, h * 0.20);

    final topSmallPaint = Paint()
      ..shader = RadialGradient(
          radius: 2,
          center: Alignment.topCenter,
          colors: [
            Color(0xFF158EFF).withOpacity(0.6),
            Colors.transparent.withOpacity(0),
          ],
          stops: [0,1]
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;


    canvas.drawPath(topSmallPath, topSmallPaint);


   }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
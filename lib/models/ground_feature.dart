import 'dart:math' as math;
import 'package:flutter/material.dart';

class GroundFeature {
  double x;
  double groundY;
  String featureType; // 'gap' or 'bump'
  double width;
  double height;

  GroundFeature({
    required this.x,
    required this.groundY,
    this.featureType = 'gap',
  })  : width = 0,
        height = 0 {
    final rnd = math.Random();
    if (featureType == 'gap') {
      width = 60 + rnd.nextDouble() * 40;
      height = 200;
    } else {
      width = 40 + rnd.nextDouble() * 30;
      height = 15 + rnd.nextDouble() * 10;
    }
  }

  void update(double gameSpeed) {
    x -= gameSpeed;
  }

  bool isOffscreen() => x + width < 0;

  Rect getRect() {
    if (featureType == 'gap') {
      return Rect.fromLTWH(x, groundY, width, height);
    }
    return Rect.fromLTWH(x, groundY - height, width, height);
  }

  void draw(Canvas canvas, bool isNight, Color bgColor) {
    if (featureType == 'gap') {
      // ✅ Fill with background color (hole)
      final bgPaint = Paint()..color = bgColor;
      canvas.drawRect(
        Rect.fromLTWH(x, groundY, width, height),
        bgPaint,
      );

      // ✅ Shadow on edges
      final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.4);
      canvas.drawRect(Rect.fromLTWH(x - 3, groundY, 3, height), shadowPaint);
      canvas.drawRect(
          Rect.fromLTWH(x + width, groundY, 3, height), shadowPaint);

      // ✅ Edge lines
      final linePaint = Paint()
        ..color = const Color(0xFF505050)
        ..strokeWidth = 2;
      canvas.drawLine(
          Offset(x, groundY), Offset(x, groundY + 20), linePaint);
      canvas.drawLine(
          Offset(x + width, groundY), Offset(x + width, groundY + 20),
          linePaint);
    } else if (featureType == 'bump') {
      // ✅ Bump like a small hill
      final color = isNight ? const Color(0xFF646464) : const Color(0xFF535353);
      final paint = Paint()..color = color;

      final path = Path()
        ..moveTo(x, groundY)
        ..lineTo(x + width / 2, groundY - height)
        ..lineTo(x + width, groundY)
        ..close();

      canvas.drawPath(path, paint);

      // ✅ Border
      final borderPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(path, borderPaint);
    }
  }
}
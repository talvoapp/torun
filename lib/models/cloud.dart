import 'dart:math' as math;
import 'package:flutter/material.dart';

class Cloud {
  double x;
  double y;
  double size;
  double speed;
  int alpha;

  Cloud({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  }) : alpha = 80 + math.Random().nextInt(100);

  void update(double gameSpeed) {
    x -= (gameSpeed * 0.3) + speed;
  }

  bool isOffscreen() => x + size < 0;

  void draw(Canvas canvas) {
    final paint = Paint()..color = Colors.white.withValues(alpha: alpha / 255);

    // ✅ 3 circles to form a cloud
    canvas.drawCircle(Offset(x + size * 0.5, y + size * 0.5), size / 2, paint);
    canvas.drawCircle(
        Offset(x + size * 0.9, y + size * 0.2), size * 0.4, paint);
    canvas.drawCircle(
        Offset(x + size * 1.3, y + size * 0.5), size * 0.35, paint);
  }
}

class Star {
  double x;
  double y;
  double size;
  double twinklePhase;

  Star({required this.x, required this.y, required this.size})
      : twinklePhase = math.Random().nextDouble() * 6.28;

  void update(double gameSpeed) {
    x -= gameSpeed * 0.1;
    twinklePhase += 0.1;
  }

  bool isOffscreen() => x < 0;

  void draw(Canvas canvas) {
    final alpha = (100 + 100 * math.sin(twinklePhase)).clamp(50, 255).toInt();
    final paint = Paint()..color = Colors.white.withValues(alpha: alpha / 255);
    canvas.drawCircle(Offset(x, y), size / 2, paint);
  }
}
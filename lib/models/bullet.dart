import 'dart:ui';
import 'package:flutter/material.dart';

class Bullet {
  double x;
  double y;
  double vx;
  double vy;
  int damage;
  Color color;
  double size;
  int lifetime = 80;
  bool explosion = false;

  Bullet({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    this.damage = 1,
    this.color = const Color(0xFFFFFF00),
    this.size = 8,
    this.explosion = false,
  });

  void update() {
    x += vx;
    y += vy;
    lifetime--;
  }

  bool get isDead => lifetime <= 0 || x > 2000 || x < -100;

  Rect getRect() =>
      Rect.fromLTWH(x - size / 2, y - size / 2, size, size);

  void draw(Canvas canvas) {
    // ✅ Glow
    for (int i = 0; i < 3; i++) {
      final glowColor = color.withValues(alpha: (100 - i * 30) / 255);
      final glowPaint = Paint()..color = glowColor;
      canvas.drawCircle(
        Offset(x, y),
        (size / 2) + i * 2,
        glowPaint,
      );
    }

    // ✅ Bullet body
    final bodyPaint = Paint()..color = color;
    canvas.drawCircle(Offset(x, y), size / 2, bodyPaint);

    // ✅ Tail
    final tailColor = color.withValues(alpha: 150 / 255);
    final tailPaint = Paint()..color = tailColor;
    canvas.drawRect(
      Rect.fromLTWH(
        x - vx * 2,
        y - size / 4,
        vx * 2,
        size / 2,
      ),
      tailPaint,
    );
  }
}
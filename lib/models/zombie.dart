import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class Zombie {
  static const Map<String, Map<String, dynamic>> types = {
    'walker': {
      'name': 'ماشي',
      'health': 2,
      'speed': 1.5,
      'color': '#4a7c4a',
      'damage': 1,
    },
    'runner': {
      'name': 'جري',
      'health': 1,
      'speed': 3.0,
      'color': '#7c4a4a',
      'damage': 1,
    },
    'shooter': {
      'name': 'رامي',
      'health': 3,
      'speed': 0.8,
      'color': '#4a4a7c',
      'damage': 1,
    },
    'tank': {
      'name': 'مدرع',
      'health': 6,
      'speed': 0.5,
      'color': '#666666',
      'damage': 2,
    },
  };

  double x;
  double y;
  final double groundY;
  String type;
  Map<String, dynamic> data;
  double width = 40;
  double height = 50;
  int health;
  int maxHealth;
  double walkPhase = 0;

  Zombie({required this.x, required this.groundY, this.type = 'walker'})
      : y = groundY - 50,
        data = types[type] ?? types['walker']!,
        health = (types[type] ?? types['walker']!)['health'] as int,
        maxHealth = (types[type] ?? types['walker']!)['health'] as int;

  void update(double gameSpeed) {
    x -= (data['speed'] as double);
    walkPhase += 0.2;
  }

  bool isOffscreen() => x + width < 0;

  Rect getRect() => Rect.fromLTWH(x + 5, y + 5, width - 10, height - 10);

  bool takeDamage(int damage) {
    health -= damage;
    return health <= 0;
  }

  void draw(Canvas canvas, bool isNight) {
    final walkOffset = 3 * math.sin(walkPhase);
    final centerX = x + width / 2;
    final centerY = y + height / 2 + walkOffset;

    final hexColor = (data['color'] as String).replaceFirst('#', '');
    final color = Color(int.parse('FF$hexColor', radix: 16));

    // ✅ Body
    final bodyRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: width,
      height: height,
    );
    canvas.drawOval(bodyRect, Paint()..color = color);

    // ✅ Border
    canvas.drawOval(
      bodyRect,
      Paint()
        ..color = color.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // ✅ Eyes
    final eyePaint = Paint()..color = const Color(0xFFFF0000);
    canvas.drawCircle(Offset(centerX - 8, centerY - 5), 4, eyePaint);
    canvas.drawCircle(Offset(centerX + 8, centerY - 5), 4, eyePaint);

    // ✅ Health bar
    if (health < maxHealth) {
      final ratio = health / maxHealth;
      canvas.drawRect(
        Rect.fromLTWH(x, y - 10, width, 4),
        Paint()..color = const Color(0xFFFF0000),
      );
      canvas.drawRect(
        Rect.fromLTWH(x, y - 10, width * ratio, 4),
        Paint()..color = const Color(0xFF00FF00),
      );
    }
  }
}
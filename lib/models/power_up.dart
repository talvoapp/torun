import 'dart:math' as math;
import 'package:flutter/material.dart';

class PowerUp {
  static const Map<String, Map<String, dynamic>> types = {
    'speed': {
      'name': 'سرعة',
      'color': '#ffff00',
      'duration': 300,
      'icon': 'flash_on',
    },
    'shield': {
      'name': 'درع',
      'color': '#00ffff',
      'duration': 400,
      'icon': 'shield',
    },
    'coin_magnet': {
      'name': 'مغناطيس',
      'color': '#ffcc00',
      'duration': 500,
      'icon': 'money',
    },
    'double_coins': {
      'name': 'عملات مضاعفة',
      'color': '#ff00ff',
      'duration': 400,
      'icon': 'star',
    },
    'slow_motion': {
      'name': 'بطء الوقت',
      'color': '#88ff88',
      'duration': 300,
      'icon': 'hourglass_bottom',
    },
  };

  double x;
  double y;
  String type;
  Map<String, dynamic> data;
  double size = 35;
  double floatPhase = 0;
  bool collected = false;

  PowerUp({required this.x, required this.y, required this.type})
      : data = types[type] ?? types['speed']!;

  void update(double gameSpeed) {
    x -= gameSpeed;
    floatPhase += 0.15;
  }

  bool isOffscreen() => x + size < 0;

  Rect getRect() => Rect.fromLTWH(x, y, size, size);

  static Color _parseHexColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  // ✅ تحويل اسم الأيقونة لـ IconData
  static IconData _getIconData(String name) {
    switch (name) {
      case 'flash_on':
        return Icons.flash_on;
      case 'shield':
        return Icons.shield;
      case 'money':
        return Icons.monetization_on;
      case 'star':
        return Icons.star;
      case 'hourglass_bottom':
        return Icons.hourglass_bottom;
      default:
        return Icons.circle;
    }
  }

  void draw(Canvas canvas) {
    final floatOffset = math.sin(floatPhase) * 5;
    final centerX = x + size / 2;
    final centerY = y + size / 2 + floatOffset;
    final color = _parseHexColor(data['color'] as String);

    // ✅ Glow
    for (int i = 4; i >= 1; i--) {
      final glowPaint = Paint()..color = color.withValues(alpha: 50 / 255);
      canvas.drawCircle(
        Offset(centerX, centerY),
        size / 2 + i * 3,
        glowPaint,
      );
    }

    // ✅ Main circle
    final circlePaint = Paint()..color = color;
    canvas.drawCircle(Offset(centerX, centerY), size / 2, circlePaint);

    // ✅ Border
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(centerX, centerY), size / 2, borderPaint);

    // ✅ الأيقونة (Material Icon بدل الإيموجي)
    final iconData = _getIconData(data['icon'] as String);
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontSize: size * 0.55,
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
          color: Colors.black87,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        centerX - iconPainter.width / 2,
        centerY - iconPainter.height / 2,
      ),
    );
  }
}
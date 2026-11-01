import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'obstacle_sprite_cache.dart';

class Obstacle {
  double x;
  double y = 0;
  final double groundY;
  final String obstacleStyle;
  final int scoreValue;
  String type;
  double width = 0;
  double height = 0;
  int health = 1;
  int maxHealth = 1;

  double flapPhase = 0;
  double hoverPhase = 0;
  double rotation = 0;
  double rotationSpeed = 0;

  Obstacle({
    required this.x,
    required this.groundY,
    this.scoreValue = 0,
    this.obstacleStyle = 'cactus',
  }) : type = _selectType(scoreValue, obstacleStyle) {
    // ✅ صحة الأعداء حسب النوع
    if (obstacleStyle == 'platformer') {
      switch (type) {
        case 'slime':
          health = 1;
          break;
        case 'fly':
          health = 1;
          break;
        case 'snail':
          health = 2;
          break;
        case 'fish':
          health = 1;
          break;
        case 'poker':
          health = 3;
          break;
        case 'blocker':
          health = 2;
          break;
        default:
          health = 1;
      }
    } else if (obstacleStyle == 'nature') {
      switch (type) {
        case 'bee':
          health = 1;
          break;
        case 'bluefish':
          health = 1;
          break;
        case 'frog':
          health = 2;
          break;
        case 'ladybug':
          health = 1;
          break;
        case 'mouse':
          health = 2;
          break;
        case 'saw':
          health = 3;
          break;
        case 'blockslime':
          health = 2;
          break;
        case 'cactus_new':
          health = 2;
          break;
        case 'cactus_new_large':
          health = 3;
          break;
        default:
          health = 1;
      }
    } else if (type.contains('small')) {
      health = 1;
    } else if (type.contains('medium')) {
      health = 2;
    } else if (type.contains('large')) {
      health = 3;
    } else {
      health = 1;
    }
    maxHealth = health;
    _setupType();
    rotationSpeed = math.Random().nextDouble() * 4 - 2;
  }

  static String _selectType(int score, String style) {
    Map<String, int> weights;

    // ✅ Nature style (جديد)
    if (style == 'nature') {
      if (score < 15) {
        weights = {
          'ladybug': 40,
          'mouse': 30,
          'frog': 30,
        };
      } else if (score < 35) {
        weights = {
          'ladybug': 25,
          'mouse': 20,
          'frog': 20,
          'bee': 20,
          'cactus_new': 15,
        };
      } else {
        weights = {
          'ladybug': 15,
          'mouse': 15,
          'frog': 15,
          'bee': 15,
          'bluefish': 15,
          'saw': 10,
          'blockslime': 10,
          'cactus_new_large': 5,
        };
      }
    }
    // ✅ Platformer style (موجود)
    else if (style == 'platformer') {
      if (score < 15) {
        weights = {
          'slime': 50,
          'snail': 50,
        };
      } else if (score < 30) {
        weights = {
          'slime': 30,
          'snail': 25,
          'fly': 25,
          'poker': 20,
        };
      } else {
        weights = {
          'slime': 20,
          'snail': 15,
          'fly': 20,
          'fish': 20,
          'poker': 15,
          'blocker': 10,
        };
      }
    }
    // ✅ الأنماط القديمة
    else if (style == 'cactus') {
      if (score < 10) {
        weights = {'cactus_small': 60, 'cactus_large': 40};
      } else if (score < 25) {
        weights = {
          'cactus_small': 40,
          'cactus_large': 30,
          'pterodactyl': 30
        };
      } else if (score < 50) {
        weights = {
          'cactus_small': 25,
          'cactus_large': 25,
          'cactus_double': 20,
          'pterodactyl': 30
        };
      } else {
        weights = {
          'cactus_small': 20,
          'cactus_large': 20,
          'cactus_double': 20,
          'pterodactyl': 40
        };
      }
    } else if (style == 'rocks') {
      weights = {'rock_small': 40, 'rock_medium': 35, 'rock_large': 25};
    } else if (style == 'cars') {
      weights = {'car_small': 60, 'car_large': 40};
    } else if (style == 'drones') {
      weights = {'drone_small': 60, 'drone_large': 40};
    } else {
      weights = {'cactus_small': 100};
    }

    final total = weights.values.reduce((a, b) => a + b);
    var r = math.Random().nextInt(total);
    for (final entry in weights.entries) {
      r -= entry.value;
      if (r < 0) return entry.key;
    }
    return weights.keys.first;
  }

  void _setupType() {
    final rnd = math.Random();

    // =============================================
    // ✅ Nature enemies (جديد)
    // =============================================
    if (type == 'bee') {
      width = 32;
      height = 32;
      y = groundY - [80.0, 110.0, 140.0][rnd.nextInt(3)];
      return;
    } else if (type == 'bluefish') {
      width = 32;
      height = 24;
      y = groundY - [90.0, 120.0, 150.0][rnd.nextInt(3)];
      return;
    } else if (type == 'frog') {
      width = 32;
      height = 32;
      y = groundY - height;
      return;
    } else if (type == 'ladybug') {
      width = 32;
      height = 24;
      y = groundY - height;
      return;
    } else if (type == 'mouse') {
      width = 32;
      height = 24;
      y = groundY - height;
      return;
    } else if (type == 'saw') {
      width = 40;
      height = 40;
      y = groundY - height;
      return;
    } else if (type == 'blockslime') {
      width = 32;
      height = 32;
      y = groundY - height;
      return;
    } else if (type == 'cactus_new') {
      width = 32;
      height = 48;
      y = groundY - height;
      return;
    } else if (type == 'cactus_new_large') {
      width = 64;
      height = 96;
      y = groundY - height;
      return;
    }

    // =============================================
    // ✅ Platformer enemies (موجود)
    // =============================================
    if (type == 'slime') {
      width = 32;
      height = 24;
      y = groundY - height;
      return;
    } else if (type == 'snail') {
      width = 32;
      height = 24;
      y = groundY - height;
      return;
    } else if (type == 'poker') {
      width = 40;
      height = 40;
      y = groundY - height;
      return;
    } else if (type == 'blocker') {
      width = 40;
      height = 48;
      y = groundY - height;
      return;
    } else if (type == 'fly') {
      width = 32;
      height = 24;
      y = groundY - [80.0, 110.0, 140.0][rnd.nextInt(3)];
      return;
    } else if (type == 'fish') {
      width = 32;
      height = 24;
      y = groundY - [90.0, 120.0, 150.0][rnd.nextInt(3)];
      return;
    }

    // =============================================
    // ✅ الأنماط القديمة
    // =============================================
    switch (type) {
      case 'cactus_small':
        width = 20;
        height = 40;
        y = groundY - height;
        break;
      case 'cactus_large':
        width = 30;
        height = 60;
        y = groundY - height;
        break;
      case 'cactus_double':
        width = 50;
        height = 50;
        y = groundY - height;
        break;
      case 'pterodactyl':
        width = 45;
        height = 35;
        y = groundY - [70.0, 110.0, 150.0][rnd.nextInt(3)];
        break;
      case 'rock_small':
        width = 30;
        height = 30;
        y = groundY - height;
        break;
      case 'rock_medium':
        width = 45;
        height = 40;
        y = groundY - height;
        break;
      case 'rock_large':
        width = 60;
        height = 55;
        y = groundY - height;
        break;
      case 'car_small':
        width = 70;
        height = 35;
        y = groundY - height;
        break;
      case 'car_large':
        width = 90;
        height = 45;
        y = groundY - height;
        break;
      case 'drone_small':
        width = 40;
        height = 25;
        y = groundY - [80.0, 120.0][rnd.nextInt(2)];
        break;
      case 'drone_large':
        width = 55;
        height = 35;
        y = groundY - [90.0, 130.0][rnd.nextInt(2)];
        break;
    }
  }

  void update(double gameSpeed) {
    x -= gameSpeed;

    // =============================================
    // ✅ Nature animations
    // =============================================
    if (type == 'bee') {
      flapPhase += 0.3;
      hoverPhase += 0.12;
    } else if (type == 'bluefish') {
      flapPhase += 0.2;
      hoverPhase += 0.1;
    } else if (type == 'frog') {
      flapPhase += 0.1;
    } else if (type == 'ladybug') {
      flapPhase += 0.12;
    } else if (type == 'mouse') {
      flapPhase += 0.15;
    } else if (type == 'saw') {
      rotation += 0.15; // rotates continuously
    } else if (type == 'blockslime') {
      flapPhase += 0.12;
    } else if (type == 'cactus_new' || type == 'cactus_new_large') {
      // ثابت
    }

    // =============================================
    // ✅ Platformer animations
    // =============================================
    else if (type == 'slime') {
      flapPhase += 0.15;
    } else if (type == 'snail') {
      flapPhase += 0.08;
    } else if (type == 'fly') {
      flapPhase += 0.25;
      hoverPhase += 0.1;
    } else if (type == 'fish') {
      flapPhase += 0.2;
    } else if (type == 'blocker') {
      flapPhase += 0.1;
    }

    // =============================================
    // ✅ الأنماط القديمة
    // =============================================
    else if (type == 'pterodactyl') {
      flapPhase += 0.3;
    } else if (type.startsWith('drone')) {
      hoverPhase += 0.15;
    } else if (type.startsWith('rock')) {
      rotation += rotationSpeed;
    }
  }

  bool isOffscreen() => x + width < 0;

  Rect getRect() {
    // ✅ Nature enemies
    if (obstacleStyle == 'nature') {
      if (type == 'bee' || type == 'bluefish') {
        const padding = 4.0;
        return Rect.fromLTWH(
            x + padding, y + padding, width - padding * 2, height - padding * 2);
      }
      return Rect.fromLTWH(x, y, width, height);
    }

    // ✅ Platformer enemies
    if (obstacleStyle == 'platformer') {
      if (type == 'fly' || type == 'fish') {
        const padding = 4.0;
        return Rect.fromLTWH(
            x + padding, y + padding, width - padding * 2, height - padding * 2);
      }
      return Rect.fromLTWH(x, y, width, height);
    }

    // ✅ الأنماط القديمة
    if (type.startsWith('drone')) {
      const padding = 8.0;
      return Rect.fromLTWH(
          x + padding, y + padding, width - padding * 2, height - padding * 2);
    } else if (type.startsWith('rock')) {
      const padding = 5.0;
      return Rect.fromLTWH(
          x + padding, y + padding, width - padding * 2, height - padding * 2);
    }
    return Rect.fromLTWH(x, y, width, height);
  }

  void draw(Canvas canvas, bool isNight) {
    // =============================================
    // ✅ Nature Sprites
    // =============================================
    if (obstacleStyle == 'nature') {
      _drawNatureSprite(canvas);

      if (health < maxHealth) {
        _drawHealthBar(canvas);
      }
      return;
    }

    // =============================================
    // ✅ Platformer Sprites
    // =============================================
    if (obstacleStyle == 'platformer') {
      _drawPlatformerSprite(canvas);

      if (health < maxHealth) {
        _drawHealthBar(canvas);
      }
      return;
    }

    // =============================================
    // ✅ الأنماط القديمة
    // =============================================
    Color color;
    switch (obstacleStyle) {
      case 'rocks':
        color = isNight ? const Color(0xFFC8BEB4) : const Color(0xFF786E64);
        break;
      case 'cars':
        color = isNight ? const Color(0xFFFF6464) : const Color(0xFFC83232);
        break;
      case 'drones':
        color = isNight ? const Color(0xFFB4B4DC) : const Color(0xFF3C3C50);
        break;
      default:
        color = isNight ? const Color(0xFFFFFFFF) : const Color(0xFF535353);
    }

    switch (type) {
      case 'cactus_small':
        _drawCactus(canvas, color, 1);
        break;
      case 'cactus_large':
        _drawCactus(canvas, color, 1.5);
        break;
      case 'cactus_double':
        _drawCactusDouble(canvas, color);
        break;
      case 'pterodactyl':
        _drawPterodactyl(canvas, color);
        break;
      case 'rock_small':
      case 'rock_medium':
      case 'rock_large':
        _drawRock(canvas, color);
        break;
      case 'car_small':
      case 'car_large':
        _drawCar(canvas, color);
        break;
      case 'drone_small':
      case 'drone_large':
        _drawDrone(canvas, color);
        break;
    }

    if (health < maxHealth) {
      _drawHealthBar(canvas);
    }
  }

  // =============================================
  // ✅ رسم Health Bar
  // =============================================
  void _drawHealthBar(Canvas canvas) {
    final healthRatio = health / maxHealth;
    canvas.drawRect(
      Rect.fromLTWH(x, y - 10, width, 4),
      Paint()..color = const Color(0xFFFF0000),
    );
    canvas.drawRect(
      Rect.fromLTWH(x, y - 10, width * healthRatio, 4),
      Paint()..color = const Color(0xFF00FF00),
    );
  }

  // =============================================
  // ✅ رسم Nature Sprite
  // =============================================
  void _drawNatureSprite(Canvas canvas) {
    String? key;

    switch (type) {
      case 'bee':
        key = (flapPhase % 2).floor() == 0 ? 'bee1' : 'bee2';
        break;
      case 'bluefish':
        key = (flapPhase % 2).floor() == 0 ? 'bluefish1' : 'bluefish2';
        break;
      case 'frog':
        key = (flapPhase % 2).floor() == 0 ? 'frog1' : 'frog2';
        break;
      case 'ladybug':
        key = (flapPhase % 2).floor() == 0 ? 'ladybug1' : 'ladybug2';
        break;
      case 'mouse':
        key = (flapPhase % 2).floor() == 0 ? 'mouse1' : 'mouse2';
        break;
      case 'saw':
        key = (flapPhase % 2).floor() == 0 ? 'saw1' : 'saw2';
        break;
      case 'blockslime':
        key = (flapPhase % 2).floor() == 0 ? 'blockslime1' : 'blockslime2';
        break;
      case 'cactus_new':
        key = 'cactus_new';
        break;
      case 'cactus_new_large':
        key = 'cactus_new_large';
        break;
    }

    if (key == null) return;
    final img = ObstacleSpriteCache.get(key);

    if (img == null) {
      _drawPlaceholder(canvas);
      return;
    }

    // ✅ دوران السو (saw)
    if (type == 'saw') {
      canvas.save();
      final cx = x + width / 2;
      final cy = y + height / 2;
      canvas.translate(cx, cy);
      canvas.rotate(rotation);
      canvas.translate(-cx, -cy);
    }

    // ✅ اهتزاز طفيف للأعداء الطائرة
    double bobY = 0;
    if (type == 'bee' || type == 'bluefish') {
      bobY = math.sin(hoverPhase) * 3;
    }

    final imgAspect = img.width / img.height;
    final targetH = height;
    final targetW = targetH * imgAspect;
    final drawX = x + (width - targetW) / 2;

    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      Rect.fromLTWH(drawX, y + bobY, targetW, targetH),
      Paint()..filterQuality = FilterQuality.medium,
    );

    if (type == 'saw') {
      canvas.restore();
    }
  }

  // =============================================
  // ✅ رسم Platformer Sprite
  // =============================================
  void _drawPlatformerSprite(Canvas canvas) {
    String? key;

    switch (type) {
      case 'slime':
        key = (flapPhase % 2).floor() == 0 ? 'slime1' : 'slime2';
        break;
      case 'snail':
        key = (flapPhase % 2).floor() == 0 ? 'snail1' : 'snail2';
        break;
      case 'fly':
        key = (flapPhase % 2).floor() == 0 ? 'fly1' : 'fly2';
        break;
      case 'fish':
        key = (flapPhase % 2).floor() == 0 ? 'fish1' : 'fish2';
        break;
      case 'poker':
        key = 'poker';
        break;
      case 'blocker':
        key = 'blocker';
        break;
    }

    if (key == null) return;
    final img = ObstacleSpriteCache.get(key);

    if (img == null) {
      _drawPlaceholder(canvas);
      return;
    }

    final imgAspect = img.width / img.height;
    final targetH = height;
    final targetW = targetH * imgAspect;
    final drawX = x + (width - targetW) / 2;

    double bobY = 0;
    if (type == 'fly' || type == 'fish') {
      bobY = math.sin(hoverPhase) * 3;
    } else if (type == 'slime' || type == 'snail') {
      bobY = math.sin(flapPhase) * 1;
    }

    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      Rect.fromLTWH(drawX, y + bobY, targetW, targetH),
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  // =============================================
  // ✅ Placeholder
  // =============================================
  void _drawPlaceholder(Canvas canvas) {
    Color color;
    switch (type) {
      case 'bee':
        color = const Color(0xFFFFC107);
        break;
      case 'bluefish':
        color = const Color(0xFF2196F3);
        break;
      case 'frog':
        color = const Color(0xFF4CAF50);
        break;
      case 'ladybug':
        color = const Color(0xFFE91E63);
        break;
      case 'mouse':
        color = const Color(0xFF9E9E9E);
        break;
      case 'saw':
        color = const Color(0xFF607D8B);
        break;
      case 'blockslime':
        color = const Color(0xFF8BC34A);
        break;
      case 'cactus_new':
      case 'cactus_new_large':
        color = const Color(0xFF2E7D32);
        break;
      default:
        color = const Color(0xFF9E9E9E);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, width, height),
        const Radius.circular(4),
      ),
      Paint()..color = color,
    );
  }

  // =============================================
  // ✅ رسم الأنماط القديمة (زي ما هو - بدون تغيير)
  // =============================================
  void _drawCactus(Canvas canvas, Color color, double scale) {
    final paint = Paint()..color = color;
    final trunkW = 8.0 * scale;
    final trunkH = height;
    final trunkX = x + (width - trunkW) / 2;

    canvas.drawRect(Rect.fromLTWH(trunkX, y, trunkW, trunkH), paint);

    final armW = 6.0 * scale;
    final armH = 15.0 * scale;

    canvas.drawRect(Rect.fromLTWH(x, y + trunkH * 0.3, armW, armH), paint);
    canvas.drawRect(
        Rect.fromLTWH(x, y + trunkH * 0.3, trunkX - x + armW, armW), paint);

    canvas.drawRect(
        Rect.fromLTWH(trunkX + trunkW, y + trunkH * 0.4, armW, armH), paint);
    canvas.drawRect(
        Rect.fromLTWH(trunkX + trunkW, y + trunkH * 0.4,
            x + width - trunkX - trunkW, armW),
        paint);
  }

  void _drawCactusDouble(Canvas canvas, Color color) {
    final paint = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(x, groundY - 50, 15, 50), paint);
    canvas.drawRect(Rect.fromLTWH(x + 20, groundY - 55, 18, 55), paint);
  }

  void _drawPterodactyl(Canvas canvas, Color color) {
    final paint = Paint()..color = color;
    canvas.drawOval(Rect.fromLTWH(x, y + 10, 25, 12), paint);
    canvas.drawCircle(Offset(x + 27, y + 12), 5, paint);
    final eyePaint = Paint()..color = const Color(0xFFFF3232);
    canvas.drawCircle(Offset(x + 29, y + 10), 2, eyePaint);

    final flapOffset = 8 * math.sin(flapPhase);
    canvas.drawOval(Rect.fromLTWH(x + 5, y - 5 + flapOffset, 20, 10), paint);
    canvas.drawOval(Rect.fromLTWH(x + 5, y + 15 - flapOffset, 18, 8), paint);
  }

  void _drawRock(Canvas canvas, Color color) {
    final center = Offset(x + width / 2, y + height / 2);
    final radius = math.min(width, height) / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    final path = Path();
    final rnd = math.Random(type.hashCode);
    for (int i = 0; i < 7; i++) {
      final angle = (i / 7) * 2 * math.pi;
      final r = radius * (0.75 + rnd.nextDouble() * 0.3);
      final px = center.dx + r * math.cos(angle);
      final py = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();

    final fillPaint = Paint()..color = color;
    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    canvas.restore();
  }

  void _drawCar(Canvas canvas, Color color) {
    final wheelSize = height * 0.35;
    final bodyH = height * 0.7;
    final bodyY = y + (height - bodyH - wheelSize / 2);

    final wheelPaint = Paint()..color = const Color(0xFF1E1E1E);
    canvas.drawCircle(Offset(x + width * 0.2, groundY - wheelSize / 2),
        wheelSize / 2, wheelPaint);
    canvas.drawCircle(Offset(x + width * 0.8, groundY - wheelSize / 2),
        wheelSize / 2, wheelPaint);

    final bodyPaint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, bodyY, width, bodyH),
        const Radius.circular(8),
      ),
      bodyPaint,
    );

    final roofW = width * 0.6;
    final roofH = height * 0.35;
    final roofX = x + (width - roofW) / 2;
    final roofY = bodyY - roofH;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(roofX, roofY, roofW, roofH),
        const Radius.circular(5),
      ),
      bodyPaint,
    );

    final windowPaint = Paint()..color = const Color(0xFF96C8FF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(roofX + 5, roofY + 3, roofW / 2 - 8, roofH - 6),
        const Radius.circular(3),
      ),
      windowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(roofX + roofW / 2 + 3, roofY + 3,
            roofW / 2 - 8, roofH - 6),
        const Radius.circular(3),
      ),
      windowPaint,
    );

    final lightPaint = Paint()..color = const Color(0xFFFFEB64);
    canvas.drawCircle(
      Offset(x + width - 6, bodyY + bodyH * 0.3 + 4),
      4,
      lightPaint,
    );
  }

  void _drawDrone(Canvas canvas, Color color) {
    final hoverOffset = 5 * math.sin(hoverPhase);
    final centerX = x + width / 2;
    final centerY = y + height / 2 + hoverOffset;

    final paint = Paint()..color = color;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: width * 0.5,
        height: height * 0.6,
      ),
      paint,
    );

    final armLen = width * 0.45;
    final armPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeWidth = math.max(3, width * 0.08)
      ..style = PaintingStyle.stroke;

    for (final angleDeg in [45, 135, 225, 315]) {
      final angle = angleDeg * math.pi / 180;
      final endX = centerX + armLen * math.cos(angle);
      final endY = centerY + armLen * math.sin(angle) * 0.5;
      canvas.drawLine(Offset(centerX, centerY), Offset(endX, endY), armPaint);
    }

    final propPaint = Paint()..color = const Color(0xC8C8C8C8);
    for (final angleDeg in [45, 135, 225, 315]) {
      final angle = angleDeg * math.pi / 180;
      final endX = centerX + armLen * math.cos(angle);
      final endY = centerY + armLen * math.sin(angle) * 0.5;
      canvas.drawCircle(Offset(endX, endY), width * 0.12, propPaint);
    }

    final ledPaint = Paint()..color = const Color(0xFFFF3232);
    canvas.drawCircle(Offset(centerX, centerY - 3), 3, ledPaint);
  }
}
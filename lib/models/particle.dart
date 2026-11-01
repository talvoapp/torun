import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  int lifetime;
  final int maxLifetime;
  final double gravity;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    this.lifetime = 100,
    this.gravity = 0.1,
  }) : maxLifetime = lifetime;

  void update() {
    x += vx;
    y += vy;
    vy += gravity;
    lifetime--;
  }

  bool get isDead => lifetime <= 0;

  double get alpha => (lifetime / maxLifetime).clamp(0.0, 1.0);

  void draw(Canvas canvas) {
    final paint = Paint()..color = color.withValues(alpha: alpha);
    canvas.drawCircle(Offset(x, y), size / 2, paint);
  }
}

class ParticleSystem {
  String effectType;
  final List<Particle> particles = [];
  int spawnTimer = 0;

  ParticleSystem({this.effectType = 'particles_none'});

  Map<String, dynamic> get _config {
    switch (effectType) {
      case 'particles_stars':
        return {
          'enabled': true,
          'spawnRate': 3,
          'colors': ['#ffd700', '#ffed4e', '#ffffff', '#fff4b3'],
          'sizes': [2.0, 5.0],
          'speedX': [-2.0, -0.5],
          'speedY': [-1.0, 1.0],
          'gravity': 0.0,
          'lifetime': 120,
        };
      case 'particles_fire':
        return {
          'enabled': true,
          'spawnRate': 2,
          'colors': ['#ff4500', '#ff6600', '#ffaa00', '#ffdd00'],
          'sizes': [3.0, 8.0],
          'speedX': [-3.0, -1.0],
          'speedY': [-2.0, 0.0],
          'gravity': -0.15,
          'lifetime': 60,
        };
      case 'particles_snow':
        return {
          'enabled': true,
          'spawnRate': 5,
          'colors': ['#ffffff', '#e0f7ff', '#cceeff'],
          'sizes': [2.0, 5.0],
          'speedX': [-1.0, 0.5],
          'speedY': [0.5, 1.5],
          'gravity': 0.02,
          'lifetime': 200,
        };
      case 'particles_bubbles':
        return {
          'enabled': true,
          'spawnRate': 8,
          'colors': ['#88ddff', '#aaddff', '#cceecc'],
          'sizes': [4.0, 10.0],
          'speedX': [-1.0, -0.3],
          'speedY': [-1.5, -0.5],
          'gravity': -0.05,
          'lifetime': 150,
        };
      case 'particles_lightning':
        return {
          'enabled': true,
          'spawnRate': 20,
          'colors': ['#ffffff', '#ffff88', '#88ffff'],
          'sizes': [2.0, 4.0],
          'speedX': [-5.0, -2.0],
          'speedY': [-3.0, 3.0],
          'gravity': 0.0,
          'lifetime': 30,
        };
      default:
        return {'enabled': false};
    }
  }

  void setEffect(String type) {
    effectType = type;
    particles.clear();
  }

  void update(double screenWidth, double screenHeight, double groundY) {
    final config = _config;
    if (config['enabled'] != true) return;

    spawnTimer++;
    final spawnRate = config['spawnRate'] as int;
    if (spawnTimer >= spawnRate) {
      spawnTimer = 0;
      _spawnParticle(screenWidth, screenHeight, groundY, config);
    }

    for (final p in particles) {
      p.update();
    }
    particles.removeWhere((p) => p.isDead);

    if (particles.length > 200) {
      particles.removeRange(0, particles.length - 200);
    }
  }

  void _spawnParticle(double screenWidth, double screenHeight,
      double groundY, Map<String, dynamic> config) {
    final rnd = math.Random();
    double x = rnd.nextDouble() * screenWidth;
    double y;

    switch (effectType) {
      case 'particles_fire':
        y = groundY - rnd.nextDouble() * 10;
        break;
      case 'particles_bubbles':
        y = screenHeight - rnd.nextDouble() * 20;
        break;
      case 'particles_snow':
        y = -10 + rnd.nextDouble() * 30;
        break;
      default:
        y = rnd.nextDouble() * screenHeight;
    }

    final colors = config['colors'] as List<String>;
    final colorHex = colors[rnd.nextInt(colors.length)];
    final color = _parseHexColor(colorHex);

    final sizes = config['sizes'] as List<double>;
    final size = sizes[0] + rnd.nextDouble() * (sizes[1] - sizes[0]);

    final speedX = config['speedX'] as List<double>;
    final vx = speedX[0] + rnd.nextDouble() * (speedX[1] - speedX[0]);

    final speedY = config['speedY'] as List<double>;
    final vy = speedY[0] + rnd.nextDouble() * (speedY[1] - speedY[0]);

    final lifetime = (config['lifetime'] as int) + rnd.nextInt(40) - 20;
    final gravity = config['gravity'] as double;

    particles.add(Particle(
      x: x,
      y: y,
      vx: vx,
      vy: vy,
      size: size,
      color: color,
      lifetime: lifetime,
      gravity: gravity,
    ));
  }

  static Color _parseHexColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  void draw(Canvas canvas) {
    for (final p in particles) {
      p.draw(canvas);
    }
  }
}
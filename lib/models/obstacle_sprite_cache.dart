import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Cache لأعداء Platformer
/// بيحمل الصور مرة واحدة في الذاكرة، ويستخدمها الأعداء
class ObstacleSpriteCache {
  static final Map<String, ui.Image> _images = {};
  static bool _loading = false;
  static bool _loaded = false;

  static Future<void> preload() async {
    if (_loaded || _loading) return;
    _loading = true;

    final paths = {
      'slime1': 'assets/images/obstacles/platformer/slime1.png',
      'slime2': 'assets/images/obstacles/platformer/slime2.png',
      'fly1': 'assets/images/obstacles/platformer/fly1.png',
      'fly2': 'assets/images/obstacles/platformer/fly2.png',
      'snail1': 'assets/images/obstacles/platformer/snail1.png',
      'snail2': 'assets/images/obstacles/platformer/snail2.png',
      'fish1': 'assets/images/obstacles/platformer/fish1.png',
      'fish2': 'assets/images/obstacles/platformer/fish2.png',
      'poker': 'assets/images/obstacles/platformer/poker.png',
      'blocker': 'assets/images/obstacles/platformer/blocker.png',
    };

    for (final entry in paths.entries) {
      try {
        final data = await rootBundle.load(entry.value);
        final codec =
            await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        _images[entry.key] = frame.image;
      } catch (e) {
        debugPrint('Failed to load ${entry.value}: $e');
      }
    }

    _loaded = true;
    _loading = false;
  }

  static ui.Image? get(String key) => _images[key];

  static bool get isReady => _loaded;
}
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../models/power_up.dart';
import '../services/shop_catalog.dart';
import '../l10n/item_translations.dart';
import '../generated/l10n/app_localizations.dart';

class GamePainter extends CustomPainter {
  final GameState state;
  final AppLocalizations l10n;
  final String locale;

  // ✅ Cache لخلفيات الصور
  static final Map<String, ui.Image?> _bgImageCache = {};

  GamePainter({
    required this.state,
    required this.l10n,
    required this.locale,
    super.repaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (state.player == null) return;

    final w = size.width;
    final h = size.height;
    final groundY = state.groundY;

    _drawBackground(canvas, w, h);

    if (state.dayNightPhase > 0) {
      for (final s in state.stars) {
        s.draw(canvas);
      }
    }

    if (state.dayNightPhase < 1) {
      for (final c in state.clouds) {
        c.draw(canvas);
      }
    }

    _drawGround(canvas, w, groundY);

    for (final o in state.obstacles) {
      o.draw(canvas, state.isNight);
    }

    final bgColor = _getBgColor();
    for (final f in state.groundFeatures) {
      f.draw(canvas, state.isNight, bgColor);
    }

    if (state.status != GameStatus.idle) {
      state.player!.draw(canvas);
    }

    state.particleSystem.draw(canvas);

    for (final p in state.powerUps) {
      p.draw(canvas);
    }

    for (final z in state.zombies) {
      z.draw(canvas, state.isNight);
    }

    _drawActivePowerUps(canvas, w, h);

    if (state.equippedWeapon != 'weapon_none' &&
        state.status == GameStatus.running) {
      _drawAimIndicator(canvas);
    }

    if (state.equippedWeapon != 'weapon_none') {
      for (final b in state.bullets) {
        b.draw(canvas);
      }
    }

    _drawScore(canvas, w);
    _drawBadge(canvas, w, h);
    _drawState(canvas, w, h);
  }

  Color _getBgColor() {
    if (state.isNight) return const Color(0xFF141E3C);
    return const Color(0xFFF7F7F7);
  }

  // =============================================
  // ✅ رسم الخلفية (يدعم الصور والتدرجات)
  // =============================================
  void _drawBackground(Canvas canvas, double w, double h) {
    final bgData = ShopCatalog.backgrounds[state.currentBackground];

    // ✅ لو الخلفية صورة
    if (bgData != null && bgData['image'] != null) {
      final imagePath = bgData['image'] as String;

      if (!_bgImageCache.containsKey(imagePath)) {
        _bgImageCache[imagePath] = null; // mark as loading
        _loadBackgroundImage(imagePath);
      }

      final img = _bgImageCache[imagePath];
      if (img != null) {
        // ✅ ارسم الصورة ممتدة على كامل الشاشة
        canvas.drawImageRect(
          img,
          Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
          Rect.fromLTWH(0, 0, w, h),
          Paint()..filterQuality = FilterQuality.medium,
        );

        // ✅ طبقة ليلية فوق الصورة
        if (state.dayNightPhase > 0) {
          canvas.drawRect(
            Rect.fromLTWH(0, 0, w, h),
            Paint()
              ..color = const Color(0xFF0A0F28)
                  .withValues(alpha: state.dayNightPhase * 0.65),
          );
        }
        return;
      }
      // لو لسه بيتحمل - نروح للـ fallback
    }

    // ✅ Fallback: gradient (الخلفيات القديمة)
    Color topDay = const Color(0xFFF0F8FF);
    Color bottomDay = const Color(0xFFF7F7F7);

    if (bgData != null &&
        bgData['topColor'] != null &&
        bgData['bottomColor'] != null) {
      final top = bgData['topColor'] as List<int>;
      final bottom = bgData['bottomColor'] as List<int>;
      topDay = Color.fromARGB(255, top[0], top[1], top[2]);
      bottomDay = Color.fromARGB(255, bottom[0], bottom[1], bottom[2]);
    }

    const topNight = Color(0xFF0A0F28);
    const bottomNight = Color(0xFF141E3C);

    final t = state.dayNightPhase;
    final topColor = Color.lerp(topDay, topNight, t) ?? topDay;
    final bottomColor = Color.lerp(bottomDay, bottomNight, t) ?? bottomDay;

    final rect = Rect.fromLTWH(0, 0, w, h);
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, h),
        [topColor, bottomColor],
      );
    canvas.drawRect(rect, paint);
  }

  Future<void> _loadBackgroundImage(String path) async {
    try {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _bgImageCache[path] = frame.image;
      debugPrint('✅ Loaded bg: $path');
    } catch (e) {
      debugPrint('❌ Failed to load bg: $path - $e');
    }
  }

  void _drawGround(Canvas canvas, double w, double groundY) {
    final bgData = ShopCatalog.backgrounds[state.currentBackground];
    Color groundColor;

    if (bgData != null && bgData['groundColor'] != null) {
      final g = bgData['groundColor'] as List<int>;
      groundColor = Color.fromARGB(255, g[0], g[1], g[2]);
    } else {
      groundColor =
          state.isNight ? const Color(0xFF646464) : const Color(0xFF535353);
    }

    final linePaint = Paint()
      ..color = groundColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, groundY), Offset(w, groundY), linePaint);

    final dotPaint = Paint()..color = groundColor;
    final offset = (state.elapsedFrames * state.gameSpeed / 60) % 40;
    for (double x = -offset; x < w; x += 40) {
      canvas.drawRect(Rect.fromLTWH(x, groundY + 5, 2, 2), dotPaint);
      canvas.drawRect(Rect.fromLTWH(x + 15, groundY + 12, 3, 3), dotPaint);
      canvas.drawRect(Rect.fromLTWH(x + 30, groundY + 7, 2, 2), dotPaint);
    }
  }

  void _drawActivePowerUps(Canvas canvas, double w, double h) {
    final active =
        state.activePowerUps.entries.where((e) => e.value > 0).toList();
    if (active.isEmpty) return;

    const x = 15.0;
    final yBase = h - 30 * active.length - 10;

    for (int i = 0; i < active.length; i++) {
      final type = active[i].key;
      final framesLeft = active[i].value;
      final data = PowerUp.types[type];
      if (data == null) continue;

      const barW = 150.0;
      const barH = 25.0;
      final y = yBase + i * 30;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, barW, barH), const Radius.circular(8)),
        Paint()..color = const Color(0xB4000000),
      );

      final maxDur = data['duration'] as int;
      final progress = framesLeft / maxDur;
      final colorHex = data['color'] as String;
      final color =
          Color(int.parse('FF${colorHex.replaceFirst('#', '')}', radix: 16));

      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, barW * progress, barH),
            const Radius.circular(8)),
        Paint()..color = color,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: _getPowerUpName(type),
          style: const TextStyle(
              color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.rtl,
      );
      tp.layout();
      tp.paint(canvas,
          Offset(x + (barW - tp.width) / 2, y + (barH - tp.height) / 2));
    }
  }

  String _getPowerUpName(String type) {
    switch (type) {
      case 'speed':
        return l10n.powerUpSpeed;
      case 'shield':
        return l10n.powerUpShield;
      case 'coin_magnet':
        return l10n.powerUpCoinMagnet;
      case 'double_coins':
        return l10n.powerUpDoubleCoins;
      case 'slow_motion':
        return l10n.powerUpSlowMotion;
      default:
        return type;
    }
  }

  void _drawAimIndicator(Canvas canvas) {
    if (state.player == null) return;
    final p = state.player!;
    final ax = p.x + p.width + 20;
    final ay = p.y + p.height / 2;
    final angleRad = state.aimAngle * math.pi / 180;
    final ex = ax + 30 * math.cos(angleRad);
    final ey = ay + 30 * math.sin(angleRad);

    final linePaint = Paint()
      ..color = const Color(0xFFFF3232)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(ax, ay), Offset(ex, ey), linePaint);

    canvas.drawCircle(
        Offset(ex, ey), 4, Paint()..color = const Color(0xFFFF3232));
  }

  void _drawScore(Canvas canvas, double w) {
    const boxW = 130.0;
    const boxH = 35.0;

    _drawBadgeBox(
      canvas,
      const Rect.fromLTWH(8, 8, boxW, boxH),
      '🏆 ${l10n.best}: ${state.highScore}${l10n.seconds}',
      const Color(0xFFFFC107),
    );

    final coins = state.scoreService.coins;
    final coinsX = (w - boxW) / 2;
    _drawBadgeBox(
      canvas,
      Rect.fromLTWH(coinsX, 8, boxW, boxH),
      '💰 ${_formatNumber(coins)}',
      const Color(0xFFFFC107),
    );

    _drawBadgeBox(
      canvas,
      Rect.fromLTWH(w - boxW - 8, 8, boxW, boxH),
      '🎯 ${l10n.score}: ${state.score.toInt()}${l10n.seconds}',
      const Color(0xFF0D6EFD),
    );
  }

  // ✅ تنسيق الأرقام الكبيرة (K/M)
  String _formatNumber(int n) {
    if (n >= 1000000) {
      final m = n / 1000000;
      return m == m.roundToDouble() ? '${m.toInt()}M' : '${m.toStringAsFixed(1)}M';
    } else if (n >= 1000) {
      final k = n / 1000;
      return k == k.roundToDouble() ? '${k.toInt()}K' : '${k.toStringAsFixed(1)}K';
    }
    return n.toString();
  }

  void _drawBadgeBox(Canvas canvas, Rect rect, String text, Color borderColor) {
    final bgColor =
        state.isNight ? const Color(0xC81E1E32) : const Color(0xDCFFFFFF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()..color = bgColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
            color: borderColor, fontSize: 13, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
        canvas,
        Offset(rect.left + (rect.width - tp.width) / 2,
            rect.top + (rect.height - tp.height) / 2));
  }

  void _drawBadge(Canvas canvas, double w, double h) {
    final badgeData = ShopCatalog.badges[state.currentBadge];
    if (badgeData == null) return;

    const bsize = 32.0;
    const bx = 145.0;
    const by = 9.0;
    const center = Offset(bx + bsize / 2, by + bsize / 2);

    final bgColor =
        state.isNight ? const Color(0xC81E1E32) : const Color(0xDCFFFFFF);

    canvas.drawCircle(
      center,
      bsize / 2,
      Paint()..color = bgColor,
    );

    canvas.drawCircle(
      center,
      bsize / 2,
      Paint()
        ..color = const Color(0xFFFFC107)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final emoji = (badgeData['name'] as String).split(' ').first;
    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: const TextStyle(fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(bx + (bsize - tp.width) / 2, by + (bsize - tp.height) / 2),
    );
  }

  void _drawState(Canvas canvas, double w, double h) {
    if (state.status == GameStatus.idle) {
      _drawIdle(canvas, w, h);
    } else if (state.status == GameStatus.gameOver) {
      _drawGameOver(canvas, w, h);
    } else if (state.status == GameStatus.paused) {
      _drawPaused(canvas, w, h);
    }
  }

  void _drawIdle(Canvas canvas, double w, double h) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xC8FFFFFF));

    _centeredText(canvas, '🎮 torun', w, h * 0.25, 28, const Color(0xFF0D6EFD),
        FontWeight.bold);
    _centeredText(canvas, l10n.tapToStart, w, h * 0.5 - 30, 14,
        const Color(0xFF535353), FontWeight.normal);
    _centeredText(
        canvas,
        '${l10n.swipeUpToJump}  •  ${l10n.swipeDownToDuck}',
        w,
        h * 0.5,
        11,
        const Color(0xFF787878),
        FontWeight.normal);

    if (state.highScore > 0) {
      _centeredText(
          canvas,
          '🏆 ${l10n.highScore}: ${state.highScore} ${l10n.seconds}',
          w,
          h * 0.5 + 30,
          13,
          const Color(0xFFFFC107),
          FontWeight.bold);
    }
  }

  void _drawGameOver(Canvas canvas, double w, double h) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0x96000000));

    _centeredText(canvas, '💀 ${l10n.gameOver}', w, h * 0.25, 32,
        const Color(0xFFFF5252), FontWeight.bold);
    _centeredText(
        canvas,
        '${l10n.yourScore}: ${state.score.toInt()} ${l10n.seconds}',
        w,
        h * 0.5 - 40,
        18,
        Colors.white,
        FontWeight.bold);

    if (state.isNewHighScore) {
      _centeredText(canvas, '🏆 ${l10n.newHighScore}', w, h * 0.5, 16,
          const Color(0xFFFFC107), FontWeight.bold);
    } else {
      _centeredText(
          canvas,
          '🏆 ${l10n.highScore}: ${state.highScore} ${l10n.seconds}',
          w,
          h * 0.5,
          12,
          const Color(0xFFC8C8C8),
          FontWeight.normal);
    }

    _centeredText(
        canvas,
        '🔫 ${l10n.bullets}: ${state.bulletsFiredThisGame}  •  💀 ${l10n.enemies}: ${state.killsThisGame}',
        w,
        h * 0.5 + 30,
        12,
        const Color(0xFFC8DCFF),
        FontWeight.bold);

    if (state.newAchievements.isNotEmpty) {
      _centeredText(canvas, '🎉 ${l10n.newAchievements}', w, h * 0.5 + 60, 13,
          const Color(0xFF00FF88), FontWeight.bold);
      for (int i = 0;
          i < state.newAchievements.length && i < 3;
          i++) {
        final achId = state.newAchievements[i];
        final data = ShopCatalog.badges[achId] ??
            ShopCatalog.weaponAchievements[achId];
        if (data != null) {
          final achName = ItemTranslations.getName(
            achId,
            locale,
            data['name'] as String,
          );
          _centeredText(canvas, achName, w,
              h * 0.5 + 85 + i * 20, 11, const Color(0xFFFFC107),
              FontWeight.normal);
        }
      }
    }

    _centeredText(canvas, l10n.tapToRestart, w, h - 60, 12,
        const Color(0xFFC8C8C8), FontWeight.normal);
  }

  void _drawPaused(Canvas canvas, double w, double h) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0x96000000));
    _centeredText(canvas, '⏸️ ${l10n.paused}', w, h / 2 - 20, 32,
        const Color(0xFFFFC107), FontWeight.bold);
    _centeredText(canvas, l10n.tapToResume, w, h / 2 + 30, 13, Colors.white,
        FontWeight.normal);
  }

  void _centeredText(Canvas canvas, String text, double w, double y,
      double fontSize, Color color, FontWeight weight) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style:
            TextStyle(color: color, fontSize: fontSize, fontWeight: weight),
      ),
      textDirection: TextDirection.rtl,
    );
    tp.layout();
    tp.paint(canvas, Offset((w - tp.width) / 2, y));
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
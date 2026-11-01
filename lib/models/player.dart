import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../services/shop_catalog.dart';
import 'rigs/character_rig.dart';

/// اللاعب الرئيسي
/// - يدعم الصور (PNG) زي logo.png
/// - يدعم الشخصيات الحقيقية (Kenney Sprites) مع أنيميشن
/// - يدعم الهياكل العظمية (HumanRig / CarRig) مع تاج وعباءة
/// - يدعم المظاهر (Skins) كطبقة توهج لونية
/// - يدعم البيئات (Environments) بجاذبية وقفز مختلفين
class Player {
  // ✅ الفيزياء
  double x = GameConstants.playerX;
  double y;
  double groundY;
  double baseWidth = GameConstants.playerWidth;
  double baseHeight = GameConstants.playerHeight;
  double width = GameConstants.playerWidth;
  double height = GameConstants.playerHeight;

  double velocityY = 0;
  bool isJumping = false;
  bool isDucking = false;
  bool isDead = false;

  // ✅ مضاعفات البيئة
  double gravityMultiplier = 1.0;
  double jumpMultiplier = 1.0;

  // ✅ الأنيميشن
  double runFrame = 0;
  double jumpPhase = 0;
  double glowPhase = 0;
  double rainbowPhase = 0;
  double squash = 1.0;

  // ✅ Trail والجزيئات
  final List<Map<String, dynamic>> trail = [];
  static const int trailMaxLength = 8;
  final List<Map<String, dynamic>> particles = [];
  int particleTimer = 0;

  // ✅ الهوية (شخصية + مظهر)
  String characterId;
  String skinId;
  Map<String, dynamic> characterData;
  Map<String, dynamic> skinData;

  // ✅ الأصول (3 أنماط)
  CharacterRig? _rig;
  ui.Image? _image;
  final Map<String, ui.Image> _sprites = {};
  bool _imageLoading = false;
  double _spriteScale = 1.0;

  // ✅ Paint objects مخزنة
  final Paint _imagePaint = Paint()..filterQuality = FilterQuality.medium;
  final Paint _glowPaint = Paint();
  final Paint _particlePaint = Paint();
  final Paint _trailPaint = Paint();

  Player({
    required this.groundY,
    this.characterId = 'char_default',
    this.skinId = 'skin_classic',
  })  : y = groundY - GameConstants.playerHeight,
        characterData = ShopCatalog.characters[characterId] ??
            ShopCatalog.characters['char_default']!,
        skinData =
            ShopCatalog.skins[skinId] ?? ShopCatalog.skins['skin_classic']! {
    _loadCharacter();
  }

  // =============================================
  // ✅ تحميل الشخصية
  // =============================================

  Future<void> _loadCharacter() async {
    _rig = null;
    _image = null;
    _sprites.clear();
    _imageLoading = true;

    // ✅ تطبيق أبعاد الشخصية
    final wm = (characterData['widthMultiplier'] as num?)?.toDouble() ?? 1.0;
    final hm = (characterData['heightMultiplier'] as num?)?.toDouble() ?? 1.0;
    baseWidth = GameConstants.playerWidth * wm;
    baseHeight = GameConstants.playerHeight * hm;
    width = baseWidth;
    height = baseHeight;
    if (groundY > 0) {
      y = groundY - height;
    }
    _spriteScale = (characterData['spriteScale'] as num?)?.toDouble() ?? 1.0;

    // =============================================
    // ✅ نمط 1: صورة PNG (logo.png)
    // =============================================
    if (characterData['image'] != null) {
      try {
        final data = await rootBundle.load(characterData['image'] as String);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        _image = frame.image;
      } catch (e) {
        debugPrint('Error loading character image: $e');
      }
      _imageLoading = false;
      return;
    }

    // =============================================
    // ✅ نمط 2: Sprites (Kenney - صور متحركة)
    // =============================================
    if (characterData['spritePrefix'] != null) {
      final prefix = characterData['spritePrefix'] as String;
      final path = characterData['spritePath'] as String;

      final poseMap = characterData['poseMap'] as Map<String, dynamic>? ?? {
        'idle': 'idle',
        'run0': 'run0',
        'run1': 'run1',
        'run2': 'run2',
        'jump': 'jump',
        'duck': 'duck',
        'hurt': 'hurt',
      };

      for (final pose in [
        'idle',
        'run0',
        'run1',
        'run2',
        'jump',
        'duck',
        'hurt'
      ]) {
        final fileName = poseMap[pose] as String? ?? pose;
        final assetPath = '$path${prefix}_$fileName.png';
        try {
          final data = await rootBundle.load(assetPath);
          final codec =
              await ui.instantiateImageCodec(data.buffer.asUint8List());
          final frame = await codec.getNextFrame();
          _sprites[pose] = frame.image;
        } catch (e) {
          debugPrint('Failed to load sprite: $assetPath');
        }
      }
      _imageLoading = false;
      return;
    }

    // =============================================
    // ✅ نمط 3: Rigs (HumanRig / CarRig)
    // =============================================
    final rigType = characterData['rig'] as String?;
    if (rigType == 'car') {
      _rig = CarRig();
    } else if (rigType == 'human') {
      final params = characterData['rigParams'] as Map<String, dynamic>? ?? {};
      _rig = HumanRig(
        headRatio: (params['headRatio'] as num?)?.toDouble() ?? 0.24,
        torsoRatio: (params['torsoRatio'] as num?)?.toDouble() ?? 0.38,
        legRatio: (params['legRatio'] as num?)?.toDouble() ?? 0.38,
        hasSkirt: params['hasSkirt'] as bool? ?? false,
        hasCrown: params['hasCrown'] as bool? ?? false,
        hasCape: params['hasCape'] as bool? ?? false,
        crownColor: _parseHex(
          params['crownColor'] as String? ?? '#FFD700',
        ),
        capeColor: _parseHex(
          params['capeColor'] as String? ?? '#4A148C',
        ),
      );
    }
    _imageLoading = false;
  }

  void setCharacter(String id) {
    characterId = id;
    characterData = ShopCatalog.characters[id] ??
        ShopCatalog.characters['char_default']!;
    _loadCharacter();
  }

  void setSkin(String id) {
    skinId = id;
    skinData = ShopCatalog.skins[id] ?? ShopCatalog.skins['skin_classic']!;
  }

  // =============================================
  // ✅ الألوان
  // =============================================

  Color get primaryColor => _parseHex(
        characterData['colorPrimary'] as String? ?? '#0d6efd',
      );

  Color get secondaryColor => _parseHex(
        characterData['colorSecondary'] as String? ?? '#0b5ed7',
      );

  Color get skinColor => _parseHex(
        characterData['colorSkin'] as String? ?? '#FFCDB2',
      );

  Color get skinTintColor {
    if (skinData['animated'] == true) {
      final hue = (rainbowPhase % 360) / 60.0;
      final rgb = _hsvToRgb(hue, 0.8, 1.0);
      return Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);
    }
    return _parseHex(skinData['colorPrimary'] as String? ?? '#0d6efd');
  }

  static Color _parseHex(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  static List<int> _hsvToRgb(double h, double s, double v) {
    final i = (h * 6).floor();
    final f = h * 6 - i;
    final p = v * (1 - s);
    final q = v * (1 - f * s);
    final t = v * (1 - (1 - f) * s);
    double r, g, b;
    switch (i % 6) {
      case 0:
        r = v;
        g = t;
        b = p;
        break;
      case 1:
        r = q;
        g = v;
        b = p;
        break;
      case 2:
        r = p;
        g = v;
        b = t;
        break;
      case 3:
        r = p;
        g = q;
        b = v;
        break;
      case 4:
        r = t;
        g = p;
        b = v;
        break;
      default:
        r = v;
        g = p;
        b = q;
    }
    return [(r * 255).round(), (g * 255).round(), (b * 255).round()];
  }

  // =============================================
  // ✅ التحكم
  // =============================================

  void jump() {
    if (!isJumping && !isDucking && !isDead) {
      isJumping = true;
      velocityY = GameConstants.jumpForce * jumpMultiplier;
      squash = 1.3;
      jumpPhase = 0;
    }
  }

  void duck(bool value) {
    if (!isJumping && !isDead) {
      isDucking = value;
      width = value ? baseWidth * 1.3 : baseWidth;
      height = value ? baseHeight * 0.6 : baseHeight;
    }
  }

  // =============================================
  // ✅ التحديث
  // =============================================

  void update() {
    if (isDead) return;

    velocityY += GameConstants.gravity * gravityMultiplier;
    y += velocityY;
    jumpPhase += 0.3;

    if (y >= groundY - height) {
      y = groundY - height;
      if (isJumping && velocityY.abs() > 5) squash = 0.7;
      velocityY = 0;
      isJumping = false;
    }

    if (squash > 1.0) {
      squash = math.max(1.0, squash - 0.05);
    } else if (squash < 1.0) {
      squash = math.min(1.0, squash + 0.05);
    }

    if (!isJumping) runFrame += 0.25;
    glowPhase += 0.15;
    rainbowPhase += 3;

    _rig?.update(
      runPhase: runFrame,
      jumpPhase: jumpPhase,
      isJumping: isJumping,
      isDucking: isDucking,
      isDead: isDead,
    );

    _updateTrail();
    _updateParticles();
  }

  void _updateTrail() {
    if (isJumping) {
      trail.add({'x': x, 'y': y, 'alpha': 200.0});
      if (trail.length > trailMaxLength) trail.removeAt(0);
    } else {
      for (final p in trail) {
        p['alpha'] = (p['alpha'] as double) - 20;
      }
      trail.removeWhere((p) => (p['alpha'] as double) <= 0);
    }
  }

  void _updateParticles() {
    particleTimer++;
    if (!isJumping && !isDucking && particleTimer % 3 == 0) {
      final rnd = math.Random();
      particles.add({
        'x': x + rnd.nextDouble() * 10,
        'y': groundY - rnd.nextDouble() * 5,
        'vx': -1.0 - rnd.nextDouble() * 2,
        'vy': -0.5 - rnd.nextDouble(),
        'size': 2.0 + rnd.nextDouble() * 2,
        'alpha': 150.0,
        'color': skinTintColor,
      });
    }
    for (final p in particles) {
      p['x'] = (p['x'] as double) + (p['vx'] as double);
      p['y'] = (p['y'] as double) + (p['vy'] as double);
      p['alpha'] = (p['alpha'] as double) - 5;
    }
    particles.removeWhere((p) => (p['alpha'] as double) <= 0);
  }

  Rect getRect() {
    if (isDucking) {
      return Rect.fromLTWH(x + 8, y + 15, width - 16, height - 15);
    }
    return Rect.fromLTWH(x + 8, y + 8, width - 16, height - 12);
  }

  ui.Image? get _currentSprite {
    if (_sprites.isEmpty) return null;
    if (isDead) return _sprites['hurt'] ?? _sprites['idle'];
    if (isDucking) return _sprites['duck'] ?? _sprites['idle'];
    if (isJumping) return _sprites['jump'] ?? _sprites['idle'];
    final frameIndex = (runFrame % 3).floor();
    return _sprites['run$frameIndex'] ?? _sprites['run0'] ?? _sprites['idle'];
  }

  // =============================================
  // ✅ رسم التاج فوق الـ Sprite
  // =============================================
  void _drawCrownAboveSprite(Canvas canvas, Rect spriteRect) {
    final crownColorHex = characterData['crownColor'] as String? ?? '#FFD700';
    final crownColor = _parseHex(crownColorHex);

    // ✅ مكان التاج (فوق الرأس مباشرة)
    final crownCx = spriteRect.center.dx;
    final crownBaseY = spriteRect.top + spriteRect.height * 0.15;
    final crownW = spriteRect.width * 0.5;
    final crownH = spriteRect.height * 0.2;

    final crownPaint = Paint()..color = crownColor;

    // ✅ قاعدة التاج
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          crownCx - crownW / 2,
          crownBaseY - crownH * 0.15,
          crownW,
          crownH * 0.25,
        ),
        const Radius.circular(2),
      ),
      crownPaint,
    );

    // ✅ 3 قمم للتاج
    for (int i = -1; i <= 1; i++) {
      final peakX = crownCx + i * crownW * 0.32;
      final path = Path()
        ..moveTo(peakX - crownW * 0.13, crownBaseY - crownH * 0.1)
        ..lineTo(peakX, crownBaseY - crownH)
        ..lineTo(peakX + crownW * 0.13, crownBaseY - crownH * 0.1)
        ..close();
      canvas.drawPath(path, crownPaint);
    }

    // ✅ جواهر على القمم
    final gemColors = [
      const Color(0xFFFF1744),
      const Color(0xFF29B6F6),
      const Color(0xFF00E676),
    ];
    final gemPaint = Paint();
    for (int i = -1; i <= 1; i++) {
      gemPaint.color = gemColors[i + 1];
      canvas.drawCircle(
        Offset(crownCx + i * crownW * 0.32, crownBaseY - crownH * 0.95),
        crownH * 0.12,
        gemPaint,
      );
    }
  }

  // =============================================
  // ✅ الرسم
  // =============================================

  void draw(Canvas canvas) {
    // ✅ Trail
    for (final p in trail) {
      final alpha = (p['alpha'] as double);
      if (alpha <= 0) continue;
      _trailPaint.color = skinTintColor.withValues(
        alpha: (alpha * 0.3 / 255).clamp(0.0, 1.0),
      );
      final size = GameConstants.playerWidth * 0.7 * (alpha / 200);
      canvas.drawOval(
        Rect.fromLTWH(p['x'] as double, p['y'] as double, size, size),
        _trailPaint,
      );
    }

    // ✅ Particles
    for (final p in particles) {
      final alpha = (p['alpha'] as double);
      _particlePaint.color = (p['color'] as Color).withValues(
        alpha: (alpha / 255).clamp(0.0, 1.0),
      );
      canvas.drawCircle(
        Offset(p['x'] as double, p['y'] as double),
        p['size'] as double,
        _particlePaint,
      );
    }

    // ✅ Squash & Stretch
    final actualWidth = width * squash;
    final actualHeight = height * (2 - squash);
    final offsetX = (width - actualWidth) / 2;
    final offsetY = height - actualHeight;
    final drawRect = Rect.fromLTWH(
      x + offsetX,
      y + offsetY,
      actualWidth,
      actualHeight,
    );

    // ✅ Glow
    if (skinData['glow'] == true) {
      final pulse = (math.sin(glowPhase) + 1) / 2;
      for (int i = 4; i >= 1; i--) {
        _glowPaint.color = skinTintColor.withValues(
          alpha: ((20 + 30 * pulse) * (5 - i) / 4 / 255).clamp(0.0, 1.0),
        );
        final offset = i * 3.0;
        canvas.drawOval(
          Rect.fromLTWH(
            drawRect.left - offset,
            drawRect.top - offset,
            drawRect.width + offset * 2,
            drawRect.height + offset * 2,
          ),
          _glowPaint,
        );
      }
    }

    // =============================================
    // ✅ رسم الشخصية
    // =============================================

    if (_image != null) {
      // --- نمط 1: صورة PNG ---
      if (isJumping) {
        canvas.save();
        canvas.translate(drawRect.center.dx, drawRect.center.dy);
        canvas.rotate(math.sin(jumpPhase) * 0.15);
        canvas.translate(-drawRect.center.dx, -drawRect.center.dy);
        canvas.drawImageRect(
          _image!,
          Rect.fromLTWH(
              0, 0, _image!.width.toDouble(), _image!.height.toDouble()),
          drawRect,
          _imagePaint,
        );
        canvas.restore();
      } else {
        canvas.drawImageRect(
          _image!,
          Rect.fromLTWH(
              0, 0, _image!.width.toDouble(), _image!.height.toDouble()),
          drawRect,
          _imagePaint,
        );
      }
    } else if (_currentSprite != null) {
      // --- نمط 2: Sprite ---
      final img = _currentSprite!;
      final imgAspect = img.width / img.height;
      final drawHeight = height * _spriteScale;
      final drawWidth = drawHeight * imgAspect;
      final spriteRect = Rect.fromLTWH(
        x + (width - drawWidth) / 2,
        y + height - drawHeight,
        drawWidth,
        drawHeight,
      );
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        spriteRect,
        _imagePaint,
      );

      // ✅ إضافة تاج فوق الـ Sprite (لو الشخصية ملكية)
      if (characterData['hasCrown'] == true) {
        _drawCrownAboveSprite(canvas, spriteRect);
      }
    } else if (_rig != null) {
      // --- نمط 3: Rig ---
      _rig!.draw(canvas, drawRect, primaryColor, secondaryColor, skinColor);
    } else if (!_imageLoading) {
      // --- Fallback ---
      final fallbackPaint = Paint()..color = primaryColor;
      canvas.drawOval(drawRect, fallbackPaint);
    }
  }
}
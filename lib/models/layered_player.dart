import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../services/customization_catalog.dart';

class LayeredPlayer {
  // ✅ الفيزياء
  double x = GameConstants.playerX;
  double y;
  double groundY;
  double width = GameConstants.playerWidth;
  double height = GameConstants.playerHeight;

  double velocityY = 0;
  bool isJumping = false;
  bool isDucking = false;
  bool isDead = false;

  // ✅ الأنيميشن
  double runFrame = 0;
  double jumpPhase = 0;
  double squash = 1.0;

  // ✅ الهوية
  String skinId;
  String hairId;
  String shirtId;
  String pantsId;
  String shoesId;
  String vehicleId;

  // ✅ صور أجزاء الجسم
  ui.Image? _headImage;
  ui.Image? _neckImage;
  ui.Image? _armImage;
  ui.Image? _handImage;
  ui.Image? _legImage;

  // ✅ صور الطبقات الأخرى
  ui.Image? _hairImage;
  ui.Image? _shirtImage;
  ui.Image? _pantsImage;
  ui.Image? _shoesImage;
  ui.Image? _vehicleImage;

  final Paint _paint = Paint()..filterQuality = FilterQuality.medium;

  LayeredPlayer({
    required this.groundY,
    this.skinId = 'skin_tint1',
    this.hairId = 'hair_black_man1',
    this.shirtId = 'shirt_blue_long',
    this.pantsId = 'pants_blue1',
    this.shoesId = 'shoes_black',
    this.vehicleId = 'vehicle_none',
  }) : y = groundY - GameConstants.playerHeight {
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadBody(),
      _loadHair(),
      _loadShirt(),
      _loadPants(),
      _loadShoes(),
      _loadVehicle(),
    ]);
  }

  Future<ui.Image?> _loadImage(String path) async {
    if (path.isEmpty) return null;
    try {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      debugPrint('❌ Error loading: $path');
      return null;
    }
  }

  Future<void> _loadBody() async {
    final data = CustomizationCatalog.skins[skinId];
    if (data == null) return;
    final folder = data['folder'] as String;
    final prefix = data['prefix'] as String;
    final basePath = 'assets/images/characters/modular/Skin/$folder/';

    _headImage = await _loadImage('$basePath${prefix}_head.png');
    _neckImage = await _loadImage('$basePath${prefix}_neck.png');
    _armImage = await _loadImage('$basePath${prefix}_arm.png');
    _handImage = await _loadImage('$basePath${prefix}_hand.png');
    _legImage = await _loadImage('$basePath${prefix}_leg.png');
  }

  Future<void> _loadHair() async {
    final data = CustomizationCatalog.hair[hairId];
    if (data == null) return;
    _hairImage = await _loadImage(data['path'] as String);
  }

  Future<void> _loadShirt() async {
    final data = CustomizationCatalog.shirts[shirtId];
    if (data == null) return;
    _shirtImage = await _loadImage(data['shirtPath'] as String);
  }

  Future<void> _loadPants() async {
    final data = CustomizationCatalog.pants[pantsId];
    if (data == null) return;
    _pantsImage = await _loadImage(data['path'] as String);
  }

  Future<void> _loadShoes() async {
    final data = CustomizationCatalog.shoes[shoesId];
    if (data == null) return;
    _shoesImage = await _loadImage(data['path'] as String);
  }

  Future<void> _loadVehicle() async {
    final data = CustomizationCatalog.vehicles[vehicleId];
    if (data == null) return;
    _vehicleImage = await _loadImage(data['path'] as String);
  }

  void setSkin(String id) { skinId = id; _loadBody(); }
  void setHair(String id) { hairId = id; _loadHair(); }
  void setShirt(String id) { shirtId = id; _loadShirt(); }
  void setPants(String id) { pantsId = id; _loadPants(); }
  void setShoes(String id) { shoesId = id; _loadShoes(); }
  void setVehicle(String id) { vehicleId = id; _loadVehicle(); }

  void update() {
    if (isDead) return;

    velocityY += GameConstants.gravity;
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
  }

  void jump() {
    if (!isJumping && !isDucking && !isDead) {
      isJumping = true;
      velocityY = GameConstants.jumpForce;
      squash = 1.3;
      jumpPhase = 0;
    }
  }

  void duck(bool value) {
    if (!isJumping && !isDead) {
      isDucking = value;
      height = value ? GameConstants.playerHeight * 0.6 : GameConstants.playerHeight;
    }
  }

  Rect getRect() {
    if (isDucking) {
      return Rect.fromLTWH(x + 8, y + 15, width - 16, height - 15);
    }
    return Rect.fromLTWH(x + 8, y + 8, width - 16, height - 12);
  }

  void draw(Canvas canvas) {
    final actualWidth = width * squash;
    final actualHeight = height * (2 - squash);
    final offsetX = (width - actualWidth) / 2;
    final offsetY = height - actualHeight;
    final drawRect = Rect.fromLTWH(x + offsetX, y + offsetY, actualWidth, actualHeight);

    // ✅ المركبة (تحت)
    if (_vehicleImage != null) {
      final vehicleRect = Rect.fromLTWH(
        drawRect.left - 20,
        drawRect.top + drawRect.height * 0.55,
        drawRect.width * 1.5,
        drawRect.height * 0.6,
      );
      canvas.drawImageRect(
        _vehicleImage!,
        Rect.fromLTWH(0, 0, _vehicleImage!.width.toDouble(), _vehicleImage!.height.toDouble()),
        vehicleRect,
        _paint,
      );
    }

    // ✅ 1. الرجل (تحت)
    if (_legImage != null) {
      final legRect = Rect.fromLTWH(
        drawRect.left + drawRect.width * 0.3,
        drawRect.top + drawRect.height * 0.55,
        drawRect.width * 0.4,
        drawRect.height * 0.45,
      );
      canvas.drawImageRect(
        _legImage!,
        Rect.fromLTWH(0, 0, _legImage!.width.toDouble(), _legImage!.height.toDouble()),
        legRect,
        _paint,
      );
    }

    // ✅ 2. البنطلون (فوق الرجل)
    if (_pantsImage != null) {
      final pantsRect = Rect.fromLTWH(
        drawRect.left + drawRect.width * 0.25,
        drawRect.top + drawRect.height * 0.5,
        drawRect.width * 0.5,
        drawRect.height * 0.4,
      );
      canvas.drawImageRect(
        _pantsImage!,
        Rect.fromLTWH(0, 0, _pantsImage!.width.toDouble(), _pantsImage!.height.toDouble()),
        pantsRect,
        _paint,
      );
    }

    // ✅ 3. الحذاء (تحت)
    if (_shoesImage != null) {
      final shoesRect = Rect.fromLTWH(
        drawRect.left + drawRect.width * 0.3,
        drawRect.top + drawRect.height * 0.85,
        drawRect.width * 0.4,
        drawRect.height * 0.15,
      );
      canvas.drawImageRect(
        _shoesImage!,
        Rect.fromLTWH(0, 0, _shoesImage!.width.toDouble(), _shoesImage!.height.toDouble()),
        shoesRect,
        _paint,
      );
    }

    // ✅ 4. الذراع (خلف القميص)
    if (_armImage != null) {
      final armRect = Rect.fromLTWH(
        drawRect.left + drawRect.width * 0.1,
        drawRect.top + drawRect.height * 0.35,
        drawRect.width * 0.2,
        drawRect.height * 0.35,
      );
      canvas.drawImageRect(
        _armImage!,
        Rect.fromLTWH(0, 0, _armImage!.width.toDouble(), _armImage!.height.toDouble()),
        armRect,
        _paint,
      );
    }

    // ✅ 5. القميص (فوق الذراع)
    if (_shirtImage != null) {
      final shirtRect = Rect.fromLTWH(
        drawRect.left + drawRect.width * 0.2,
        drawRect.top + drawRect.height * 0.35,
        drawRect.width * 0.6,
        drawRect.height * 0.3,
      );
      canvas.drawImageRect(
        _shirtImage!,
        Rect.fromLTWH(0, 0, _shirtImage!.width.toDouble(), _shirtImage!.height.toDouble()),
        shirtRect,
        _paint,
      );
    }

    // ✅ 6. الرقبة
    if (_neckImage != null) {
      final neckRect = Rect.fromLTWH(
        drawRect.left + drawRect.width * 0.4,
        drawRect.top + drawRect.height * 0.28,
        drawRect.width * 0.2,
        drawRect.height * 0.1,
      );
      canvas.drawImageRect(
        _neckImage!,
        Rect.fromLTWH(0, 0, _neckImage!.width.toDouble(), _neckImage!.height.toDouble()),
        neckRect,
        _paint,
      );
    }

    // ✅ 7. اليد
    if (_handImage != null) {
      final handRect = Rect.fromLTWH(
        drawRect.left + drawRect.width * 0.05,
        drawRect.top + drawRect.height * 0.6,
        drawRect.width * 0.15,
        drawRect.height * 0.1,
      );
      canvas.drawImageRect(
        _handImage!,
        Rect.fromLTWH(0, 0, _handImage!.width.toDouble(), _handImage!.height.toDouble()),
        handRect,
        _paint,
      );
    }

    // ✅ 8. الرأس (فوق)
    if (_headImage != null) {
      final headRect = Rect.fromLTWH(
        drawRect.left + drawRect.width * 0.25,
        drawRect.top,
        drawRect.width * 0.5,
        drawRect.height * 0.3,
      );
      canvas.drawImageRect(
        _headImage!,
        Rect.fromLTWH(0, 0, _headImage!.width.toDouble(), _headImage!.height.toDouble()),
        headRect,
        _paint,
      );
    } else {
      // Fallback
      canvas.drawOval(drawRect, Paint()..color = Colors.brown);
    }

    // ✅ 9. الشعر (فوق الرأس)
    if (_hairImage != null) {
      final hairRect = Rect.fromLTWH(
        drawRect.left + drawRect.width * 0.2,
        drawRect.top - drawRect.height * 0.05,
        drawRect.width * 0.6,
        drawRect.height * 0.25,
      );
      canvas.drawImageRect(
        _hairImage!,
        Rect.fromLTWH(0, 0, _hairImage!.width.toDouble(), _hairImage!.height.toDouble()),
        hairRect,
        _paint,
      );
    }
  }
}
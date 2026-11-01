import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/shop_catalog.dart';
import '../services/score_service.dart';
import '../services/sound_service.dart';
import 'player.dart';
import 'obstacle.dart';
import 'particle.dart';
import 'bullet.dart';
import 'power_up.dart';
import 'cloud.dart';
import 'ground_feature.dart';
import 'zombie.dart';

enum GameStatus { idle, running, paused, gameOver }

class GameState extends ChangeNotifier {
  // =============================================
  // ✅ الحالة العامة
  // =============================================
  GameStatus status = GameStatus.idle;
  double score = 0.0;
  int highScore = 0;
  int elapsedFrames = 0;
  int difficulty = 1;
  double gameSpeed = 8.0;
  double maxSpeed = 22.0;
  double speedIncrement = 0.15;
  int speedIncrementTimer = 0;

  // =============================================
  // ✅ الكائنات
  // =============================================
  Player? player;
  List<Obstacle> obstacles = [];
  List<Cloud> clouds = [];
  List<Star> stars = [];
  List<GroundFeature> groundFeatures = [];
  List<PowerUp> powerUps = [];
  List<Zombie> zombies = [];
  List<Bullet> bullets = [];
  ParticleSystem particleSystem = ParticleSystem();

  // =============================================
  // ✅ المؤقتات
  // =============================================
  int spawnTimer = 0;
  double nextSpawnDistance = 400;
  int groundFeatureTimer = 0;
  double nextGroundFeatureDistance = 1500;
  int powerUpTimer = 0;
  double nextPowerUpDistance = 1500;
  int zombieTimer = 0;
  double nextZombieDistance = 2000;

  // =============================================
  // ✅ القوى النشطة
  // =============================================
  final Map<String, int> activePowerUps = {
    'speed': 0,
    'shield': 0,
    'coin_magnet': 0,
    'double_coins': 0,
    'slow_motion': 0,
  };

  // =============================================
  // ✅ دورة الليل/النهار
  // =============================================
  bool isNight = false;
  double dayNightPhase = 0;
  int dayNightTarget = 0;

  // =============================================
  // ✅ إحصائيات الجلسة
  // =============================================
  int killsThisGame = 0;
  int bulletsFiredThisGame = 0;
  bool isNewHighScore = false;
  List<String> newAchievements = [];

  // =============================================
  // ✅ المظهر المُجهز
  // =============================================
  String currentCharacter = 'char_default';
  String currentSkin = 'skin_classic';
  String currentWorld = 'world_normal';
  String currentBackground = 'bg_day';
  String currentParticles = 'particles_none';
  String currentBadge = 'badge_rookie';
  String equippedWeapon = 'weapon_none';
  String currentSounds = 'sounds_default';

  // =============================================
  // ✅ التصويب
  // =============================================
  double aimAngle = 0;
  int lastShotTime = 0;

  // =============================================
  // ✅ الأبعاد
  // =============================================
  Size screenSize = Size.zero;
  double groundY = 0;

  // =============================================
  // ✅ الخدمات
  // =============================================
  final ScoreService scoreService;
  final SoundService soundService;
  final VoidCallback? onGameOverCallback;

  int _lastMilestone = 0;

  GameState({
    required this.scoreService,
    required this.soundService,
    this.onGameOverCallback,
  }) {
    highScore = scoreService.highScore;
    _loadEquipped();
  }

  // =============================================
  // ✅ تحميل العناصر المُجهزة
  // =============================================
  void _loadEquipped() {
    final eq = scoreService.equippedItems;
    currentCharacter = eq['character'] ?? 'char_default';
    currentSkin = eq['skin'] ?? 'skin_classic';
    currentWorld = eq['world'] ?? 'world_normal';
    currentBackground = eq['background'] ?? 'bg_day';
    currentParticles = eq['particles'] ?? 'particles_none';
    currentBadge = eq['badge'] ?? 'badge_rookie';
    equippedWeapon = eq['weapons'] ?? 'weapon_none';
    currentSounds = eq['sounds'] ?? 'sounds_default';

    // ✅ تطبيق العالم (الخلفية + الأعداء + الأصوات + المؤثرات)
    _applyWorldData();

    particleSystem.setEffect(currentParticles);
    soundService.setPack(currentSounds);
  }

  // =============================================
  // ✅ تطبيق بيانات العالم
  // =============================================
  void _applyWorldData() {
    final worldData = ShopCatalog.worlds[currentWorld];
    if (worldData == null) return;

    // ✅ تطبيق الخلفية والأعداء والأصوات والمؤثرات من العالم
    currentBackground =
        worldData['background'] as String? ?? 'bg_day';
    currentParticles =
        worldData['particles'] as String? ?? 'particles_none';
    currentSounds =
        worldData['sounds'] as String? ?? 'sounds_default';
  }

  // =============================================
  // ✅ تطبيق إعدادات العالم على اللاعب
  // =============================================
  void _applyWorldToPlayer() {
    if (player == null) return;
    final worldData = ShopCatalog.worlds[currentWorld];
    if (worldData == null) return;

    player!.gravityMultiplier =
        (worldData['gravityMultiplier'] as num?)?.toDouble() ?? 1.0;
    player!.jumpMultiplier =
        (worldData['jumpMultiplier'] as num?)?.toDouble() ?? 1.0;
  }

  void refreshEquipped() {
    _loadEquipped();
    if (player != null) {
      player!.setCharacter(currentCharacter);
      player!.setSkin(currentSkin);
      _applyWorldToPlayer();
    }
    notifyListeners();
  }

  void setScreenSize(Size size) {
    if (screenSize == size) return;
    screenSize = size;
    groundY = size.height * GameConstants.groundRatio;
    if (player == null) {
      _initScene();
    } else {
      player!.groundY = groundY;
    }
    notifyListeners();
  }

  void _initScene() {
    player = Player(
      groundY: groundY,
      characterId: currentCharacter,
      skinId: currentSkin,
    );
    _applyWorldToPlayer();
    _initBackground();
  }

  void _initBackground() {
    clouds.clear();
    stars.clear();
    final w = screenSize.width;
    final rnd = math.Random();
    for (int i = 0; i < 5; i++) {
      clouds.add(Cloud(
        x: rnd.nextDouble() * w,
        y: 20 + rnd.nextDouble() * 80,
        size: 40 + rnd.nextDouble() * 30,
        speed: 0.2 + rnd.nextDouble() * 0.3,
      ));
    }
    for (int i = 0; i < 30; i++) {
      stars.add(Star(
        x: rnd.nextDouble() * w,
        y: 10 + rnd.nextDouble() * 190,
        size: 2 + rnd.nextDouble() * 2,
      ));
    }
  }

  int _calculateDifficulty() {
    final hs = scoreService.highScore;
    if (hs < 20) return 1;
    if (hs < 50) return 2;
    if (hs < 100) return 3;
    if (hs < 200) return 4;
    return 5;
  }

  Map<String, dynamic> get _difficultySettings =>
      GameConstants.difficultySettings[difficulty]!;

  // =============================================
  // ✅ إدارة اللعبة
  // =============================================

  void startGame() {
    difficulty = _calculateDifficulty();
    final settings = _difficultySettings;

    status = GameStatus.running;
    score = 0;
    elapsedFrames = 0;
    gameSpeed = settings['initialSpeed'] as double;
    maxSpeed = settings['maxSpeed'] as double;
    speedIncrement = settings['speedIncrement'] as double;
    speedIncrementTimer = 0;

    // ✅ تطبيق سرعة العالم
    final worldData = ShopCatalog.worlds[currentWorld];
    if (worldData != null) {
      final speedMult =
          (worldData['speedMultiplier'] as num?)?.toDouble() ?? 1.0;
      gameSpeed *= speedMult;
      maxSpeed *= speedMult;
    }

    // ✅ تطبيق بيانات العالم (خلفية + أعداء + أصوات + مؤثرات)
    _applyWorldData();

    obstacles.clear();
    groundFeatures.clear();
    bullets.clear();
    powerUps.clear();
    zombies.clear();
    groundFeatureTimer = 0;
    nextGroundFeatureDistance = (settings['groundFeatureMin'] as num).toDouble();
    aimAngle = 0;
    lastShotTime = 0;
    killsThisGame = 0;
    bulletsFiredThisGame = 0;
    powerUpTimer = 0;
    nextPowerUpDistance = 1500;
    zombieTimer = 0;
    nextZombieDistance = 2000;
    spawnTimer = 0;
    nextSpawnDistance = 400;
    isNewHighScore = false;
    newAchievements = [];
    _lastMilestone = 0;

    for (final key in activePowerUps.keys) {
      activePowerUps[key] = 0;
    }

    player = Player(
      groundY: groundY,
      characterId: currentCharacter,
      skinId: currentSkin,
    );

    // ✅ تطبيق إعدادات العالم على اللاعب
    _applyWorldToPlayer();

    dayNightTarget = 0;
    dayNightPhase = 0;
    isNight = false;

    soundService.play('click');
    notifyListeners();
  }

  void pauseGame() {
    if (status != GameStatus.running) return;
    status = GameStatus.paused;
    soundService.play('pause');
    notifyListeners();
  }

  void resumeGame() {
    if (status != GameStatus.paused) return;
    status = GameStatus.running;
    soundService.play('resume');
    notifyListeners();
  }

  void gameOver() {
    if (player != null) {
      player!.isDead = true;
    }
    status = GameStatus.gameOver;

    isNewHighScore = scoreService.isHighScore(score.toInt());
    scoreService.addScore(score.toInt());
    highScore = scoreService.highScore;

    scoreService.updateBestKills(killsThisGame);
    scoreService.addDeath();
    scoreService.addPlayTime(score.toInt());

    newAchievements = [];
    _checkAchievementsAsync();

    soundService.play('game_over');
    if (isNewHighScore) {
      Future.delayed(const Duration(milliseconds: 700), () {
        soundService.play('new_high_score');
      });
    }

    onGameOverCallback?.call();
    notifyListeners();
  }

  Future<void> _checkAchievementsAsync() async {
    final badges = await scoreService.checkAchievements();
    final ach = await scoreService.checkWeaponAchievements();
    newAchievements = [...badges, ...ach];
    notifyListeners();
  }

  void playerJump() {
    if (status == GameStatus.running) {
      player?.jump();
      soundService.play('jump');
    }
  }

  void playerDuck(bool value) {
    if (status == GameStatus.running) {
      final wasDucking = player?.isDucking ?? false;
      player?.duck(value);
      if (value && !wasDucking) {
        soundService.play('duck');
      }
    }
  }

  void shoot() {
    if (status != GameStatus.running) return;
    if (equippedWeapon == 'weapon_none') return;

    final weaponData = ShopCatalog.weapons[equippedWeapon];
    if (weaponData == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final fireRate = weaponData['fireRate'] as int;
    if (now - lastShotTime < fireRate) return;
    lastShotTime = now;

    final damage = weaponData['damage'] as int;
    final colorHex = weaponData['bulletColor'] as String? ?? '#ffff00';
    final color =
        Color(int.parse('FF${colorHex.replaceFirst('#', '')}', radix: 16));
    final speed = (weaponData['bulletSpeed'] as num).toDouble();
    final spread = (weaponData['spread'] as int?) ?? 1;

    final p = player!;
    final bx = p.x + p.width;
    final by = p.y + p.height / 2;
    final angleRad = aimAngle * math.pi / 180;

    int created = 0;
    if (spread > 1) {
      for (int i = 0; i < spread; i++) {
        final offsetDeg = (i - spread ~/ 2) * 5;
        final offsetRad = offsetDeg * math.pi / 180 + angleRad;
        bullets.add(Bullet(
          x: bx,
          y: by,
          vx: speed * math.cos(offsetRad),
          vy: speed * math.sin(offsetRad),
          damage: damage,
          color: color,
          size: 6,
        ));
        created++;
      }
    } else {
      bullets.add(Bullet(
        x: bx,
        y: by,
        vx: speed * math.cos(angleRad),
        vy: speed * math.sin(angleRad),
        damage: damage,
        color: color,
        size: 8,
        explosion: weaponData['explosion'] == true,
      ));
      created = 1;
    }

    bulletsFiredThisGame += created;
    scoreService.addBulletFired(count: created);
    soundService.play('click');
    p.squash = 0.9;
  }

  void aimUp() {
    if (status == GameStatus.running) {
      aimAngle = math.max(-45, aimAngle - 5);
    }
  }

  void aimDown() {
    if (status == GameStatus.running) {
      aimAngle = math.min(45, aimAngle + 5);
    }
  }

  void _spawnExplosion(double cx, double cy) {
    final rnd = math.Random();
    for (int i = 0; i < 20; i++) {
      particleSystem.particles.add(Particle(
        x: cx,
        y: cy,
        vx: rnd.nextDouble() * 10 - 5,
        vy: rnd.nextDouble() * 10 - 5,
        size: 4 + rnd.nextDouble() * 4,
        color: Color(int.parse(
            'FFFF${['0000', '6600', 'AA00', 'FF00'][rnd.nextInt(4)]}',
            radix: 16)),
        lifetime: 30,
        gravity: 0.2,
      ));
    }
  }

  void _spawnHitEffect(double cx, double cy) {
    final rnd = math.Random();
    for (int i = 0; i < 5; i++) {
      particleSystem.particles.add(Particle(
        x: cx,
        y: cy,
        vx: rnd.nextDouble() * 4 - 2,
        vy: rnd.nextDouble() * 4 - 2,
        size: 2 + rnd.nextDouble() * 2,
        color: const Color(0xFFFFFF00),
        lifetime: 15,
        gravity: 0.1,
      ));
    }
  }

  void _activatePowerUp(String type) {
    final data = PowerUp.types[type];
    if (data == null) return;
    activePowerUps[type] = data['duration'] as int;
  }

  bool _hasShield() => (activePowerUps['shield'] ?? 0) > 0;

  int _coinMultiplier() => (activePowerUps['double_coins'] ?? 0) > 0 ? 2 : 1;

  // =============================================
  // ✅ تحديث اللعبة (كل frame)
  // =============================================

  void update(double dt) {
    if (status != GameStatus.running) return;

    // ✅ تحديث اللاعب
    player?.update();
    if (player != null) {
      player!.groundY = groundY;
    }

    // ✅ تحديث العقبات
    for (final o in obstacles) {
      o.update(gameSpeed);
    }
    obstacles.removeWhere((o) => o.isOffscreen());

    // ✅ تحديث الحفر والمطبات
    for (final f in groundFeatures) {
      f.update(gameSpeed);
    }
    groundFeatures.removeWhere((f) => f.isOffscreen());

    // ✅ تحديث الرصاص
    for (final b in bullets) {
      b.update();
    }
    bullets.removeWhere((b) => b.isDead);

    // ✅ تصادم الرصاص مع العقبات
    for (final b in List<Bullet>.from(bullets)) {
      for (final o in List<Obstacle>.from(obstacles)) {
        if (b.getRect().overlaps(o.getRect())) {
          bullets.remove(b);
          o.health -= b.damage;
          if (o.health <= 0) {
            obstacles.remove(o);
            _spawnExplosion(o.x + o.width / 2, o.y + o.height / 2);
            killsThisGame++;
            scoreService.addKill();
            final coins = 10 * _coinMultiplier();
            scoreService.addCoins(coins);
            soundService.play('score');
          } else {
            _spawnHitEffect(o.x + o.width / 2, o.y + o.height / 2);
          }
          break;
        }
      }
    }

    // ✅ تصادم الرصاص مع الزومبي
    for (final b in List<Bullet>.from(bullets)) {
      for (final z in List<Zombie>.from(zombies)) {
        if (b.getRect().overlaps(z.getRect())) {
          bullets.remove(b);
          if (z.takeDamage(b.damage)) {
            zombies.remove(z);
            _spawnExplosion(z.x + z.width / 2, z.y + z.height / 2);
            killsThisGame++;
            scoreService.addKill();
            final coins = 15 * _coinMultiplier();
            scoreService.addCoins(coins);
            soundService.play('score');
          }
          break;
        }
      }
    }

    // ✅ تحديث Power-ups
    for (final p in powerUps) {
      p.update(gameSpeed);
    }
    powerUps.removeWhere((p) => p.isOffscreen());

    // ✅ التقاط Power-ups
    if (player != null) {
      final pr = player!.getRect();
      for (final p in List<PowerUp>.from(powerUps)) {
        if (pr.overlaps(p.getRect())) {
          _activatePowerUp(p.type);
          powerUps.remove(p);
          soundService.play('score');
        }
      }
    }

    // ✅ توليد Power-ups
    powerUpTimer += gameSpeed.round();
    if (powerUpTimer >= nextPowerUpDistance) {
      powerUpTimer = 0;
      nextPowerUpDistance = (1000 + math.Random().nextInt(1000)).toDouble();
      final types = PowerUp.types.keys.toList();
      final type = types[math.Random().nextInt(types.length)];
      final py = groundY - (80 + math.Random().nextInt(70));
      powerUps.add(PowerUp(x: screenSize.width + 20, y: py, type: type));
    }

    // ✅ تنقيص مدة القوى النشطة
    for (final key in activePowerUps.keys.toList()) {
      if (activePowerUps[key]! > 0) {
        activePowerUps[key] = activePowerUps[key]! - 1;
      }
    }

    // ✅ تحديث الزومبي
    for (final z in zombies) {
      z.update(gameSpeed);
    }
    zombies.removeWhere((z) => z.isOffscreen());

    // ✅ توليد الزومبي
    final zombieChance = _difficultySettings['zombieChance'] as double;
    if (zombieChance > 0) {
      zombieTimer += gameSpeed.round();
      if (zombieTimer >= nextZombieDistance) {
        zombieTimer = 0;
        nextZombieDistance = (1500 + math.Random().nextInt(1500)).toDouble();
        if (math.Random().nextDouble() < zombieChance) {
          final types = Zombie.types.keys.toList();
          final type = types[math.Random().nextInt(types.length)];
          zombies.add(Zombie(
            x: screenSize.width + 20,
            groundY: groundY,
            type: type,
          ));
        }
      }
    }

    // ✅ تصادم الزومبي مع اللاعب
    if (player != null) {
      final pr = player!.getRect();
      for (final z in zombies) {
        if (pr.overlaps(z.getRect()) && !_hasShield()) {
          gameOver();
          return;
        }
      }
    }

    // ✅ توليد الحفر والمطبات
    groundFeatureTimer += gameSpeed.round();
    if (groundFeatureTimer >= nextGroundFeatureDistance) {
      groundFeatureTimer = 0;
      final minD = _difficultySettings['groundFeatureMin'] as num;
      final maxD = _difficultySettings['groundFeatureMax'] as num;
      nextGroundFeatureDistance =
          (minD.toDouble() + math.Random().nextDouble() * (maxD - minD))
              .toDouble();

      final gapChance = _difficultySettings['gapChance'] as double;
      final bumpChance = _difficultySettings['bumpChance'] as double;
      final rand = math.Random().nextDouble();

      String? featureType;
      if (rand < gapChance) {
        featureType = 'gap';
      } else if (rand < gapChance + bumpChance) {
        featureType = 'bump';
      }

      if (featureType != null) {
        groundFeatures.add(GroundFeature(
          x: screenSize.width + 20,
          groundY: groundY,
          featureType: featureType,
        ));
      }
    }

    // ✅ تحديث السحاب
    for (final c in clouds) {
      c.update(gameSpeed);
    }
    clouds.removeWhere((c) => c.isOffscreen());
    if (clouds.length < 5) {
      final rnd = math.Random();
      clouds.add(Cloud(
        x: screenSize.width + 50 + rnd.nextDouble() * 150,
        y: 20 + rnd.nextDouble() * 80,
        size: 40 + rnd.nextDouble() * 30,
        speed: 0.2 + rnd.nextDouble() * 0.3,
      ));
    }

    // ✅ رجع التصويب للصفر تدريجياً
    if (aimAngle > 0) {
      aimAngle = math.max(0, aimAngle - 1);
    } else if (aimAngle < 0) {
      aimAngle = math.min(0, aimAngle + 1);
    }

    // ✅ تحديث النجوم
    for (final s in stars) {
      s.update(gameSpeed);
    }
    stars.removeWhere((s) => s.isOffscreen());
    if (stars.length < 30) {
      final rnd = math.Random();
      stars.add(Star(
        x: screenSize.width + rnd.nextDouble() * 100,
        y: 10 + rnd.nextDouble() * 190,
        size: 2 + rnd.nextDouble() * 2,
      ));
    }

    // ✅ توليد العقبات (من العالم)
    spawnTimer += gameSpeed.round();
    if (spawnTimer >= nextSpawnDistance) {
      spawnTimer = 0;
      final minD = _difficultySettings['obstacleDistanceMin'] as num;
      final maxD = _difficultySettings['obstacleDistanceMax'] as num;
      nextSpawnDistance =
          (minD.toDouble() + math.Random().nextDouble() * (maxD - minD))
              .toDouble();

      // ✅ تحديد نمط الأعداء من العالم
      final worldData = ShopCatalog.worlds[currentWorld];
      final obsId = worldData?['obstacles'] as String? ?? 'obs_cactus';

      String obstacleStyle = 'cactus';
      switch (obsId) {
        case 'obs_rocks':
          obstacleStyle = 'rocks';
          break;
        case 'obs_cars':
          obstacleStyle = 'cars';
          break;
        case 'obs_drones':
          obstacleStyle = 'drones';
          break;
        case 'obs_platformer':
          obstacleStyle = 'platformer';
          break;
        case 'obs_nature':
          obstacleStyle = 'nature';
          break;
        default:
          obstacleStyle = 'cactus';
      }

      obstacles.add(Obstacle(
        x: screenSize.width + 20,
        groundY: groundY,
        scoreValue: score.toInt(),
        obstacleStyle: obstacleStyle,
      ));
    }

    // ✅ تحديث المؤثرات
    particleSystem.update(screenSize.width, screenSize.height, groundY);

    // ✅ فحص التصادم
    if (_checkCollision()) {
      gameOver();
      return;
    }

    // ✅ زيادة النقاط
    elapsedFrames++;
    score = elapsedFrames / 60.0;

    // ✅ صوت Milestone
    final intScore = score.toInt();
    if (intScore > 0 && intScore % 30 == 0 && intScore != _lastMilestone) {
      _lastMilestone = intScore;
      soundService.play('milestone');
    }

    // ✅ زيادة السرعة
    speedIncrementTimer++;
    if (speedIncrementTimer >= 200) {
      speedIncrementTimer = 0;
      if (gameSpeed < maxSpeed) {
        gameSpeed += speedIncrement * 0.5;
      }
    }

    // ✅ دورة الليل/النهار
    _updateDayNight();

    notifyListeners();
  }

  void _updateDayNight() {
    final expectedPhase = (score.toInt() ~/ 30) % 2;
    dayNightTarget = expectedPhase;
    if (dayNightPhase < dayNightTarget) {
      dayNightPhase = math.min(dayNightTarget.toDouble(), dayNightPhase + 0.02);
    } else if (dayNightPhase > dayNightTarget) {
      dayNightPhase = math.max(dayNightTarget.toDouble(), dayNightPhase - 0.02);
    }
    isNight = dayNightPhase > 0.5;
  }

  bool _checkCollision() {
    if (_hasShield()) return false;
    if (player == null) return false;
    final pr = player!.getRect();

    for (final o in obstacles) {
      if (pr.overlaps(o.getRect())) {
        return true;
      }
    }

    for (final f in groundFeatures) {
      if (f.featureType == 'gap') {
        if (player!.x + player!.width > f.x &&
            player!.x < f.x + f.width &&
            player!.y + player!.height >= f.groundY - 5) {
          return true;
        }
      }
    }

    for (final z in zombies) {
      if (pr.overlaps(z.getRect())) {
        return true;
      }
    }

    return false;
  }
}
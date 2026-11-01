import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../models/obstacle_sprite_cache.dart';
import '../widgets/game_loop.dart';
import '../services/score_service.dart';
import '../services/sound_service.dart';
import '../generated/l10n/app_localizations.dart';
import '../services/shop_catalog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;
  bool _isLandscapeSet = false;

  GameStatus _lastStatus = GameStatus.idle;
  String _lastWeapon = 'weapon_none';
  String _lastWorld = 'world_normal'; // ✅ جديد

  final FocusNode _keyboardFocusNode = FocusNode();

  Timer? _autoFireTimer;
  bool _isFiring = false;
  double _aimStartY = 0;
  double _aimStartAngle = 0;

  bool _isDucking = false;

  @override
  void initState() {
    super.initState();
    _gameState = GameState(
      scoreService: ScoreService(),
      soundService: SoundService(),
      onGameOverCallback: _onGameOver,
    );
    _lastStatus = _gameState.status;
    _lastWeapon = _gameState.equippedWeapon;
    _lastWorld = _gameState.currentWorld; // ✅
    _gameState.addListener(_onGameStateChanged);
    ObstacleSpriteCache.preload();
    _setLandscape();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
  }

  void _onGameStateChanged() {
    final newStatus = _gameState.status;
    if (newStatus != _lastStatus ||
        _gameState.equippedWeapon != _lastWeapon ||
        _gameState.currentWorld != _lastWorld) {
      _lastStatus = newStatus;
      _lastWeapon = _gameState.equippedWeapon;
      _lastWorld = _gameState.currentWorld;
      if (mounted) setState(() {});
    }
  }

  Future<void> _setLandscape() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _isLandscapeSet = true;
  }

  void _onGameOver() {
    _stopFiring();
    if (mounted) setState(() {});
  }

  void _startFiring() {
    if (_isFiring) return;
    if (_gameState.equippedWeapon == 'weapon_none') return;
    if (_gameState.status != GameStatus.running) return;

    _isFiring = true;
    HapticFeedback.lightImpact();
    _gameState.shoot();

    _autoFireTimer?.cancel();
    _autoFireTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (_gameState.status != GameStatus.running) {
        _stopFiring();
        return;
      }
      _gameState.shoot();
    });
  }

  void _stopFiring() {
    _isFiring = false;
    _autoFireTimer?.cancel();
    _autoFireTimer = null;
  }

  void _handleTouchStart(Offset localPosition, Size screenSize) {
    if (_gameState.status != GameStatus.running) {
      if (_gameState.status == GameStatus.idle ||
          _gameState.status == GameStatus.gameOver) {
        _gameState.startGame();
      } else if (_gameState.status == GameStatus.paused) {
        _gameState.resumeGame();
      }
      return;
    }

    if (localPosition.dx < screenSize.width / 2) {
      if (_gameState.equippedWeapon != 'weapon_none') {
        _aimStartY = localPosition.dy;
        _aimStartAngle = _gameState.aimAngle;
        _startFiring();
      }
    }
  }

  void _handleTouchUpdate(Offset localPosition, Size screenSize) {
    if (_gameState.status != GameStatus.running) return;

    if (_isFiring) {
      final deltaY = localPosition.dy - _aimStartY;
      final newAngle = (_aimStartAngle - deltaY * 0.3).clamp(-45.0, 45.0);
      _gameState.aimAngle = newAngle;
    }
  }

  void _handleTouchEnd() {
    if (_isFiring) {
      _stopFiring();
    }
  }

  void _handleSwipeEnd(Offset velocity, Size screenSize) {
    if (_gameState.status != GameStatus.running) return;

    if (velocity.dy > 300) {
      if (!_isDucking) {
        _isDucking = true;
        _gameState.playerDuck(true);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_isDucking) {
            _isDucking = false;
            _gameState.playerDuck(false);
          }
        });
      }
    } else if (velocity.dy < -300) {
      _gameState.playerJump();
    }
  }

  @override
  void dispose() {
    _stopFiring();
    _gameState.removeListener(_onGameStateChanged);
    _keyboardFocusNode.dispose();
    if (_isLandscapeSet) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    super.dispose();
  }

  // =============================================
  // ✅ معلومات العالم الحالي (للعرض في HUD)
  // =============================================
  String _getWorldDisplayName() {
    final worldData = ShopCatalog.worlds[_gameState.currentWorld];
    return worldData?['name'] as String? ?? 'عادي';
  }

  IconData _getWorldIcon() {
    final worldData = ShopCatalog.worlds[_gameState.currentWorld];
    final iconName = worldData?['icon'] as String? ?? 'public';
    switch (iconName) {
      case 'public': return Icons.public;
      case 'forest': return Icons.forest;
      case 'water': return Icons.water;
      case 'nights_stay': return Icons.nights_stay;
      case 'landscape': return Icons.landscape;
      case 'terrain': return Icons.terrain;
      case 'workspace_premium': return Icons.workspace_premium;
      default: return Icons.public;
    }
  }

  Color _getWorldColor() {
    final worldData = ShopCatalog.worlds[_gameState.currentWorld];
    final iconName = worldData?['icon'] as String? ?? 'public';
    switch (iconName) {
      case 'public': return const Color(0xFF4A90E2);
      case 'forest': return const Color(0xFF4CAF50);
      case 'water': return const Color(0xFF0288D1);
      case 'nights_stay': return const Color(0xFF6B21A8);
      case 'landscape': return const Color(0xFFD4A574);
      case 'terrain': return const Color(0xFF6B8E23);
      case 'workspace_premium': return const Color(0xFFFFD700);
      default: return const Color(0xFF0D6EFD);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _gameState.status == GameStatus.running) {
          _gameState.pauseGame();
        }
      },
      child: KeyboardListener(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.keyX) {
              _gameState.shoot();
            } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
              _gameState.aimUp();
            } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
              _gameState.aimDown();
            } else if (event.logicalKey == LogicalKeyboardKey.space) {
              _gameState.playerJump();
            }
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenSize = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );

            return Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                fit: StackFit.expand,
                children: [
                  // ✅ Game Canvas
                  Listener(
                    onPointerDown: (event) {
                      _handleTouchStart(event.localPosition, screenSize);
                    },
                    onPointerMove: (event) {
                      _handleTouchUpdate(event.localPosition, screenSize);
                    },
                    onPointerUp: (_) => _handleTouchEnd(),
                    onPointerCancel: (_) => _handleTouchEnd(),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (_gameState.status != GameStatus.running) {
                          if (_gameState.status == GameStatus.idle ||
                              _gameState.status == GameStatus.gameOver) {
                            _gameState.startGame();
                          } else if (_gameState.status == GameStatus.paused) {
                            _gameState.resumeGame();
                          }
                        }
                      },
                      onVerticalDragEnd: (details) {
                        final velocity = details.velocity.pixelsPerSecond;
                        _handleSwipeEnd(velocity, screenSize);
                      },
                      child: GameLoop(state: _gameState, l10n: l10n),
                    ),
                  ),

                  // ✅ Top Bar (Back, World Badge, Pause)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            _buildIconButton(
                              icon: Icons.arrow_back,
                              onTap: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: 8),

                            // ✅ مؤشر العالم الحالي
                            if (_gameState.status == GameStatus.running)
                              _buildWorldBadge(),

                            const Spacer(),
                            if (_gameState.status == GameStatus.running)
                              _buildIconButton(
                                icon: Icons.pause,
                                onTap: () => _gameState.pauseGame(),
                              ),
                            if (_gameState.status == GameStatus.paused)
                              _buildIconButton(
                                icon: Icons.play_arrow,
                                onTap: () => _gameState.resumeGame(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ✅ مؤشر الضرب
                  if (_isFiring)
                    Positioned(
                      right: 20,
                      top: 60,
                      child: SafeArea(
                        child: _FiringIndicator(text: l10n.firing),
                      ),
                    ),

                  // ✅ تعليمات اللعب
                  if (_gameState.status == GameStatus.idle ||
                      _gameState.status == GameStatus.gameOver)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Column(
                          children: [
                            Text(
                              _gameState.equippedWeapon != 'weapon_none'
                                  ? l10n.tapLeftToFire
                                  : '',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${l10n.swipeDownToDuck}  •  ${l10n.swipeUpToJump}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // =============================================
  // ✅ مؤشر العالم (Badge)
  // =============================================
  Widget _buildWorldBadge() {
    final icon = _getWorldIcon();
    final color = _getWorldColor();
    final name = _getWorldDisplayName();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.5),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

// =============================================
// ✅ مؤشر الضرب (نابض أحمر)
// =============================================
class _FiringIndicator extends StatefulWidget {
  final String text;
  const _FiringIndicator({required this.text});

  @override
  State<_FiringIndicator> createState() => _FiringIndicatorState();
}

class _FiringIndicatorState extends State<_FiringIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF3232).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFF3232)
                  .withValues(alpha: 0.5 + _controller.value * 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF3232)
                    .withValues(alpha: 0.3 * _controller.value),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: _controller.value),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
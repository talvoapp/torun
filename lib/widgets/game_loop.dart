import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/game_state.dart';
import '../generated/l10n/app_localizations.dart';
import 'game_painter.dart';

class GameLoop extends StatefulWidget {
  final GameState state;
  final AppLocalizations l10n;

  const GameLoop({super.key, required this.state, required this.l10n});

  @override
  State<GameLoop> createState() => _GameLoopState();
}

class _GameLoopState extends State<GameLoop>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dt > 0 && dt < 0.1) {
      widget.state.update(dt);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        if (size != widget.state.screenSize) {
          widget.state.setScreenSize(size);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (widget.state.status == GameStatus.idle ||
                widget.state.status == GameStatus.gameOver) {
              widget.state.startGame();
            } else if (widget.state.status == GameStatus.running) {
              widget.state.playerJump();
            } else if (widget.state.status == GameStatus.paused) {
              widget.state.resumeGame();
            }
          },
          onVerticalDragEnd: (details) {
            if (widget.state.status == GameStatus.running) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 0) {
                widget.state.playerDuck(true);
                Future.delayed(const Duration(milliseconds: 500), () {
                  widget.state.playerDuck(false);
                });
              }
            }
          },
          child: RepaintBoundary(
            child: CustomPaint(
              size: size,
              painter: GamePainter(
                state: widget.state,
                l10n: widget.l10n,
                locale: Localizations.localeOf(context).languageCode,
                repaint: widget.state,
              ),
            ),
          ),
        );
      },
    );
  }
}
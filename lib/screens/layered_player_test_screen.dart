import 'package:flutter/material.dart';
import '../models/layered_player.dart';

class LayeredPlayerTestScreen extends StatefulWidget {
  const LayeredPlayerTestScreen({super.key});

  @override
  State<LayeredPlayerTestScreen> createState() => _LayeredPlayerTestScreenState();
}

class _LayeredPlayerTestScreenState extends State<LayeredPlayerTestScreen> {
  late LayeredPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = LayeredPlayer(
      groundY: 400,
      skinId: 'skin_tint1',
      hairId: 'hair_black_man1',
      shirtId: 'shirt_blue_long',
      pantsId: 'pants_blue1',
      shoesId: 'shoes_black',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: CustomPaint(
          size: const Size(200, 500),
          painter: _PlayerPainter(_player),
        ),
      ),
    );
  }
}

class _PlayerPainter extends CustomPainter {
  final LayeredPlayer player;
  _PlayerPainter(this.player);

  @override
  void paint(Canvas canvas, Size size) {
    player.draw(canvas);
  }

  @override
  bool shouldRepaint(_PlayerPainter old) => true;
}
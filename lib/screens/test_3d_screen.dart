import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class Test3DScreen extends StatefulWidget {
  const Test3DScreen({super.key});

  @override
  State<Test3DScreen> createState() => _Test3DScreenState();
}

class _Test3DScreenState extends State<Test3DScreen> {
  final Flutter3DController _controller = Flutter3DController();
  String _selectedAnimation = 'Idle';
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    // ✅ الطريقة الصح في 1.3.1
    _controller.onModelLoaded.addListener(() {
      if (_controller.onModelLoaded.value) {
        debugPrint('✅ Model loaded!');
        if (mounted) {
          setState(() => _isLoaded = true);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('🧪 اختبار نموذج Sophia 3D'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Flutter3DViewer(
              controller: _controller,
              src: 'assets/models/sophia.glb',
              progressBarColor: const Color(0xFF0D6EFD),
              // ⚠️ في 1.3.1، onLoad و onError مش موجودين في الـ Widget
              // الاعتماد على onModelLoaded من الـ Controller
            ),
          ),

          if (!_isLoaded)
            const Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'جاري تحميل النموذج 3D...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'الحالي: $_selectedAnimation',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildAnimButton('Idle', '🧍 واقف'),
                      _buildAnimButton('Run', '🏃 جري'),
                      _buildAnimButton('Jump', '🤸 قفز'),
                      _buildAnimButton('Fall', '⬇️ سقوط'),
                      _buildAnimButton('Walk', '🚶 مشي'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _playAnimation(String animation) {
    setState(() => _selectedAnimation = animation);
    try {
      _controller.playAnimation(animationName: animation);
    } catch (e) {
      debugPrint('Animation error: $e');
    }
  }

  Widget _buildAnimButton(String animation, String label) {
    final isSelected = _selectedAnimation == animation;
    return ElevatedButton(
      onPressed: _isLoaded ? () => _playAnimation(animation) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? const Color(0xFF0D6EFD) : Colors.white24,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }
}
import 'package:flutter/material.dart';
import '../constants.dart';
import '../generated/l10n/app_localizations.dart';
import '../services/score_service.dart';
import '../services/sound_service.dart';
import 'game_screen.dart';
import 'shop_screen.dart';
import 'settings_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScoreService _scoreService = ScoreService();
  final SoundService _soundService = SoundService();

  @override
  void initState() {
    super.initState();
    _soundService.play('click');
  }

  void _startGame() {
    _soundService.play('click');
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    ).then((_) => setState(() {}));
  }

  void _openShop() {
    _soundService.play('click');
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ShopScreen()),
    ).then((_) => setState(() {}));
  }

  void _openSettings() {
    _soundService.play('click');
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    ).then((_) => setState(() {}));
  }

  void _openLeaderboard() {
    _soundService.play('click');
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
    );
  }

  // =============================================
  // ✅ تنسيق العملات (K/M)
  // =============================================
  String _formatCoins(int coins) {
    if (coins >= 1000000) {
      final m = coins / 1000000;
      return m == m.roundToDouble() ? '${m.toInt()}M' : '${m.toStringAsFixed(1)}M';
    } else if (coins >= 1000) {
      final k = coins / 1000;
      return k == k.roundToDouble() ? '${k.toInt()}K' : '${k.toStringAsFixed(1)}K';
    }
    return coins.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final coins = _scoreService.coins;
    final highScore = _scoreService.highScore;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0F28), Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ الشعار
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: GameConstants.primaryColor
                              .withValues(alpha: 0.4),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: GameConstants.primaryColor
                              .withValues(alpha: 0.2),
                          blurRadius: 80,
                          spreadRadius: 16,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ✅ العنوان
                  Text(
                    l10n.appTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Endless Runner Game',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ✅ الإحصائيات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatChip(
                        icon: Icons.monetization_on,
                        value: _formatCoins(coins),
                        color: const Color(0xFFFFC107),
                      ),
                      const SizedBox(width: 12),
                      _buildStatChip(
                        icon: Icons.emoji_events,
                        value: _formatCoins(highScore),
                        color: const Color(0xFF0D6EFD),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // ✅ زر اللعب
                  SizedBox(
                    width: double.infinity,
                    height: 72,
                    child: ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GameConstants.successColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 10,
                        shadowColor: GameConstants.successColor
                            .withValues(alpha: 0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow, size: 38),
                          const SizedBox(width: 10),
                          Text(
                            l10n.play,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ✅ الأزرار الثانوية
                  Row(
                    children: [
                      Expanded(
                        child: _buildMenuButton(
                          icon: Icons.shopping_cart,
                          label: l10n.shop,
                          color: GameConstants.primaryColor,
                          onTap: _openShop,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMenuButton(
                          icon: Icons.leaderboard,
                          label: l10n.leaderboard,
                          color: GameConstants.secondaryColor,
                          onTap: _openLeaderboard,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMenuButton(
                          icon: Icons.settings,
                          label: l10n.settings,
                          color: GameConstants.grayColor,
                          onTap: _openSettings,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '© torun 2026',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =============================================
  // ✅ Stat Chip
  // =============================================
  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // ✅ Menu Button
  // =============================================
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
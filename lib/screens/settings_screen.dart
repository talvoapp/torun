import 'package:flutter/material.dart';
import '../constants.dart';
import '../main.dart';
import '../generated/l10n/app_localizations.dart';
import '../services/score_service.dart';
import '../services/sound_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ScoreService _scoreService = ScoreService();
  final SoundService _soundService = SoundService();
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _soundEnabled = _soundService.enabled;
  }

  Future<void> _resetStats() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GameConstants.darkColor,
        title: Text(l10n.confirm,
            style: const TextStyle(color: Colors.white)),
        content: Text(
          l10n.resetStatsConfirm,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
                backgroundColor: GameConstants.dangerColor),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _scoreService.resetStats();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).statsReset),
          backgroundColor: GameConstants.successColor,
        ),
      );
    }
  }

  Future<void> _resetAll() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GameConstants.darkColor,
        title: Row(
          children: [
            const Icon(
              Icons.warning,
              color: GameConstants.dangerColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.dangerZone,
              style: const TextStyle(color: GameConstants.dangerColor),
            ),
          ],
        ),
        content: Text(
          l10n.resetAllConfirm,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
                backgroundColor: GameConstants.dangerColor),
            child: Text(l10n.deleteAll),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _scoreService.resetAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).allReset),
          backgroundColor: GameConstants.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLang =
        TorunApp.of(context)?.currentLocale.languageCode ?? 'ar';

    return Scaffold(
      backgroundColor: GameConstants.darkColor,
      appBar: AppBar(
        backgroundColor: GameConstants.darkColor,
        foregroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.settings, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              l10n.settings,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // =============================================
          // ✅ اللغة
          // =============================================
          _buildSectionTitle(
            icon: Icons.language,
            title: l10n.language,
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F3460),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildLanguageOption(
                  label: l10n.arabic,
                  code: 'ar',
                  current: currentLang,
                  icon: Icons.translate,
                ),
                const Divider(color: Colors.white24, height: 1),
                _buildLanguageOption(
                  label: l10n.english,
                  code: 'en',
                  current: currentLang,
                  icon: Icons.translate,
                ),
                const Divider(color: Colors.white24, height: 1),
                _buildLanguageOption(
                  label: l10n.french,
                  code: 'fr',
                  current: currentLang,
                  icon: Icons.translate,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // =============================================
          // ✅ الصوت
          // =============================================
          _buildSectionTitle(
            icon: Icons.volume_up,
            title: l10n.sound,
          ),
          _buildSwitchTile(
            title: l10n.soundOn,
            value: _soundEnabled,
            onChanged: (value) {
              setState(() => _soundEnabled = value);
              _soundService.setEnabled(value);
            },
          ),
          const SizedBox(height: 20),

          // =============================================
          // ✅ الإحصائيات
          // =============================================
          _buildSectionTitle(
            icon: Icons.bar_chart,
            title: l10n.gamesPlayed,
          ),
          _buildStatTile(
            icon: Icons.sports_esports,
            label: l10n.gamesPlayed,
            value: '${_scoreService.stats['total_deaths'] ?? 0}',
          ),
          _buildStatTile(
            icon: Icons.emoji_events,
            label: l10n.highScore,
            value: '${_scoreService.highScore}',
          ),
          _buildStatTile(
            icon: Icons.monetization_on,
            label: l10n.totalCoins,
            value: '${_scoreService.totalCoinsEarned}',
          ),
          const SizedBox(height: 20),

          // =============================================
          // ✅ منطقة الخطر
          // =============================================
          _buildSectionTitle(
            icon: Icons.warning,
            title: l10n.dangerZone,
          ),
          _buildDangerButton(
            icon: Icons.delete_sweep,
            label: l10n.resetStats,
            onTap: _resetStats,
          ),
          const SizedBox(height: 8),
          _buildDangerButton(
            icon: Icons.delete_forever,
            label: l10n.resetAll,
            onTap: _resetAll,
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '${l10n.version} 1.0.0',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // ✅ خيار اللغة
  // =============================================
  Widget _buildLanguageOption({
    required String label,
    required String code,
    required String current,
    required IconData icon,
  }) {
    final isSelected = current == code;

    return InkWell(
      onTap: () {
        _soundService.play('click');
        TorunApp.of(context)?.changeLanguage(code);
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? GameConstants.primaryColor
                  : Colors.white.withValues(alpha: 0.6),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color:
                      isSelected ? GameConstants.primaryColor : Colors.white,
                  fontSize: 15,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: GameConstants.successColor,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  // =============================================
  // ✅ عنوان قسم
  // =============================================
  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: GameConstants.primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: GameConstants.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // ✅ Switch Tile
  // =============================================
  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: GameConstants.primaryColor,
      ),
    );
  }

  // =============================================
  // ✅ Stat Tile (أيقونة + label + value)
  // =============================================
  Widget _buildStatTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: GameConstants.secondaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // ✅ Danger Button (أيقونة + label)
  // =============================================
  Widget _buildDangerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: GameConstants.dangerColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
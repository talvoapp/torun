import 'package:flutter/material.dart';
import '../constants.dart';
import '../generated/l10n/app_localizations.dart';
import '../services/score_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scoreService = ScoreService();
    final highScore = scoreService.highScore;
    final leaderboard = scoreService.leaderboard;

    return Scaffold(
      backgroundColor: GameConstants.darkColor,
      appBar: AppBar(
        backgroundColor: GameConstants.darkColor,
        foregroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Color(0xFFFFC107), size: 24),
            const SizedBox(width: 8),
            Text(
              l10n.leaderboard,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =============================================
            // ✅ أعلى نتيجة
            // =============================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GameConstants.secondaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GameConstants.secondaryColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: GameConstants.secondaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.highScore,
                        style: const TextStyle(
                          color: GameConstants.secondaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$highScore ${l10n.seconds}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // =============================================
            // ✅ القائمة
            // =============================================
            Expanded(
              child: leaderboard.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.leaderboard,
                            size: 80,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noResultsYet,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFADB5BD),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.startPlaying,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: leaderboard.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final entry = leaderboard[i];
                        final dateStr =
                            _formatDate(entry['date'] as String? ?? '');
                        return _buildRankItem(
                          rank: i + 1,
                          score: entry['score'] as int? ?? 0,
                          date: dateStr,
                          l10n: l10n,
                          isFirst: i == 0,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================
  // ✅ بناء عنصر الرتبة (بدون إيموجي)
  // =============================================
  Widget _buildRankItem({
    required int rank,
    required int score,
    required String date,
    required AppLocalizations l10n,
    required bool isFirst,
  }) {
    // ✅ لون + أيقونة حسب الرتبة
    Color rankColor;
    IconData? rankIcon;

    switch (rank) {
      case 1:
        rankColor = const Color(0xFFFFD700); // ذهبي
        rankIcon = Icons.emoji_events;
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0); // فضي
        rankIcon = Icons.emoji_events;
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32); // برونزي
        rankIcon = Icons.emoji_events;
        break;
      default:
        rankColor = const Color(0xFF6C757D);
        rankIcon = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFirst
              ? GameConstants.secondaryColor
              : const Color(0xFF1E5A96),
          width: isFirst ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // ✅ الرتبة (أيقونة أو رقم)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: rankColor.withValues(alpha: 0.5)),
            ),
            alignment: Alignment.center,
            child: rankIcon != null
                ? Icon(rankIcon, color: rankColor, size: 22)
                : Text(
                    '$rank',
                    style: TextStyle(
                      color: rankColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // ✅ النقاط
          Expanded(
            child: Text(
              '$score ${l10n.seconds}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ✅ التاريخ
          Text(
            date,
            style: const TextStyle(
              color: Color(0xFFADB5BD),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // ✅ تنسيق التاريخ
  // =============================================
  String _formatDate(String iso) {
    try {
      final date = DateTime.parse(iso);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
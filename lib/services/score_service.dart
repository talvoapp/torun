import 'storage_service.dart';

class ScoreService {
  static final ScoreService _instance = ScoreService._internal();
  factory ScoreService() => _instance;
  ScoreService._internal();

  static const String _storageKey = 'talvo_runner_data';
  Map<String, dynamic> _data = {};

  Future<void> initialize() async {
    final stored = StorageService().getJson(_storageKey);
    _data = stored ?? _defaultData();
    if (stored == null) {
      await save();
    }
  }

  Map<String, dynamic> _defaultData() {
    return {
      'high_score': 0,
      'leaderboard': [],
      'total_games': 0,
      'coins': 0,
      'total_coins_earned': 0,
      'owned_items': [
        'char_default', // ✅ الافتراضي (logo.png)
        'skin_classic',
        'bg_day',
        'env_normal',
        'obs_cactus',
        'particles_none',
        'sounds_default',
        'badge_rookie',
        'weapon_none',
      ],
      'equipped_items': {
        'character': 'char_default',
        'skin': 'skin_classic',
        'background': 'bg_day',
        'environment': 'env_normal',
        'obstacles': 'obs_cactus',
        'particles': 'particles_none',
        'sounds': 'sounds_default',
        'badge': 'badge_rookie',
        'weapons': 'weapon_none',
      },
      'achievements': [],
      'stats': {
        'total_kills': 0,
        'total_bullets_fired': 0,
        'best_kills_in_game': 0,
        'total_play_time': 0,
        'total_deaths': 0,
      },
    };
  }

  Future<void> save() async {
    await StorageService().setJson(_storageKey, _data);
  }

  // =============================================
  // ✅ High Score
  // =============================================

  int get highScore => (_data['high_score'] as int?) ?? 0;

  bool isHighScore(int score) => score > highScore;

  // =============================================
  // ✅ Leaderboard
  // =============================================

  List<Map<String, dynamic>> get leaderboard {
    final list = (_data['leaderboard'] as List?) ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<int> addScore(int score, {String? playerName}) async {
    if (score > highScore) {
      _data['high_score'] = score;
    }

    final lb = List<Map<String, dynamic>>.from(_data['leaderboard'] ?? []);
    lb.add({
      'score': score,
      'date': DateTime.now().toIso8601String(),
      if (playerName != null) 'player_name': playerName,
    });
    lb.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    _data['leaderboard'] = lb.take(5).toList();

    _data['total_games'] = ((_data['total_games'] as int?) ?? 0) + 1;

    final coinsEarned = _calculateCoins(score);
    await addCoins(coinsEarned);
    await save();
    return coinsEarned;
  }

  int _calculateCoins(int score) {
    int base = score;
    if (score >= 100) {
      base += 20;
    } else if (score >= 50) {
      base += 10;
    } else if (score >= 30) {
      base += 5;
    }
    return base;
  }

  // =============================================
  // ✅ Coins
  // =============================================

  int get coins => (_data['coins'] as int?) ?? 0;
  int get totalCoinsEarned => (_data['total_coins_earned'] as int?) ?? 0;

  Future<int> addCoins(int amount) async {
    _data['coins'] = coins + amount;
    _data['total_coins_earned'] = totalCoinsEarned + amount;
    await save();
    return _data['coins'] as int;
  }

  Future<bool> spendCoins(int amount) async {
    if (coins < amount) return false;
    _data['coins'] = coins - amount;
    await save();
    return true;
  }

  // =============================================
  // ✅ Items
  // =============================================

  List<String> get ownedItems {
    final list = (_data['owned_items'] as List?) ?? [];
    return list.map((e) => e.toString()).toList();
  }

  bool ownsItem(String itemId) => ownedItems.contains(itemId);

  Map<String, String> get equippedItems {
    final map = (_data['equipped_items'] as Map?) ?? {};
    return map.map((key, value) => MapEntry(key.toString(), value.toString()));
  }

  String getEquipped(String category) => equippedItems[category] ?? '';

  Future<Map<String, dynamic>> buyItem(String itemId, int price) async {
    if (ownsItem(itemId)) {
      return {'success': false, 'code': 'already_owned'};
    }
    if (!await spendCoins(price)) {
      return {'success': false, 'code': 'insufficient_coins'};
    }
    final owned = ownedItems..add(itemId);
    _data['owned_items'] = owned;
    await save();
    return {'success': true, 'code': 'purchased'};
  }

  Future<Map<String, dynamic>> equipItem(String category, String itemId) async {
    if (!ownsItem(itemId)) {
      return {'success': false, 'code': 'not_owned'};
    }
    final equipped = equippedItems..[category] = itemId;
    _data['equipped_items'] = equipped;
    await save();
    return {'success': true, 'code': 'equipped'};
  }

  // =============================================
  // ✅ Stats
  // =============================================

  Map<String, int> get stats {
    final map = (_data['stats'] as Map?) ?? {};
    return map.map(
      (key, value) => MapEntry(key.toString(), (value as num).toInt()),
    );
  }

  Future<void> addKill({int count = 1}) async {
    final s = stats..['total_kills'] = (stats['total_kills'] ?? 0) + count;
    _data['stats'] = s;
    await save();
  }

  Future<void> addBulletFired({int count = 1}) async {
    final s = stats
      ..['total_bullets_fired'] = (stats['total_bullets_fired'] ?? 0) + count;
    _data['stats'] = s;
    await save();
  }

  Future<void> updateBestKills(int kills) async {
    if (kills > (stats['best_kills_in_game'] ?? 0)) {
      final s = stats..['best_kills_in_game'] = kills;
      _data['stats'] = s;
      await save();
    }
  }

  Future<void> addDeath() async {
    final s = stats..['total_deaths'] = (stats['total_deaths'] ?? 0) + 1;
    _data['stats'] = s;
    await save();
  }

  Future<void> addPlayTime(int seconds) async {
    final s = stats
      ..['total_play_time'] = (stats['total_play_time'] ?? 0) + seconds;
    _data['stats'] = s;
    await save();
  }

  // =============================================
  // ✅ Achievements (Badges)
  // =============================================

  List<String> get achievements {
    final list = (_data['achievements'] as List?) ?? [];
    return list.map((e) => e.toString()).toList();
  }

  Future<List<String>> checkAchievements() async {
    final earned = <String>[];
    final totalGames = (_data['total_games'] as int?) ?? 0;
    final hs = highScore;

    if (totalGames >= 1) earned.add('badge_rookie');
    if (totalGames >= 10) earned.add('badge_pro');
    if (hs >= 100) earned.add('badge_master');
    if (hs >= 300) earned.add('badge_legend');
    if (hs >= 1000) earned.add('badge_god');

    final owned = ownedItems;
    final newBadges = <String>[];
    for (final badge in earned) {
      if (!owned.contains(badge)) {
        owned.add(badge);
        newBadges.add(badge);
      }
    }

    if (newBadges.isNotEmpty) {
      _data['owned_items'] = owned;
      await save();
    }

    return newBadges;
  }

  Future<List<String>> checkWeaponAchievements() async {
    final s = stats;
    final earned = achievements;
    final newAchievements = <String>[];

    const requirements = {
      'ach_first_kill': {'type': 'kills', 'value': 1, 'reward': 20},
      'ach_hunter': {'type': 'kills', 'value': 50, 'reward': 100},
      'ach_sniper': {'type': 'kills', 'value': 200, 'reward': 300},
      'ach_shooter': {'type': 'bullets', 'value': 500, 'reward': 150},
      'ach_terminator': {'type': 'kills_in_game', 'value': 100, 'reward': 500},
    };

    for (final entry in requirements.entries) {
      final achId = entry.key;
      if (earned.contains(achId)) continue;

      final req = entry.value;
      final type = req['type'] as String;
      final value = req['value'] as int;

      bool achieved = false;
      if (type == 'kills') {
        achieved = (s['total_kills'] ?? 0) >= value;
      } else if (type == 'bullets') {
        achieved = (s['total_bullets_fired'] ?? 0) >= value;
      } else if (type == 'kills_in_game') {
        achieved = (s['best_kills_in_game'] ?? 0) >= value;
      }
      if (achieved) {
        newAchievements.add(achId);
        await addCoins(req['reward'] as int);
      }
    }

    if (newAchievements.isNotEmpty) {
      final ach = achievements..addAll(newAchievements);
      _data['achievements'] = ach;
      await save();
    }

    return newAchievements;
  }

  Future<void> resetStats() async {
    _data['stats'] = {
      'total_kills': 0,
      'total_bullets_fired': 0,
      'best_kills_in_game': 0,
      'total_play_time': 0,
      'total_deaths': 0,
    };
    await save();
  }

  Future<void> resetAll() async {
    _data = _defaultData();
    await save();
  }
}
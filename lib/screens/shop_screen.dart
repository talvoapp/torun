import 'package:flutter/material.dart';
import '../constants.dart';
import '../generated/l10n/app_localizations.dart';
import '../l10n/item_translations.dart';
import '../services/score_service.dart';
import '../services/sound_service.dart';
import '../services/shop_catalog.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  final ScoreService _scoreService = ScoreService();
  final SoundService _soundService = SoundService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final categories = ShopCatalog.allCategories.keys.toList();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // =============================================
  // ✅ تنسيق الأسعار (K/M)
  // =============================================
  String _formatPrice(int price) {
    if (price >= 1000000) {
      final millions = price / 1000000;
      if (millions == millions.roundToDouble()) {
        return '${millions.toInt()}M';
      }
      return '${millions.toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      final thousands = price / 1000;
      if (thousands == thousands.roundToDouble()) {
        return '${thousands.toInt()}K';
      }
      return '${thousands.toStringAsFixed(1)}K';
    }
    return price.toString();
  }

  // =============================================
  // ✅ ترجمة أسماء الفئات
  // =============================================
  String _translateCategory(String key, AppLocalizations l10n) {
    switch (key) {
      case 'character':
        return l10n.categoryCharacters;
      case 'skin':
        return l10n.categorySkins;
      case 'background':
        return l10n.categoryBackgrounds;
      case 'world':
        return l10n.categoryWorlds;
      case 'obstacles':
        return l10n.categoryObstacles;
      case 'particles':
        return l10n.categoryParticles;
      case 'sounds':
        return l10n.categorySounds;
      case 'badge':
        return l10n.categoryBadges;
      case 'weapons':
        return l10n.categoryWeapons;
      case 'achievements':
        return l10n.categoryAchievements;
      default:
        return key;
    }
  }

  // =============================================
  // ✅ أيقونة الفئة
  // =============================================
  IconData _getCategoryIcon(String key) {
    switch (key) {
      case 'character':
        return Icons.person;
      case 'skin':
        return Icons.palette;
      case 'background':
        return Icons.image;
      case 'world':
        return Icons.public;
      case 'obstacles':
        return Icons.warning_amber;
      case 'particles':
        return Icons.auto_awesome;
      case 'sounds':
        return Icons.music_note;
      case 'badge':
        return Icons.emoji_events;
      case 'weapons':
        return Icons.gps_fixed;
      case 'achievements':
        return Icons.military_tech;
      default:
        return Icons.category;
    }
  }

  // =============================================
  // ✅ شراء عنصر
  // =============================================
  Future<void> _buyItem(String itemId, String catKey, int price) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GameConstants.darkColor,
        title: Text(
          l10n.confirmPurchase,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.buyConfirm(_formatPrice(price)),
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
              backgroundColor: GameConstants.successColor,
            ),
            child: Text(l10n.buy),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await _scoreService.buyItem(itemId, price);
    if (!mounted) return;

    if (result['success'] == true) {
      await _scoreService.equipItem(catKey, itemId);
      _soundService.play('new_high_score');
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.purchaseSuccess),
          backgroundColor: GameConstants.successColor,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.insufficientCoins),
          backgroundColor: GameConstants.dangerColor,
        ),
      );
    }
  }

  // =============================================
  // ✅ تجهيز عنصر
  // =============================================
  Future<void> _equipItem(String catKey, String itemId) async {
    final l10n = AppLocalizations.of(context);
    final result = await _scoreService.equipItem(catKey, itemId);
    if (!mounted) return;

    if (result['success'] == true) {
      _soundService.play('click');
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.equipFailed),
          backgroundColor: GameConstants.dangerColor,
        ),
      );
    }
  }

  // =============================================
  // ✅ بناء الشاشة الرئيسية
  // =============================================
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final categories = ShopCatalog.allCategories.entries.toList();
    final coins = _scoreService.coins;

    return Scaffold(
      backgroundColor: GameConstants.darkColor,
      appBar: AppBar(
        backgroundColor: GameConstants.darkColor,
        foregroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart, size: 24),
            const SizedBox(width: 8),
            Text(
              l10n.shop,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(left: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: GameConstants.secondaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: GameConstants.secondaryColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: GameConstants.secondaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatPrice(coins),
                    style: const TextStyle(
                      color: GameConstants.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: GameConstants.primaryColor,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF6C757D),
          tabs: categories
              .map((e) => Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getCategoryIcon(e.key), size: 16),
                        const SizedBox(width: 4),
                        Text(_translateCategory(e.key, l10n)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: categories.map((entry) {
          final catKey = entry.key;
          final items =
              entry.value['items'] as Map<String, Map<String, dynamic>>;
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final itemId = items.keys.elementAt(i);
              final itemData = items[itemId]!;
              return _buildItemCard(
                l10n,
                locale,
                catKey,
                itemId,
                itemData,
              );
            },
          );
        }).toList(),
      ),
    );
  }

  // =============================================
  // ✅ بطاقة العنصر
  // =============================================
  Widget _buildItemCard(
    AppLocalizations l10n,
    String locale,
    String catKey,
    String itemId,
    Map<String, dynamic> itemData,
  ) {
    final owned = _scoreService.ownsItem(itemId);
    final equipped = _scoreService.getEquipped(catKey) == itemId;
    final price = itemData['price'] as int? ?? 0;

    final rawName = itemData['name'] as String? ?? '';
    final rawDesc = itemData['description'] as String? ?? '';
    final name = ItemTranslations.getName(itemId, locale, rawName);
    final desc = ItemTranslations.getDescription(itemId, locale, rawDesc);

    final preview = _buildPreview(catKey, itemData, l10n);
    final cardBg = _getCardBackground(catKey, itemData);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: equipped
              ? GameConstants.successColor
              : const Color(0xFF1E5A96),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(gradient: cardBg),
                padding: const EdgeInsets.all(8),
                child: Center(child: preview),
              ),
            ),
            Container(
              color: const Color(0xFF0F3460),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFADB5BD),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                      l10n, catKey, itemId, price, owned, equipped),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================
  // ✅ زر الإجراء
  // =============================================
  Widget _buildActionButton(
    AppLocalizations l10n,
    String catKey,
    String itemId,
    int price,
    bool owned,
    bool equipped,
  ) {
    if (equipped) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: GameConstants.successColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: GameConstants.successColor.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: GameConstants.successColor,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              l10n.equipped,
              style: const TextStyle(
                color: GameConstants.successColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (owned) {
      return SizedBox(
        height: 32,
        child: ElevatedButton(
          onPressed: () => _equipItem(catKey, itemId),
          style: ElevatedButton.styleFrom(
            backgroundColor: GameConstants.successColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.touch_app, size: 14),
              const SizedBox(width: 4),
              Text(
                l10n.equip,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: () => _buyItem(itemId, catKey, price),
        style: ElevatedButton.styleFrom(
          backgroundColor: GameConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              price == 0 ? Icons.card_giftcard : Icons.shopping_cart,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              price == 0 ? l10n.free : _formatPrice(price),
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================
  // ✅ خلفية البطاقة حسب الفئة
  // =============================================
  LinearGradient _getCardBackground(String catKey, Map<String, dynamic> data) {
    switch (catKey) {
      case 'character':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)],
        );
      case 'skin':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C2D12), Color(0xFF9A3412)],
        );
      case 'background':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF065F46), Color(0xFF047857)],
        );
      case 'world':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E7490), Color(0xFF155E75)],
        );
      case 'obstacles':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7F1D1D), Color(0xFF991B1B)],
        );
      case 'particles':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B21A8), Color(0xFF7E22CE)],
        );
      case 'sounds':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF164E63), Color(0xFF155E75)],
        );
      case 'badge':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF854D0E), Color(0xFFA16207)],
        );
      case 'weapons':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF831843), Color(0xFF9D174D)],
        );
      case 'achievements':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF78350F), Color(0xFF92400E)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF1F2937), Color(0xFF374151)],
        );
    }
  }

  // =============================================
  // ✅ تحويل اسم الأيقونة لـ IconData
  // =============================================
  IconData _getIconData(String name) {
    switch (name) {
      case 'star': return Icons.star;
      case 'directions_run': return Icons.directions_run;
      case 'directions_car': return Icons.directions_car;
      case 'smart_toy': return Icons.smart_toy;
      case 'dangerous': return Icons.dangerous;
      case 'shield': return Icons.shield;
      case 'military_tech': return Icons.military_tech;
      case 'workspace_premium': return Icons.workspace_premium;
      case 'palette': return Icons.palette;
      case 'wb_sunny': return Icons.wb_sunny;
      case 'dark_mode': return Icons.dark_mode;
      case 'landscape': return Icons.landscape;
      case 'terrain': return Icons.terrain;
      case 'forest': return Icons.forest;
      case 'nights_stay': return Icons.nights_stay;
      case 'water': return Icons.water;
      case 'public': return Icons.public;
      case 'park': return Icons.park;
      case 'flight': return Icons.flight;
      case 'bug_report': return Icons.bug_report;
      case 'pest_control': return Icons.pest_control;
      case 'block': return Icons.block;
      case 'local_fire_department': return Icons.local_fire_department;
      case 'ac_unit': return Icons.ac_unit;
      case 'bubble_chart': return Icons.bubble_chart;
      case 'flash_on': return Icons.flash_on;
      case 'volume_up': return Icons.volume_up;
      case 'piano': return Icons.piano;
      case 'sports_esports': return Icons.sports_esports;
      case 'graphic_eq': return Icons.graphic_eq;
      case 'music_note': return Icons.music_note;
      case 'gps_fixed': return Icons.gps_fixed;
      case 'rocket_launch': return Icons.rocket_launch;
      case 'bolt': return Icons.bolt;
      default: return Icons.star;
    }
  }

  // =============================================
  // ✅ معاينة العنصر
  // =============================================
  Widget _buildPreview(
    String catKey,
    Map<String, dynamic> itemData,
    AppLocalizations l10n,
  ) {
    switch (catKey) {
      case 'character':
        return _buildCharacterPreview(itemData);
      case 'skin':
        return _buildSkinPreview(itemData);
      case 'background':
        return _buildBackgroundPreview(itemData);
      case 'world':
        return _buildWorldPreview(itemData);
      case 'obstacles':
        return _buildObstaclePreview(itemData, l10n);
      case 'particles':
        return _buildGenericIconPreview(itemData);
      case 'sounds':
        return _buildGenericIconPreview(itemData);
      case 'badge':
        return _buildGenericIconPreview(itemData);
      case 'weapons':
        return _buildGenericIconPreview(itemData);
      case 'achievements':
        return _buildGenericIconPreview(itemData);
      default:
        return const Icon(Icons.help, size: 40, color: Color(0xFFADB5BD));
    }
  }

  // =============================================
  // ✅ معاينة الشخصية
  // =============================================
  Widget _buildCharacterPreview(Map<String, dynamic> itemData) {
    if (itemData['image'] != null) {
      return Image.asset(
        itemData['image'] as String,
        height: 90,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.person, size: 60, color: Color(0xFFADB5BD)),
      );
    }

    if (itemData['spritePrefix'] != null) {
      final prefix = itemData['spritePrefix'] as String;
      final path = itemData['spritePath'] as String;
      final poseMap = itemData['poseMap'] as Map<String, dynamic>? ?? {};
      final idleName = poseMap['idle'] as String? ?? 'idle';
      return Image.asset(
        '$path${prefix}_$idleName.png',
        height: 90,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.person, size: 60, color: Color(0xFFADB5BD)),
      );
    }

    if (itemData['rig'] != null) {
      final rigType = itemData['rig'] as String? ?? 'human';
      final colorHex = itemData['colorPrimary'] as String? ?? '#0d6efd';
      final color = Color(
        int.parse('FF${colorHex.replaceFirst('#', '')}', radix: 16),
      );
      final iconData =
          rigType == 'car' ? Icons.directions_car : Icons.directions_run;

      return Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(iconData, size: 55, color: color),
      );
    }

    return const Icon(Icons.person, size: 60, color: Color(0xFFADB5BD));
  }

  // =============================================
  // ✅ معاينة المظهر
  // =============================================
  Widget _buildSkinPreview(Map<String, dynamic> itemData) {
    final hex = (itemData['colorPrimary'] as String? ?? '#0d6efd')
        .replaceFirst('#', '');
    final color = Color(int.parse('FF$hex', radix: 16));

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
        boxShadow: itemData['glow'] == true
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ]
            : null,
      ),
      child: itemData['glow'] == true
          ? const Icon(Icons.auto_awesome, color: Colors.white, size: 30)
          : null,
    );
  }

  // =============================================
  // ✅ معاينة الخلفية
  // =============================================
  Widget _buildBackgroundPreview(Map<String, dynamic> itemData) {
    if (itemData['image'] != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          itemData['image'] as String,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF1A1A2E),
            child: const Icon(Icons.broken_image,
                size: 40, color: Color(0xFFADB5BD)),
          ),
        ),
      );
    }

    if (itemData['topColor'] != null && itemData['bottomColor'] != null) {
      final top = itemData['topColor'] as List<int>;
      final bottom = itemData['bottomColor'] as List<int>;
      final groundColor = itemData['groundColor'] as List<int>?;

      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, top[0], top[1], top[2]),
                Color.fromARGB(255, bottom[0], bottom[1], bottom[2]),
              ],
            ),
          ),
          child: groundColor != null
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 15,
                    color: Color.fromARGB(
                        255, groundColor[0], groundColor[1], groundColor[2]),
                  ),
                )
              : null,
        ),
      );
    }

    return const Icon(Icons.image, size: 40, color: Color(0xFFADB5BD));
  }

  // =============================================
  // ✅ معاينة العالم (بأيقونة Material)
  // =============================================
  Widget _buildWorldPreview(Map<String, dynamic> itemData) {
    final iconName = itemData['icon'] as String? ?? 'public';
    final iconData = _getIconData(iconName);

    // ✅ لون حسب نوع العالم
    Color bgColor;
    switch (iconName) {
      case 'public':
        bgColor = const Color(0xFF4A90E2);
        break;
      case 'forest':
        bgColor = const Color(0xFF4CAF50);
        break;
      case 'water':
        bgColor = const Color(0xFF0288D1);
        break;
      case 'nights_stay':
        bgColor = const Color(0xFF6B21A8);
        break;
      case 'landscape':
        bgColor = const Color(0xFFD4A574);
        break;
      case 'terrain':
        bgColor = const Color(0xFF6B8E23);
        break;
      case 'workspace_premium':
        bgColor = const Color(0xFFFFD700);
        break;
      default:
        bgColor = const Color(0xFF6C757D);
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            bgColor.withValues(alpha: 0.8),
            bgColor.withValues(alpha: 0.3),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: bgColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Icon(iconData, color: Colors.white, size: 50),
    );
  }

  // =============================================
  // ✅ معاينة الأعداء
  // =============================================
  Widget _buildObstaclePreview(
      Map<String, dynamic> itemData, AppLocalizations l10n) {
    final type = itemData['type'] as String? ?? 'cactus';

    if (type == 'platformer') {
      return _buildMultiSpritePreview([
        'assets/images/obstacles/platformer/slime1.png',
        'assets/images/obstacles/platformer/snail1.png',
        'assets/images/obstacles/platformer/fish1.png',
      ]);
    }

    if (type == 'nature') {
      return _buildMultiSpritePreview([
        'assets/images/obstacles/nature/frog1.png',
        'assets/images/obstacles/nature/bee1.png',
        'assets/images/obstacles/nature/ladybug1.png',
      ]);
    }

    if (type == 'cactus') {
      return _buildMultiSpritePreview([
        'assets/images/obstacles/cactus_platformer/cactus.png',
        'assets/images/obstacles/cactus_platformer/cactus_large.png',
      ]);
    }

    final iconName = itemData['icon'] as String? ?? 'park';
    final iconData = _getIconData(iconName);

    Color iconColor;
    switch (iconName) {
      case 'landscape':
        iconColor = const Color(0xFFC8BEB4);
        break;
      case 'directions_car':
        iconColor = const Color(0xFFFF6464);
        break;
      case 'flight':
        iconColor = const Color(0xFFB4B4DC);
        break;
      default:
        iconColor = const Color(0xFFADB5BD);
    }

    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: iconColor, width: 2),
      ),
      child: Icon(iconData, size: 55, color: iconColor),
    );
  }

  // =============================================
  // ✅ معاينة متعددة sprites
  // =============================================
  Widget _buildMultiSpritePreview(List<String> imagePaths) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: imagePaths.map((path) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Image.asset(
              path,
              height: 70,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.image_not_supported,
                size: 24,
                color: Color(0xFF6C757D),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // =============================================
  // ✅ معاينة عامة
  // =============================================
  Widget _buildGenericIconPreview(Map<String, dynamic> itemData) {
    final iconName = itemData['icon'] as String? ?? 'star';
    final iconData = _getIconData(iconName);

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
      ),
      child: Icon(iconData, size: 45, color: Colors.white),
    );
  }
}
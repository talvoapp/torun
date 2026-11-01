/// ترجمات أسماء وأوصاف عناصر المتجر
/// المفتاح: itemId
/// القيمة: خريطة [locale: string]
class ItemTranslations {
  // =============================================
  // ✅ أسماء العناصر
  // =============================================
  static const Map<String, Map<String, String>> _names = {
    // === الشخصيات - القديمة ===
    'char_default': {
      'ar': 'Talvo',
      'en': 'Talvo',
      'fr': 'Talvo',
    },
    'char_man': {
      'ar': 'رجل (رسم قديم)',
      'en': 'Man (Old)',
      'fr': 'Homme (Ancien)',
    },
    'char_child': {
      'ar': 'طفل (رسم قديم)',
      'en': 'Child (Old)',
      'fr': 'Enfant (Ancien)',
    },
    'char_woman': {
      'ar': 'امرأة (رسم قديم)',
      'en': 'Woman (Old)',
      'fr': 'Femme (Ancienne)',
    },
    'char_male_person': {
      'ar': 'رجل',
      'en': 'Man',
      'fr': 'Homme',
    },
    'char_female_person': {
      'ar': 'امرأة',
      'en': 'Woman',
      'fr': 'Femme',
    },
    'char_male_adventurer': {
      'ar': 'مغامر',
      'en': 'Male Adventurer',
      'fr': 'Aventurier',
    },
    'char_female_adventurer': {
      'ar': 'مغامرة',
      'en': 'Female Adventurer',
      'fr': 'Aventurière',
    },
    'char_robot': {
      'ar': 'روبوت',
      'en': 'Robot',
      'fr': 'Robot',
    },
    'char_zombie': {
      'ar': 'زومبي',
      'en': 'Zombie',
      'fr': 'Zombie',
    },
    'char_car': {
      'ar': 'سيارة رياضية',
      'en': 'Sports Car',
      'fr': 'Voiture Sportive',
    },
    'char_superhero': {
      'ar': 'بطل خارق',
      'en': 'Superhero',
      'fr': 'Super-héros',
    },

    // === العوالم ===
    'world_normal': {
      'ar': 'العالم العادي',
      'en': 'Normal World',
      'fr': 'Monde Normal',
    },
    'world_forest': {
      'ar': 'غابة الأشجار',
      'en': 'Forest World',
      'fr': 'Monde Forêt',
    },
    'world_underwater': {
      'ar': 'تحت الماء',
      'en': 'Underwater World',
      'fr': 'Monde Sous-Marin',
    },
    'world_space': {
      'ar': 'الفضاء',
      'en': 'Space World',
      'fr': 'Monde Spatial',
    },
    'world_desert': {
      'ar': 'الصحراء',
      'en': 'Desert World',
      'fr': 'Monde Désert',
    },
    'world_hills': {
      'ar': 'التلال',
      'en': 'Hills World',
      'fr': 'Monde Collines',
    },
    'world_azza_elasfar': {
      'ar': 'مملكة عزة',
      'en': 'Azza\'s Kingdom',
      'fr': 'Royaume d\'Azza',
    },

    // === AZZA ELASFAR ===
    'char_azza_elasfar': {
      'ar': 'عزة الأصفر',
      'en': 'Azza Elasfar',
      'fr': 'Azza Elasfar',
    },
    'bg_azza_elasfar': {
      'ar': 'مملكة عزة',
      'en': 'Azza\'s Kingdom',
      'fr': 'Royaume d\'Azza',
    },

    // === الشخصيات - Platformer ===
    'char_platformer_zombie': {
      'ar': 'زومبي بلاتفورمر',
      'en': 'Platformer Zombie',
      'fr': 'Zombie Platformer',
    },
    'char_platformer_player': {
      'ar': 'لاعب بلاتفورمر',
      'en': 'Platformer Player',
      'fr': 'Joueur Platformer',
    },
    'char_platformer_female': {
      'ar': 'امرأة بلاتفورمر',
      'en': 'Platformer Female',
      'fr': 'Femme Platformer',
    },
    'char_platformer_adventurer': {
      'ar': 'مغامر بلاتفورمر',
      'en': 'Platformer Adventurer',
      'fr': 'Aventurier Platformer',
    },
    'char_platformer_soldier': {
      'ar': 'جندي بلاتفورمر',
      'en': 'Platformer Soldier',
      'fr': 'Soldat Platformer',
    },

    // === المظاهر ===
    'skin_classic': {
      'ar': 'Talvo Classic',
      'en': 'Talvo Classic',
      'fr': 'Talvo Classique',
    },
    'skin_golden': {
      'ar': 'Golden Talvo',
      'en': 'Golden Talvo',
      'fr': 'Talvo Doré',
    },
    'skin_neon': {
      'ar': 'Neon Talvo',
      'en': 'Neon Talvo',
      'fr': 'Talvo Néon',
    },
    'skin_fire': {
      'ar': 'Fire Talvo',
      'en': 'Fire Talvo',
      'fr': 'Talvo de Feu',
    },
    'skin_ice': {
      'ar': 'Ice Talvo',
      'en': 'Ice Talvo',
      'fr': 'Talvo de Glace',
    },
    'skin_rainbow': {
      'ar': 'Rainbow Talvo',
      'en': 'Rainbow Talvo',
      'fr': 'Talvo Arc-en-ciel',
    },

    // === الخلفيات ===
    'bg_day': {
      'ar': 'نهار',
      'en': 'Day',
      'fr': 'Jour',
    },
    'bg_night': {
      'ar': 'ليل',
      'en': 'Night',
      'fr': 'Nuit',
    },
    'bg_desert': {
      'ar': 'صحراء',
      'en': 'Desert',
      'fr': 'Désert',
    },
    'bg_forest': {
      'ar': 'غابة',
      'en': 'Forest',
      'fr': 'Forêt',
    },
    'bg_space': {
      'ar': 'فضاء',
      'en': 'Space',
      'fr': 'Espace',
    },
    'bg_ocean': {
      'ar': 'محيط',
      'en': 'Ocean',
      'fr': 'Océan',
    },
    'bg_nature_desert': {
      'ar': 'صحراء طبيعية',
      'en': 'Nature Desert',
      'fr': 'Désert Naturel',
    },
    'bg_nature_hills': {
      'ar': 'تلال',
      'en': 'Hills',
      'fr': 'Collines',
    },
    'bg_nature_mushrooms': {
      'ar': 'غابة فطر',
      'en': 'Mushroom Forest',
      'fr': 'Forêt de Champignons',
    },
    'bg_nature_trees': {
      'ar': 'أشجار',
      'en': 'Trees',
      'fr': 'Arbres',
    },

    // === الأعداء ===
    'obs_cactus': {
      'ar': 'كاكتوس (افتراضي)',
      'en': 'Cactus (Default)',
      'fr': 'Cactus (Défaut)',
    },
    'obs_rocks': {
      'ar': 'صخور',
      'en': 'Rocks',
      'fr': 'Rochers',
    },
    'obs_platformer': {
      'ar': 'وحوش بلاتفورمر',
      'en': 'Platformer Monsters',
      'fr': 'Monstres Platformer',
    },
    'obs_cars': {
      'ar': 'سيارات',
      'en': 'Cars',
      'fr': 'Voitures',
    },
    'obs_drones': {
      'ar': 'طائرات بدون طيار',
      'en': 'Drones',
      'fr': 'Drones',
    },
    'obs_nature': {
      'ar': 'مخلوقات الطبيعة',
      'en': 'Nature Creatures',
      'fr': 'Créatures de la Nature',
    },

    // === المؤثرات ===
    'particles_none': {
      'ar': 'بدون مؤثرات',
      'en': 'No Effects',
      'fr': 'Aucun Effet',
    },
    'particles_stars': {
      'ar': 'نجوم',
      'en': 'Stars',
      'fr': 'Étoiles',
    },
    'particles_fire': {
      'ar': 'لهب',
      'en': 'Fire',
      'fr': 'Feu',
    },
    'particles_snow': {
      'ar': 'ثلج',
      'en': 'Snow',
      'fr': 'Neige',
    },
    'particles_bubbles': {
      'ar': 'فقاعات',
      'en': 'Bubbles',
      'fr': 'Bulles',
    },
    'particles_lightning': {
      'ar': 'برق',
      'en': 'Lightning',
      'fr': 'Éclair',
    },

    // === الأصوات ===
    'sounds_default': {
      'ar': 'افتراضي',
      'en': 'Default',
      'fr': 'Défaut',
    },
    'sounds_classical': {
      'ar': 'كلاسيكي',
      'en': 'Classical',
      'fr': 'Classique',
    },
    'sounds_arcade': {
      'ar': 'أركيد',
      'en': 'Arcade',
      'fr': 'Arcade',
    },
    'sounds_synth': {
      'ar': 'سينث',
      'en': 'Synth',
      'fr': 'Synth',
    },
    'sounds_platformer': {
      'ar': 'بلاتفورمر',
      'en': 'Platformer',
      'fr': 'Platformer',
    },

    // === الشارات ===
    'badge_rookie': {
      'ar': 'مبتدئ',
      'en': 'Rookie',
      'fr': 'Débutant',
    },
    'badge_pro': {
      'ar': 'محترف',
      'en': 'Pro',
      'fr': 'Pro',
    },
    'badge_master': {
      'ar': 'خبير',
      'en': 'Master',
      'fr': 'Maître',
    },
    'badge_legend': {
      'ar': 'أسطورة',
      'en': 'Legend',
      'fr': 'Légende',
    },
    'badge_god': {
      'ar': 'إله',
      'en': 'God',
      'fr': 'Dieu',
    },

    // === الأسلحة ===
    'weapon_none': {
      'ar': 'بدون سلاح',
      'en': 'No Weapon',
      'fr': 'Sans Arme',
    },
    'weapon_pistol': {
      'ar': 'مسدس',
      'en': 'Pistol',
      'fr': 'Pistolet',
    },
    'weapon_rifle': {
      'ar': 'رشاش',
      'en': 'Rifle',
      'fr': 'Fusil',
    },
    'weapon_shotgun': {
      'ar': 'شوزن',
      'en': 'Shotgun',
      'fr': 'Fusil à Pompe',
    },
    'weapon_rocket': {
      'ar': 'صاروخ',
      'en': 'Rocket',
      'fr': 'Fusée',
    },
    'weapon_laser': {
      'ar': 'ليزر',
      'en': 'Laser',
      'fr': 'Laser',
    },

    // === الإنجازات ===
    'ach_first_kill': {
      'ar': 'أول قتلة',
      'en': 'First Kill',
      'fr': 'Premier Kill',
    },
    'ach_hunter': {
      'ar': 'صياد',
      'en': 'Hunter',
      'fr': 'Chasseur',
    },
    'ach_sniper': {
      'ar': 'قناص',
      'en': 'Sniper',
      'fr': 'Sniper',
    },
    'ach_shooter': {
      'ar': 'رامي',
      'en': 'Shooter',
      'fr': 'Tireur',
    },
    'ach_terminator': {
      'ar': 'مدمّر',
      'en': 'Terminator',
      'fr': 'Terminateur',
    },
  };

  // =============================================
  // ✅ الأوصاف
  // =============================================
  static const Map<String, Map<String, String>> _descriptions = {
    // === الشخصيات ===
    'char_default': {
      'ar': 'الشعار الافتراضي',
      'en': 'Default logo',
      'fr': 'Logo par défaut',
    },
    'char_male_person': {
      'ar': 'رجل عادي',
      'en': 'Ordinary man',
      'fr': 'Homme ordinaire',
    },
    'char_female_person': {
      'ar': 'امرأة عادية',
      'en': 'Ordinary woman',
      'fr': 'Femme ordinaire',
    },
    'char_male_adventurer': {
      'ar': 'مغامر شجاع',
      'en': 'Brave adventurer',
      'fr': 'Aventurier courageux',
    },
    'char_female_adventurer': {
      'ar': 'مغامرة شجاعة',
      'en': 'Brave adventurer',
      'fr': 'Aventurière courageuse',
    },
    'char_robot': {
      'ar': 'روبوت آلي',
      'en': 'Mechanical robot',
      'fr': 'Robot mécanique',
    },
    'char_zombie': {
      'ar': 'زومبي مخيف',
      'en': 'Scary zombie',
      'fr': 'Zombie effrayant',
    },
    'char_man': {
      'ar': 'عداء نحيف وسريع',
      'en': 'Fast skinny runner',
      'fr': 'Coureur rapide et mince',
    },
    'char_child': {
      'ar': 'طفل صغير مرح',
      'en': 'Happy little child',
      'fr': 'Petit enfant joyeux',
    },
    'char_woman': {
      'ar': 'عداءة رشيقة',
      'en': 'Agile runner',
      'fr': 'Coureuse agile',
    },
    'char_car': {
      'ar': 'سيارة بعجلات دوارة',
      'en': 'Car with spinning wheels',
      'fr': 'Voiture à roues tournantes',
    },
    'char_superhero': {
      'ar': 'بطل بزي أسود',
      'en': 'Hero in black suit',
      'fr': 'Héros en costume noir',
    },

    // === العوالم ===
    'world_normal': {
      'ar': 'العالم الأساسي: نهار، جاذبية عادية',
      'en': 'Basic world: day, normal gravity',
      'fr': 'Monde de base: jour, gravité normale',
    },
    'world_forest': {
      'ar': 'غابة كثيفة: أشجار، جاذبية عادية',
      'en': 'Dense forest: trees, normal gravity',
      'fr': 'Forêt dense: arbres, gravité normale',
    },
    'world_underwater': {
      'ar': 'عالم بحري: فقاعات، جاذبية أقل',
      'en': 'Underwater world: bubbles, lower gravity',
      'fr': 'Monde sous-marin: bulles, gravité plus faible',
    },
    'world_space': {
      'ar': 'فضاء مفتوح: نجوم، جاذبية خفيفة',
      'en': 'Open space: stars, low gravity',
      'fr': 'Espace ouvert: étoiles, faible gravité',
    },
    'world_desert': {
      'ar': 'صحراء حارقة: رمال، شمس',
      'en': 'Scorching desert: sand, sun',
      'fr': 'Désert brûlant: sable, soleil',
    },
    'world_hills': {
      'ar': 'تلال خضراء: طبيعة، أعداء طبيعية',
      'en': 'Green hills: nature, nature enemies',
      'fr': 'Collines vertes: nature, ennemis naturels',
    },
    'world_azza_elasfar': {
      'ar': 'المملكة الملكية: ذهب، أرض ذهبية',
      'en': 'Royal kingdom: gold, golden ground',
      'fr': 'Royaume royal: or, sol doré',
    },

    // === AZZA ELASFAR ===
    'char_azza_elasfar': {
      'ar': 'الشخصية الملكية الأسطورية',
      'en': 'The legendary royal character',
      'fr': 'Le personnage royal légendaire',
    },
    'bg_azza_elasfar': {
      'ar': 'خلفية مملكة عزة الأصفر',
      'en': 'Azza Elasfar\'s kingdom background',
      'fr': 'Arrière-plan du royaume d\'Azza',
    },

    // === Platformer ===
    'char_platformer_zombie': {
      'ar': 'زومبي كلاسيكي',
      'en': 'Classic zombie',
      'fr': 'Zombie classique',
    },
    'char_platformer_player': {
      'ar': 'لاعب أساسي',
      'en': 'Basic player',
      'fr': 'Joueur de base',
    },
    'char_platformer_female': {
      'ar': 'امرأة مقاتلة',
      'en': 'Fighting female',
      'fr': 'Femme combattante',
    },
    'char_platformer_adventurer': {
      'ar': 'مغامر شجاع',
      'en': 'Brave adventurer',
      'fr': 'Aventurier courageux',
    },
    'char_platformer_soldier': {
      'ar': 'جندي محترف',
      'en': 'Professional soldier',
      'fr': 'Soldat professionnel',
    },

    // === الأعداء ===
    'obs_platformer': {
      'ar': 'وحوش من عالم البلاتفورمر',
      'en': 'Monsters from the platformer world',
      'fr': 'Monstres du monde platformer',
    },
    'obs_nature': {
      'ar': 'نحل، ضفادع، سحالي، صراصير',
      'en': 'Bees, frogs, lizards, roaches',
      'fr': 'Abeilles, grenouilles, lézards',
    },

    // === الخلفيات ===
    'bg_nature_desert': {
      'ar': 'خلفية صحراء طبيعية',
      'en': 'Nature desert background',
      'fr': 'Arrière-plan désert naturel',
    },
    'bg_nature_hills': {
      'ar': 'خلفية تلال طبيعية',
      'en': 'Nature hills background',
      'fr': 'Arrière-plan collines',
    },
    'bg_nature_mushrooms': {
      'ar': 'خلفية غابة فطر',
      'en': 'Mushroom forest background',
      'fr': 'Arrière-plan forêt champignons',
    },
    'bg_nature_trees': {
      'ar': 'خلفية أشجار طبيعية',
      'en': 'Nature trees background',
      'fr': 'Arrière-plan arbres',
    },

    // === الأصوات ===
    'sounds_platformer': {
      'ar': 'أصوات بلاتفورمر احترافية',
      'en': 'Professional platformer sounds',
      'fr': 'Sons platformer professionnels',
    },

    // === الأسلحة ===
    'weapon_pistol': {
      'ar': 'مسدس بسيط - طلقة واحدة',
      'en': 'Simple pistol - single shot',
      'fr': 'Pistolet simple - tir unique',
    },
    'weapon_rifle': {
      'ar': 'رشاش سريع - طلقات متتالية',
      'en': 'Fast rifle - rapid fire',
      'fr': 'Fusil rapide - tir rapide',
    },
    'weapon_shotgun': {
      'ar': 'شوزن - 3 طلقات مع بعض',
      'en': 'Shotgun - 3 shots together',
      'fr': 'Fusil à pompe - 3 tirs groupés',
    },
    'weapon_rocket': {
      'ar': 'صاروخ قوي - يدمر أي عدو',
      'en': 'Powerful rocket - destroys any enemy',
      'fr': 'Fusée puissante - détruit tout ennemi',
    },
    'weapon_laser': {
      'ar': 'ليزر مستمر',
      'en': 'Continuous laser',
      'fr': 'Laser continu',
    },
  };

  // =============================================
  // ✅ Helpers
  // =============================================

  static String getName(String itemId, String locale, String fallback) {
    final map = _names[itemId];
    if (map == null) return fallback;
    return map[locale] ?? fallback;
  }

  static String getDescription(
      String itemId, String locale, String fallback) {
    final map = _descriptions[itemId];
    if (map == null) return fallback;
    return map[locale] ?? fallback;
  }
}
// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'torun';

  @override
  String get play => 'Play';

  @override
  String get shop => 'Shop';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get settings => 'Settings';

  @override
  String get coins => 'Coins';

  @override
  String get highScore => 'High Score';

  @override
  String get best => 'Best';

  @override
  String get score => 'Score';

  @override
  String get gameOver => 'Game Over';

  @override
  String get yourScore => 'Your Score';

  @override
  String get newHighScore => 'New High Score!';

  @override
  String get tapToRestart => 'Tap to Restart';

  @override
  String get tapToStart => 'Tap to Start';

  @override
  String get tapLeftToFire => 'Touch left side to fire';

  @override
  String get swipeDownToDuck => 'Swipe ↓ to duck';

  @override
  String get swipeUpToJump => 'Swipe ↑ to jump';

  @override
  String get paused => 'Paused';

  @override
  String get tapToResume => 'Tap to resume';

  @override
  String get buy => 'Buy';

  @override
  String get equip => 'Equip';

  @override
  String get equipped => 'Equipped';

  @override
  String get owned => 'Owned';

  @override
  String get free => 'Free';

  @override
  String get confirmPurchase => 'Confirm Purchase';

  @override
  String buyConfirm(String price) {
    return 'Do you want to buy this item for $price coins?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get purchaseSuccess => 'Purchase successful!';

  @override
  String get insufficientCoins => 'Insufficient coins';

  @override
  String get alreadyOwned => 'You already own this item';

  @override
  String get equipSuccess => 'Equipped!';

  @override
  String get equipFailed => 'You don\'t own this item';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get sound => 'Sound';

  @override
  String get soundOn => 'Enable sounds';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get resetStats => 'Reset Statistics';

  @override
  String get resetAll => 'Reset All Data';

  @override
  String get resetStatsConfirm => 'Do you want to reset statistics?';

  @override
  String get resetAllConfirm =>
      'Are you sure you want to reset all data? This cannot be undone!';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get statsReset => 'Statistics reset';

  @override
  String get allReset => 'All data reset';

  @override
  String get gamesPlayed => 'Games Played';

  @override
  String get totalCoins => 'Total Coins';

  @override
  String get version => 'Version';

  @override
  String get characters => 'Characters';

  @override
  String get skins => 'Skins';

  @override
  String get backgrounds => 'Backgrounds';

  @override
  String get obstacles => 'Obstacles';

  @override
  String get particles => 'Particles';

  @override
  String get sounds => 'Sounds';

  @override
  String get badges => 'Badges';

  @override
  String get weapons => 'Weapons';

  @override
  String get achievements => 'Achievements';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get firing => 'Firing';

  @override
  String get target => 'Target';

  @override
  String get seconds => 's';

  @override
  String get noResultsYet => 'No results yet';

  @override
  String get startPlaying => 'Start playing!';

  @override
  String get topPlayer => 'Top Player';

  @override
  String get categoryCharacters => 'Characters';

  @override
  String get categorySkins => 'Skins';

  @override
  String get categoryBackgrounds => 'Backgrounds';

  @override
  String get categoryObstacles => 'Obstacles';

  @override
  String get categoryParticles => 'Particles';

  @override
  String get categorySounds => 'Sounds';

  @override
  String get categoryBadges => 'Badges';

  @override
  String get categoryWeapons => 'Weapons';

  @override
  String get categoryAchievements => 'Achievements';

  @override
  String get bullets => 'Bullets';

  @override
  String get enemies => 'Enemies';

  @override
  String get newAchievements => 'New Achievements!';

  @override
  String get powerUpSpeed => '⚡ Speed';

  @override
  String get powerUpShield => '🛡️ Shield';

  @override
  String get powerUpCoinMagnet => '💰 Coin Magnet';

  @override
  String get powerUpDoubleCoins => '✨ Double Coins';

  @override
  String get powerUpSlowMotion => '🐢 Slow Motion';

  @override
  String get million => 'Million';

  @override
  String get coinsShort => 'coins';

  @override
  String get scoreDisplay => 'Score';

  @override
  String get categoryEnvironments => 'Environments';

  @override
  String get categoryWorlds => 'Worlds';
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'torun'**
  String get appTitle;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get coins;

  /// No description provided for @highScore.
  ///
  /// In en, this message translates to:
  /// **'High Score'**
  String get highScore;

  /// No description provided for @best.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get best;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// No description provided for @newHighScore.
  ///
  /// In en, this message translates to:
  /// **'New High Score!'**
  String get newHighScore;

  /// No description provided for @tapToRestart.
  ///
  /// In en, this message translates to:
  /// **'Tap to Restart'**
  String get tapToRestart;

  /// No description provided for @tapToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap to Start'**
  String get tapToStart;

  /// No description provided for @tapLeftToFire.
  ///
  /// In en, this message translates to:
  /// **'Touch left side to fire'**
  String get tapLeftToFire;

  /// No description provided for @swipeDownToDuck.
  ///
  /// In en, this message translates to:
  /// **'Swipe ↓ to duck'**
  String get swipeDownToDuck;

  /// No description provided for @swipeUpToJump.
  ///
  /// In en, this message translates to:
  /// **'Swipe ↑ to jump'**
  String get swipeUpToJump;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @tapToResume.
  ///
  /// In en, this message translates to:
  /// **'Tap to resume'**
  String get tapToResume;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @equip.
  ///
  /// In en, this message translates to:
  /// **'Equip'**
  String get equip;

  /// No description provided for @equipped.
  ///
  /// In en, this message translates to:
  /// **'Equipped'**
  String get equipped;

  /// No description provided for @owned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get owned;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @confirmPurchase.
  ///
  /// In en, this message translates to:
  /// **'Confirm Purchase'**
  String get confirmPurchase;

  /// No description provided for @buyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to buy this item for {price} coins?'**
  String buyConfirm(String price);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @purchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchase successful!'**
  String get purchaseSuccess;

  /// No description provided for @insufficientCoins.
  ///
  /// In en, this message translates to:
  /// **'Insufficient coins'**
  String get insufficientCoins;

  /// No description provided for @alreadyOwned.
  ///
  /// In en, this message translates to:
  /// **'You already own this item'**
  String get alreadyOwned;

  /// No description provided for @equipSuccess.
  ///
  /// In en, this message translates to:
  /// **'Equipped!'**
  String get equipSuccess;

  /// No description provided for @equipFailed.
  ///
  /// In en, this message translates to:
  /// **'You don\'t own this item'**
  String get equipFailed;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @soundOn.
  ///
  /// In en, this message translates to:
  /// **'Enable sounds'**
  String get soundOn;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @resetStats.
  ///
  /// In en, this message translates to:
  /// **'Reset Statistics'**
  String get resetStats;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All Data'**
  String get resetAll;

  /// No description provided for @resetStatsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to reset statistics?'**
  String get resetStatsConfirm;

  /// No description provided for @resetAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all data? This cannot be undone!'**
  String get resetAllConfirm;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @statsReset.
  ///
  /// In en, this message translates to:
  /// **'Statistics reset'**
  String get statsReset;

  /// No description provided for @allReset.
  ///
  /// In en, this message translates to:
  /// **'All data reset'**
  String get allReset;

  /// No description provided for @gamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Games Played'**
  String get gamesPlayed;

  /// No description provided for @totalCoins.
  ///
  /// In en, this message translates to:
  /// **'Total Coins'**
  String get totalCoins;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @characters.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get characters;

  /// No description provided for @skins.
  ///
  /// In en, this message translates to:
  /// **'Skins'**
  String get skins;

  /// No description provided for @backgrounds.
  ///
  /// In en, this message translates to:
  /// **'Backgrounds'**
  String get backgrounds;

  /// No description provided for @obstacles.
  ///
  /// In en, this message translates to:
  /// **'Obstacles'**
  String get obstacles;

  /// No description provided for @particles.
  ///
  /// In en, this message translates to:
  /// **'Particles'**
  String get particles;

  /// No description provided for @sounds.
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get sounds;

  /// No description provided for @badges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;

  /// No description provided for @weapons.
  ///
  /// In en, this message translates to:
  /// **'Weapons'**
  String get weapons;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @firing.
  ///
  /// In en, this message translates to:
  /// **'Firing'**
  String get firing;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get seconds;

  /// No description provided for @noResultsYet.
  ///
  /// In en, this message translates to:
  /// **'No results yet'**
  String get noResultsYet;

  /// No description provided for @startPlaying.
  ///
  /// In en, this message translates to:
  /// **'Start playing!'**
  String get startPlaying;

  /// No description provided for @topPlayer.
  ///
  /// In en, this message translates to:
  /// **'Top Player'**
  String get topPlayer;

  /// No description provided for @categoryCharacters.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get categoryCharacters;

  /// No description provided for @categorySkins.
  ///
  /// In en, this message translates to:
  /// **'Skins'**
  String get categorySkins;

  /// No description provided for @categoryBackgrounds.
  ///
  /// In en, this message translates to:
  /// **'Backgrounds'**
  String get categoryBackgrounds;

  /// No description provided for @categoryObstacles.
  ///
  /// In en, this message translates to:
  /// **'Obstacles'**
  String get categoryObstacles;

  /// No description provided for @categoryParticles.
  ///
  /// In en, this message translates to:
  /// **'Particles'**
  String get categoryParticles;

  /// No description provided for @categorySounds.
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get categorySounds;

  /// No description provided for @categoryBadges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get categoryBadges;

  /// No description provided for @categoryWeapons.
  ///
  /// In en, this message translates to:
  /// **'Weapons'**
  String get categoryWeapons;

  /// No description provided for @categoryAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get categoryAchievements;

  /// No description provided for @bullets.
  ///
  /// In en, this message translates to:
  /// **'Bullets'**
  String get bullets;

  /// No description provided for @enemies.
  ///
  /// In en, this message translates to:
  /// **'Enemies'**
  String get enemies;

  /// No description provided for @newAchievements.
  ///
  /// In en, this message translates to:
  /// **'New Achievements!'**
  String get newAchievements;

  /// No description provided for @powerUpSpeed.
  ///
  /// In en, this message translates to:
  /// **'⚡ Speed'**
  String get powerUpSpeed;

  /// No description provided for @powerUpShield.
  ///
  /// In en, this message translates to:
  /// **'🛡️ Shield'**
  String get powerUpShield;

  /// No description provided for @powerUpCoinMagnet.
  ///
  /// In en, this message translates to:
  /// **'💰 Coin Magnet'**
  String get powerUpCoinMagnet;

  /// No description provided for @powerUpDoubleCoins.
  ///
  /// In en, this message translates to:
  /// **'✨ Double Coins'**
  String get powerUpDoubleCoins;

  /// No description provided for @powerUpSlowMotion.
  ///
  /// In en, this message translates to:
  /// **'🐢 Slow Motion'**
  String get powerUpSlowMotion;

  /// No description provided for @million.
  ///
  /// In en, this message translates to:
  /// **'Million'**
  String get million;

  /// No description provided for @coinsShort.
  ///
  /// In en, this message translates to:
  /// **'coins'**
  String get coinsShort;

  /// No description provided for @scoreDisplay.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get scoreDisplay;

  /// No description provided for @categoryEnvironments.
  ///
  /// In en, this message translates to:
  /// **'Environments'**
  String get categoryEnvironments;

  /// No description provided for @categoryWorlds.
  ///
  /// In en, this message translates to:
  /// **'Worlds'**
  String get categoryWorlds;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n/app_localizations.dart';
import 'services/storage_service.dart';
import 'services/sound_service.dart';
import 'services/score_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await StorageService().initialize();
  } catch (e) {
    debugPrint('StorageService init failed: $e');
  }

  try {
    await ScoreService().initialize();
  } catch (e) {
    debugPrint('ScoreService init failed: $e');
  }

  // ✅ الصوت في الخلفية
  SoundService().initialize();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const TorunApp());
}

class TorunApp extends StatefulWidget {
  const TorunApp({super.key});

  @override
  State<TorunApp> createState() => TorunAppState();

  // ✅ دالة للوصول من أي مكان
  static TorunAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<TorunAppState>();
  }
}

class TorunAppState extends State<TorunApp> {
  Locale _locale = const Locale('ar');

  @override
  void initState() {
    super.initState();
    // ✅ تحميل اللغة المحفوظة
    try {
      final savedLang = StorageService().getString('language');
      if (savedLang.isNotEmpty) {
        _locale = Locale(savedLang);
      }
    } catch (e) {
      debugPrint('Load language failed: $e');
    }
  }

  // ✅ تغيير اللغة + حفظها
  void changeLanguage(String code) {
    setState(() {
      _locale = Locale(code);
    });
    try {
      StorageService().setString('language', code);
    } catch (e) {
      debugPrint('Save language failed: $e');
    }
  }

  Locale get currentLocale => _locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'torun',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
        Locale('fr'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D6EFD),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      ),
      home: const HomeScreen(),
    );
  }
}
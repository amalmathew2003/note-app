import 'package:note_app/Screen/splash_screen.dart';
import 'package:note_app/services/hive_note_service.dart';
import 'package:note_app/services/tts_route_observer.dart';
import 'package:note_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:note_app/services/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Global ValueNotifier for Theme switching
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  await NotificationService().init();
  
  // Load saved theme
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? true;
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

  await HiveNoteService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        final isDark = mode == ThemeMode.dark;
        
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: isDark ? AppColors.bgDark : AppColors.bgLight,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
        );

        return MaterialApp(
          title: 'Voice Notes',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.bgLight,
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              secondary: AppColors.accent,
              surface: AppColors.surfaceLight,
              onSurface: AppColors.textPrimaryLight,
            ),
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).apply(
              bodyColor: AppColors.textPrimaryLight,
              displayColor: AppColors.textPrimaryLight,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.bgDark,
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              secondary: AppColors.accent,
              surface: AppColors.surfaceDark,
              onSurface: AppColors.textPrimaryDark,
            ),
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
              bodyColor: AppColors.textPrimaryDark,
              displayColor: AppColors.textPrimaryDark,
            ),
            useMaterial3: true,
          ),
          navigatorObservers: [TtsRouteObserver()],
          home: const SplashScreen(),
        );
      },
    );
  }
}

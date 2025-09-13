import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/injection.dart';
import 'core/theme/modern_theme.dart';
import 'features/location_detection/presentation/pages/modern_redesigned_home_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Warning: .env file not found. Using default values.');
  }

  // Initialize dependencies
  await configureDependencies();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const FindLocApp());
}

class FindLocApp extends StatelessWidget {
  const FindLocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'FindLoc',
          debugShowCheckedModeBanner: false,
          theme: ModernTheme.lightTheme,
          darkTheme: ModernTheme.darkTheme,
          themeMode: ThemeMode.dark, // Koyu tema varsayılan
          home: const AppInitializer(),
        );
      },
    );
  }
}

/// Widget to check if onboarding is completed
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Test için her zaman onboarding göster
      // final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

      setState(() {
        _showOnboarding = true; // Her zaman true yap
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _showOnboarding = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _showOnboarding
        ? const OnboardingPage()
        : const ModernRedesignedHomePage();
  }
}

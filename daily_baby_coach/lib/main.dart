import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/localization/localization_service.dart';
import 'core/theme/app_theme.dart';
import 'data/local/hive_setup.dart';
import 'presentation/providers/localization_provider.dart';
import 'presentation/providers/onboarding_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/onboarding/profile_setup_screen.dart';
import 'presentation/screens/onboarding/welcome_screen.dart';
import 'presentation/screens/today/today_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage
  await HiveSetup.init();

  // Initialize localization with saved locale
  final localizationService = LocalizationService();
  final prefs = await SharedPreferences.getInstance();
  final savedLocale = prefs.getString('app_locale') ?? 'en';
  await localizationService.load(savedLocale);

  runApp(
    ProviderScope(
      overrides: [
        localizationServiceProvider.overrideWithValue(localizationService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = ref.watch(effectiveBrightnessProvider);
    final onboardingState = ref.watch(onboardingProvider);
    final currentLocale = ref.watch(appLocaleProvider);
    final loc = ref.watch(localizationServiceProvider);

    return MaterialApp(
      key: ValueKey(currentLocale.code), // Force rebuild on locale change
      title: loc.t('app_name'),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
      home: onboardingState.isLoading
          ? const LoadingScreen()
          : onboardingState.isComplete
              ? const TodayScreen()
              : const WelcomeScreen(),
      routes: {
        '/onboarding/welcome': (context) => const WelcomeScreen(),
        '/onboarding/profile': (context) => const ProfileSetupScreen(),
        '/today': (context) => const TodayScreen(),
      },
    );
  }
}

/// Loading screen shown while checking onboarding status
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.child_care,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

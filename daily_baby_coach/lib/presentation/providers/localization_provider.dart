import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization/localization_service.dart';

/// Provider for localization service
final localizationServiceProvider = Provider<LocalizationService>((ref) {
  throw UnimplementedError('LocalizationService must be initialized in main()');
});

/// Helper provider to get translated strings
/// Usage: ref.watch(translationProvider('key'))
final translationProvider = Provider.family<String, String>((ref, key) {
  final localization = ref.watch(localizationServiceProvider);
  return localization.t(key);
});

/// Provider for current app locale (stored in SharedPreferences)
final appLocaleProvider = StateNotifierProvider<AppLocaleNotifier, AppLocale>(
  (ref) => AppLocaleNotifier(ref),
);

class AppLocaleNotifier extends StateNotifier<AppLocale> {
  final Ref _ref;

  AppLocaleNotifier(this._ref) : super(AppLocale.en) {
    _loadLocale();
  }

  static const String _key = 'app_locale';

  /// Load locale from SharedPreferences
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_key);
    if (localeCode != null) {
      final locale = AppLocale.fromCode(localeCode);
      state = locale;
      // Reload localization service with saved locale
      await _ref.read(localizationServiceProvider).load(locale.code);
    }
  }

  /// Set locale and persist to SharedPreferences
  Future<void> setLocale(AppLocale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.code);
    // Reload localization service
    await _ref.read(localizationServiceProvider).load(locale.code);
  }
}

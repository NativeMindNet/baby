import 'package:flutter_riverpod/flutter_riverpod.dart';
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

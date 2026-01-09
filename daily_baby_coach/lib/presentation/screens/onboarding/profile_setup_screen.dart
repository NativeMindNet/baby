import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/localization/localization_service.dart';
import '../../../domain/models/baby_profile.dart';
import '../../providers/localization_provider.dart';
import '../../providers/repository_providers.dart';

/// Profile setup screen - second onboarding step
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  DateTime? _selectedBirthday;
  final Map<String, bool> _capabilities = {
    'rollsOver': false,
    'sitsWithSupport': false,
    'sitsIndependently': false,
    'crawls': false,
    'standsWithSupport': false,
    'walksWithSupport': false,
    'picksUpObjects': false,
    'respondsToName': false,
  };

  bool _isLoading = false;

  Future<void> _selectBirthday(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final lastDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: ref.read(localizationServiceProvider).t('onboarding_birthday_hint'),
    );

    if (picked != null) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  Future<void> _saveAndContinue() async {
    if (_selectedBirthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(localizationServiceProvider).t('onboarding_birthday_hint')),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final profile = BabyProfile(
        id: const Uuid().v4(),
        birthDate: _selectedBirthday!,
        capabilities: _capabilities,
        lastCapabilityUpdate: now,
        createdAt: now,
        updatedAt: now,
      );

      final profileRepo = ref.read(profileRepositoryProvider);
      await profileRepo.saveProfile(profile);

      // Initialize task repository
      final taskRepo = ref.read(taskRepositoryProvider);
      await taskRepo.initialize();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/today');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.read(localizationServiceProvider).t('error'))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(localizationServiceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('onboarding_profile_title')),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Subtitle
                    Text(
                      loc.t('onboarding_profile_subtitle'),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Birthday picker
                    Text(
                      loc.t('onboarding_birthday_label'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      onPressed: () => _selectBirthday(context),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _selectedBirthday != null
                            ? '${_selectedBirthday!.year}-${_selectedBirthday!.month.toString().padLeft(2, '0')}-${_selectedBirthday!.day.toString().padLeft(2, '0')}'
                            : loc.t('onboarding_birthday_hint'),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.centerLeft,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Capabilities section
                    Text(
                      loc.t('onboarding_capabilities_title'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.t('onboarding_capabilities_subtitle'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Capability checkboxes
                    ..._buildCapabilityCheckboxes(loc),

                    const SizedBox(height: 32),

                    // Continue button
                    FilledButton(
                      onPressed: _saveAndContinue,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          loc.t('onboarding_finish'),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _buildCapabilityCheckboxes(LocalizationService loc) {
    final capabilities = [
      ('rollsOver', 'onboarding_cap_rolls_over'),
      ('sitsWithSupport', 'onboarding_cap_sits_with_support'),
      ('sitsIndependently', 'onboarding_cap_sits_independently'),
      ('crawls', 'onboarding_cap_crawls'),
      ('standsWithSupport', 'onboarding_cap_stands_with_support'),
      ('walksWithSupport', 'onboarding_cap_walks_with_support'),
      ('picksUpObjects', 'onboarding_cap_picks_up_objects'),
      ('respondsToName', 'onboarding_cap_responds_to_name'),
    ];

    return capabilities.map((capability) {
      final key = capability.$1;
      final labelKey = capability.$2;

      return CheckboxListTile(
        value: _capabilities[key],
        onChanged: (value) {
          setState(() {
            _capabilities[key] = value ?? false;
          });
        },
        title: Text(loc.t(labelKey)),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      );
    }).toList();
  }
}

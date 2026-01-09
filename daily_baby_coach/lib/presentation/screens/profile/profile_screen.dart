import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/baby_profile.dart';
import '../../providers/localization_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/theme_provider.dart';

/// Profile and settings screen
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(localizationServiceProvider);
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('profile_title')),
      ),
      body: FutureBuilder<BabyProfile?>(
        future: ref.read(profileRepositoryProvider).getProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(loc.t('error')),
            );
          }

          final profile = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Baby info section
                Text(
                  loc.t('profile_baby_info'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.child_care,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(loc.t('profile_age')),
                        subtitle: Text(profile.ageDisplay),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.cake,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(loc.t('profile_birthday')),
                        subtitle: Text(
                          '${profile.birthDate.year}-${profile.birthDate.month.toString().padLeft(2, '0')}-${profile.birthDate.day.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Capabilities section
                Text(
                  loc.t('profile_capabilities'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._buildCapabilityList(profile, loc, theme),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Statistics section
                Text(
                  loc.t('profile_stats'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),

                FutureBuilder<int>(
                  future: Future.value(ref.read(activityRepositoryProvider).totalActivitiesCount),
                  builder: (context, activitySnapshot) {
                    return FutureBuilder<int>(
                      future: ref.read(dailyPlanServiceProvider).getCurrentStreak(),
                      builder: (context, streakSnapshot) {
                        return Card(
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.check_circle_outline,
                                  color: theme.colorScheme.primary,
                                ),
                                title: Text(loc.t('profile_total_activities')),
                                trailing: Text(
                                  '${activitySnapshot.data ?? 0}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.local_fire_department,
                                  color: theme.colorScheme.primary,
                                ),
                                title: Text(loc.t('profile_current_streak')),
                                trailing: Text(
                                  '${streakSnapshot.data ?? 0} ${loc.t('profile_days')}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                // App settings section
                Text(
                  loc.t('profile_app_settings'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.palette_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(loc.t('profile_theme')),
                        trailing: DropdownButton<AppThemeMode>(
                          value: themeMode,
                          onChanged: (value) {
                            if (value != null) {
                              ref.read(themeModeProvider.notifier).setThemeMode(value);
                            }
                          },
                          items: AppThemeMode.values.map((mode) {
                            String label;
                            switch (mode) {
                              case AppThemeMode.light:
                                label = loc.t('theme_light');
                                break;
                              case AppThemeMode.dark:
                                label = loc.t('theme_dark');
                                break;
                              case AppThemeMode.system:
                                label = loc.t('theme_system');
                                break;
                            }
                            return DropdownMenuItem(
                              value: mode,
                              child: Text(label),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // About section
                Text(
                  loc.t('profile_about'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(loc.t('profile_version')),
                    subtitle: const Text('1.0.0 (MVP)'),
                  ),
                ),

                const SizedBox(height: 24),

                // Reset data button
                OutlinedButton.icon(
                  onPressed: () => _showResetDataDialog(context, ref, loc),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(loc.t('profile_reset_data')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildCapabilityList(BabyProfile profile, dynamic loc, ThemeData theme) {
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

    final achieved = capabilities
        .where((cap) => profile.capabilities[cap.$1] == true)
        .toList();

    if (achieved.isEmpty) {
      return [
        Text(
          'No milestones recorded yet',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ];
    }

    return achieved.map((cap) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                loc.t(cap.$2),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Future<void> _showResetDataDialog(BuildContext context, WidgetRef ref, dynamic loc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.t('profile_reset_data')),
        content: Text(loc.t('profile_reset_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.t('profile_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(loc.t('profile_delete')),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Delete all data
      await ref.read(profileRepositoryProvider).deleteProfile();
      await ref.read(dailyPlanRepositoryProvider).deletePlan('all'); // This will need adjustment
      await ref.read(skillScoreServiceProvider).resetAllScores();

      // Navigate back to onboarding
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/onboarding/welcome', (route) => false);
      }
    }
  }
}

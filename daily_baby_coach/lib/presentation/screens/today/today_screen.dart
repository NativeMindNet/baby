import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/baby_profile.dart';
import '../../providers/localization_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/today_provider.dart';
import '../../widgets/task_card.dart';

/// Today screen - main screen showing daily plan
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  bool _isToughDayMode = false;

  @override
  void initState() {
    super.initState();
    // Load today's plan on init
    Future.microtask(() => ref.read(todayProvider.notifier).loadTodaysPlan());
  }

  Future<void> _toggleToughDayMode(bool value) async {
    setState(() {
      _isToughDayMode = value;
    });

    await ref.read(todayProvider.notifier).regeneratePlan(
          isToughDayMode: value,
        );
  }

  Future<void> _onTaskTap(String taskId) async {
    // Navigate to task detail screen (Phase 5)
    // For now, just show a placeholder dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Task Detail'),
        content: const Text('Task flow coming in Phase 5'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(localizationServiceProvider);
    final theme = Theme.of(context);
    final todayState = ref.watch(todayProvider);
    final profileAsync = ref.watch(profileRepositoryProvider).getProfile();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('today_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to profile (Phase 6)
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Profile'),
                  content: const Text('Profile screen coming in Phase 6'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(todayProvider.notifier).refresh(),
        child: todayState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : todayState.error != null
                ? _buildErrorState(todayState.error!)
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Baby age card
                        FutureBuilder<BabyProfile?>(
                          future: profileAsync,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              final profile = snapshot.data!;
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.child_care,
                                        size: 32,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            loc.t('today_baby_age'),
                                            style: theme.textTheme.bodySmall,
                                          ),
                                          Text(
                                            profile.ageDisplay,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),

                        const SizedBox(height: 16),

                        // Tough day mode toggle
                        Card(
                          child: SwitchListTile(
                            title: Text(loc.t('today_tough_day_mode')),
                            subtitle: Text(loc.t('today_tough_day_hint')),
                            value: _isToughDayMode,
                            onChanged: _toggleToughDayMode,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Plan header
                        if (todayState.plan != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                loc.t('today_tasks_label'),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${todayState.plan!.completedCount}/${todayState.plan!.taskCount} ${loc.t('today_progress')}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Completed message
                          if (todayState.plan!.isComplete)
                            Card(
                              color: theme.colorScheme.primaryContainer,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.celebration,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        loc.t('today_completed'),
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: theme.colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 8),

                          // Task cards
                          ...todayState.tasks.map((task) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: TaskCard(
                                  task: task,
                                  plan: todayState.plan!,
                                  onTap: () => _onTaskTap(task.id),
                                ),
                              )),
                        ] else
                          // No plan state
                          Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 32),
                                Icon(
                                  Icons.event_note,
                                  size: 64,
                                  color: theme.colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  loc.t('today_no_plan'),
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: () {
                                    ref.read(todayProvider.notifier).loadTodaysPlan(
                                          isToughDayMode: _isToughDayMode,
                                        );
                                  },
                                  child: Text(loc.t('today_generate_plan')),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final loc = ref.watch(localizationServiceProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            loc.t('error'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => ref.read(todayProvider.notifier).refresh(),
            child: Text(loc.t('retry')),
          ),
        ],
      ),
    );
  }
}

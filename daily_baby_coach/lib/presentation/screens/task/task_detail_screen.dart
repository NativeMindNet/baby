import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/task.dart';
import '../../providers/localization_provider.dart';
import '../../providers/task_timer_provider.dart';
import 'feedback_screen.dart';

/// Task detail screen showing steps and timer
class TaskDetailScreen extends ConsumerWidget {
  final Task task;
  final String planId;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.planId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(localizationServiceProvider);
    final theme = Theme.of(context);
    final timerState = ref.watch(taskTimerProvider);

    // Get skill color
    final skillColor = Color(
      int.parse(task.category.colorHex.substring(1), radix: 16) + 0xFF000000,
    );

    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation if timer is running
        if (timerState.status == TimerStatus.running ||
            timerState.status == TimerStatus.paused) {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(loc.t('finish_early')),
              content: const Text('Are you sure you want to exit? Your progress will be lost.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(taskTimerProvider.notifier).reset();
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Exit'),
                ),
              ],
            ),
          );
          return shouldExit ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.t('task_detail_title')),
          backgroundColor: skillColor,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Task header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Skill badge
                      Row(
                        children: [
                          Text(
                            task.category.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            loc.t('skill_${task.category.name}'),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: skillColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Task title
                      Text(
                        loc.t(task.titleKey),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Duration
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${task.durationMinutes} ${loc.t('minutes_short')}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Timer display (when running)
              if (timerState.status != TimerStatus.idle) ...[
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          timerState.formattedTime,
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.t('task_timer_running'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Steps
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.t('task_steps_label'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...task.stepKeys.asMap().entries.map((entry) {
                        final index = entry.key;
                        final stepKey = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: skillColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  loc.t(stepKey),
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Stop condition
              if (task.stopIfKey != null)
                Card(
                  color: theme.colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_outlined,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.t('task_stop_if_label'),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                loc.t(task.stopIfKey!),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Action buttons
              if (timerState.status == TimerStatus.idle)
                FilledButton(
                  onPressed: () {
                    ref.read(taskTimerProvider.notifier).start();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      loc.t('task_start'),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                )
              else if (timerState.status == TimerStatus.running)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(taskTimerProvider.notifier).pause();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(loc.t('pause')),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: () => _finishTask(context, ref),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(loc.t('finish')),
                        ),
                      ),
                    ),
                  ],
                )
              else if (timerState.status == TimerStatus.paused)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(taskTimerProvider.notifier).reset();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: const Text('Reset'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(taskTimerProvider.notifier).resume();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(loc.t('resume')),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _finishTask(context, ref),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(loc.t('finish')),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _finishTask(BuildContext context, WidgetRef ref) {
    final timerState = ref.read(taskTimerProvider);
    ref.read(taskTimerProvider.notifier).complete();

    // Navigate to feedback screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => FeedbackScreen(
          task: task,
          planId: planId,
          elapsedMinutes: timerState.elapsedMinutes,
        ),
      ),
    );
  }
}

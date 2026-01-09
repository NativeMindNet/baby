import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/daily_plan.dart';
import '../../domain/models/task.dart';
import '../providers/localization_provider.dart';

/// Card displaying a single task with completion status
class TaskCard extends ConsumerWidget {
  final Task task;
  final DailyPlan plan;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.plan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(localizationServiceProvider);
    final theme = Theme.of(context);
    final isCompleted = plan.isTaskCompleted(task.id);

    // Get skill color
    final skillColor = Color(int.parse(task.category.colorHex.substring(1), radix: 16) + 0xFF000000);

    return Card(
      elevation: isCompleted ? 0 : 2,
      child: InkWell(
        onTap: isCompleted ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Completion checkbox
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted ? skillColor : theme.colorScheme.outline,
                    width: 2,
                  ),
                  color: isCompleted ? skillColor : Colors.transparent,
                ),
                child: isCompleted
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: theme.colorScheme.onPrimary,
                      )
                    : null,
              ),

              const SizedBox(width: 16),

              // Task details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task title
                    Text(
                      loc.t(task.titleKey),
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                            : null,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Skill category and duration
                    Row(
                      children: [
                        // Skill icon
                        Text(
                          task.category.icon,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          loc.t('skill_${task.category.name}'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: skillColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${task.durationMinutes} ${loc.t('minutes_short')}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow indicator
              if (!isCompleted)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

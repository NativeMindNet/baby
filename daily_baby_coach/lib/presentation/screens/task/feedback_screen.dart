import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/models/activity_result.dart';
import '../../../domain/models/feedback_score.dart';
import '../../../domain/models/task.dart';
import '../../providers/localization_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/task_timer_provider.dart';
import '../../providers/today_provider.dart';

/// Feedback collection screen after completing a task
class FeedbackScreen extends ConsumerStatefulWidget {
  final Task task;
  final String planId;
  final int elapsedMinutes;

  const FeedbackScreen({
    super.key,
    required this.task,
    required this.planId,
    required this.elapsedMinutes,
  });

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  FeedbackScore? _selectedFeedback;
  int? _actualDuration;
  final _commentController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _actualDuration = widget.elapsedMinutes;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_selectedFeedback == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select how the activity went')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final profile = await profileRepo.getProfile();

      if (profile == null) {
        throw Exception('Profile not found');
      }

      // Create activity result
      final result = ActivityResult(
        id: const Uuid().v4(),
        taskId: widget.task.id,
        completedAt: DateTime.now(),
        feedback: _selectedFeedback!,
        actualDurationMinutes: _actualDuration ?? widget.elapsedMinutes,
        comment: _commentController.text.isNotEmpty ? _commentController.text : null,
        babyAgeDays: profile.ageDays,
      );

      // Save activity result
      final activityRepo = ref.read(activityRepositoryProvider);
      await activityRepo.recordResult(result);

      // Update skill score
      final skillScoreService = ref.read(skillScoreServiceProvider);
      await skillScoreService.updateScoreAfterActivity(result);

      // Mark task as completed in plan
      await ref.read(todayProvider.notifier).markTaskCompleted(widget.task.id);

      // Reset timer
      ref.read(taskTimerProvider.notifier).reset();

      if (mounted) {
        // Navigate back to Today screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving feedback: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(localizationServiceProvider);
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation without submitting
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard feedback?'),
            content: const Text('Are you sure you want to exit without saving feedback?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Discard'),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.t('feedback_title')),
          automaticallyImplyLeading: false,
        ),
        body: _isSaving
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Task summary
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Text(
                              widget.task.category.icon,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                loc.t(widget.task.titleKey),
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Feedback question
                    Text(
                      loc.t('feedback_title'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Feedback options
                    ...FeedbackScore.values.map((score) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _FeedbackOption(
                          score: score,
                          label: _getFeedbackLabel(loc, score),
                          icon: _getFeedbackIcon(score),
                          isSelected: _selectedFeedback == score,
                          onTap: () {
                            setState(() {
                              _selectedFeedback = score;
                            });
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Duration adjustment
                    Text(
                      loc.t('feedback_duration'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        IconButton(
                          onPressed: _actualDuration != null && _actualDuration! > 1
                              ? () {
                                  setState(() {
                                    _actualDuration = _actualDuration! - 1;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              '${_actualDuration ?? widget.elapsedMinutes} ${loc.t('minutes_short')}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _actualDuration = (_actualDuration ?? widget.elapsedMinutes) + 1;
                            });
                          },
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Optional comment
                    TextField(
                      controller: _commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: loc.t('feedback_comment_placeholder'),
                        border: const OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit button
                    FilledButton(
                      onPressed: _submitFeedback,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          loc.t('feedback_done'),
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

  String _getFeedbackLabel(dynamic loc, FeedbackScore score) {
    switch (score) {
      case FeedbackScore.easy:
        return loc.t('feedback_easy');
      case FeedbackScore.normal:
        return loc.t('feedback_normal');
      case FeedbackScore.hard:
        return loc.t('feedback_hard');
      case FeedbackScore.didNotWork:
        return loc.t('feedback_failed');
    }
  }

  IconData _getFeedbackIcon(FeedbackScore score) {
    switch (score) {
      case FeedbackScore.easy:
        return Icons.sentiment_very_satisfied;
      case FeedbackScore.normal:
        return Icons.sentiment_satisfied;
      case FeedbackScore.hard:
        return Icons.sentiment_dissatisfied;
      case FeedbackScore.didNotWork:
        return Icons.sentiment_very_dissatisfied;
    }
  }
}

/// Feedback option widget
class _FeedbackOption extends StatelessWidget {
  final FeedbackScore score;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FeedbackOption({
    required this.score,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? theme.colorScheme.onPrimaryContainer : null,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

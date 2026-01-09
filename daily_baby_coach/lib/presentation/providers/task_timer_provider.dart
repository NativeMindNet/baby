import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Timer state
enum TimerStatus { idle, running, paused, completed }

/// State for task timer
class TaskTimerState {
  final int elapsedSeconds;
  final TimerStatus status;

  const TaskTimerState({
    this.elapsedSeconds = 0,
    this.status = TimerStatus.idle,
  });

  TaskTimerState copyWith({
    int? elapsedSeconds,
    TimerStatus? status,
  }) {
    return TaskTimerState(
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      status: status ?? this.status,
    );
  }

  /// Format elapsed time as MM:SS
  String get formattedTime {
    final minutes = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Get elapsed minutes (for feedback)
  int get elapsedMinutes => (elapsedSeconds / 60).ceil();
}

/// State notifier for task timer
class TaskTimerNotifier extends StateNotifier<TaskTimerState> {
  Timer? _timer;

  TaskTimerNotifier() : super(const TaskTimerState());

  /// Start the timer
  void start() {
    if (state.status == TimerStatus.running) return;

    state = state.copyWith(status: TimerStatus.running);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(
        elapsedSeconds: state.elapsedSeconds + 1,
      );
    });
  }

  /// Pause the timer
  void pause() {
    if (state.status != TimerStatus.running) return;

    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.paused);
  }

  /// Resume the timer
  void resume() {
    if (state.status != TimerStatus.paused) return;
    start();
  }

  /// Stop and complete the timer
  void complete() {
    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.completed);
  }

  /// Reset the timer
  void reset() {
    _timer?.cancel();
    state = const TaskTimerState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provider for task timer
final taskTimerProvider = StateNotifierProvider<TaskTimerNotifier, TaskTimerState>((ref) {
  return TaskTimerNotifier();
});

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PomodoroState { idle, running, paused, completed }

class PomodoroTimer extends StateNotifier<PomodoroState> {
  Timer? _timer;
  int _remainingSeconds = 25 * 60; // 25 minutes default
  int _workDuration = 25 * 60;
  int _shortBreakDuration = 5 * 60;
  int _longBreakDuration = 15 * 60;
  int _completedPomodoros = 0;
  bool _isBreak = false;

  PomodoroTimer() : super(PomodoroState.idle);

  int get remainingSeconds => _remainingSeconds;
  int get completedPomodoros => _completedPomodoros;
  bool get isBreak => _isBreak;

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void start() {
    if (state == PomodoroState.running) return;
    
    state = PomodoroState.running;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
      } else {
        _onComplete();
      }
    });
  }

  void pause() {
    if (state != PomodoroState.running) return;
    state = PomodoroState.paused;
    _timer?.cancel();
  }

  void resume() {
    if (state != PomodoroState.paused) return;
    start();
  }

  void reset() {
    _timer?.cancel();
    state = PomodoroState.idle;
    _remainingSeconds = _workDuration;
    _isBreak = false;
  }

  void setWorkDuration(int minutes) {
    _workDuration = minutes * 60;
    if (state == PomodoroState.idle && !_isBreak) {
      _remainingSeconds = _workDuration;
    }
  }

  void setShortBreakDuration(int minutes) {
    _shortBreakDuration = minutes * 60;
  }

  void setLongBreakDuration(int minutes) {
    _longBreakDuration = minutes * 60;
  }

  void _onComplete() {
    _timer?.cancel();
    state = PomodoroState.completed;
    
    if (!_isBreak) {
      _completedPomodoros++;
      // After 4 pomodoros, take long break, otherwise short break
      if (_completedPomodoros % 4 == 0) {
        _remainingSeconds = _longBreakDuration;
        _isBreak = true;
      } else {
        _remainingSeconds = _shortBreakDuration;
        _isBreak = true;
      }
    } else {
      // Break completed, start work session
      _remainingSeconds = _workDuration;
      _isBreak = false;
    }
  }

  void startBreak() {
    reset();
    _isBreak = true;
    if (_completedPomodoros % 4 == 0) {
      _remainingSeconds = _longBreakDuration;
    } else {
      _remainingSeconds = _shortBreakDuration;
    }
    start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final pomodoroProvider = StateNotifierProvider<PomodoroTimer, PomodoroState>((ref) {
  return PomodoroTimer();
});

final pomodoroTimeProvider = Provider<String>((ref) {
  final timer = ref.watch(pomodoroProvider.notifier);
  return timer.formattedTime;
});

final pomodoroCompletedProvider = Provider<int>((ref) {
  final timer = ref.watch(pomodoroProvider.notifier);
  return timer.completedPomodoros;
});

final pomodoroIsBreakProvider = Provider<bool>((ref) {
  final timer = ref.watch(pomodoroProvider.notifier);
  return timer.isBreak;
});


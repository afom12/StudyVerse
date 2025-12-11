import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final repo = TaskRepository();
  repo.init();
  return repo;
});

final tasksProvider = StreamProvider<List<TaskModel>>((ref) {
  return ref.watch(taskRepositoryProvider).watchTasks();
});

final todayTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  return await ref.watch(taskRepositoryProvider).getTodayTasks();
});

final taskStatsProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  
  return tasksAsync.when(
    data: (tasks) {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      final todayTasks = tasks.where((task) {
        if (task.completed) return false;
        if (task.dueDate == null) return false;
        final dueDate = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        return dueDate.isAtSameMomentAs(todayStart) || dueDate.isBefore(todayStart);
      }).length;
      
      final totalPending = tasks.where((t) => !t.completed).length;
      
      return AsyncValue.data({
        'today': todayTasks,
        'pending': totalPending,
      });
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});


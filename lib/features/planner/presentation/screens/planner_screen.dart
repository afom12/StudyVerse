import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/task_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/task_provider.dart';
import '../providers/pomodoro_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final pomodoroState = ref.watch(pomodoroProvider);
    final pomodoroTimer = ref.watch(pomodoroProvider.notifier);
    final time = ref.watch(pomodoroTimeProvider);
    final completedPomodoros = ref.watch(pomodoroCompletedProvider);
    final isBreak = ref.watch(pomodoroIsBreakProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Planner'),
      ),
      body: Column(
        children: [
          // Tasks Section
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                final todayTasks = tasks.where((t) {
                  if (t.completed) return false;
                  if (t.dueDate == null) return true;
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final dueDate = DateTime(
                    t.dueDate!.year,
                    t.dueDate!.month,
                    t.dueDate!.day,
                  );
                  return dueDate.isAtSameMomentAs(today) || dueDate.isBefore(today);
                }).toList();

                if (todayTasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks for today',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add a task to get started',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      "Today's Tasks",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ...todayTasks.map((task) => _TaskCard(
                      task: task,
                      onToggle: (completed) async {
                        await ref.read(taskRepositoryProvider).toggleTaskComplete(task.id, completed);
                      },
                      onTap: () => _showTaskDetails(context, ref, task),
                    )),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text('Error: $err'),
              ),
            ),
          ),
          // Pomodoro Timer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isBreak)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Break Time',
                          style: TextStyle(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Focus Time',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  time,
                  style: GoogleFonts.robotoMono(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: isBreak ? AppTheme.accentColor : AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completed: $completedPomodoros',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (pomodoroState == PomodoroState.running)
                      IconButton(
                        icon: const Icon(Icons.pause),
                        iconSize: 48,
                        onPressed: () => pomodoroTimer.pause(),
                        color: AppTheme.primaryColor,
                      )
                    else if (pomodoroState == PomodoroState.paused)
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        iconSize: 48,
                        onPressed: () => pomodoroTimer.resume(),
                        color: AppTheme.primaryColor,
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        iconSize: 48,
                        onPressed: () => pomodoroTimer.start(),
                        color: AppTheme.primaryColor,
                      ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.stop),
                      iconSize: 32,
                      onPressed: () => pomodoroTimer.reset(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter task title',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Enter task description',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskPriority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: TaskPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(priority.toString().split('.').last.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedPriority = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(selectedDate == null
                      ? 'No due date'
                      : 'Due: ${selectedDate!.toString().split(' ')[0]}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                
                try {
                  await ref.read(taskRepositoryProvider).createTask(
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim(),
                        dueDate: selectedDate,
                        priority: selectedPriority,
                      );
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task created!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetails(BuildContext context, WidgetRef ref, TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null) ...[
              Text(task.description!),
              const SizedBox(height: 16),
            ],
            Text('Priority: ${task.priority.toString().split('.').last}'),
            if (task.dueDate != null)
              Text('Due: ${task.dueDate!.toString().split(' ')[0]}'),
            Text('Status: ${task.completed ? "Completed" : "Pending"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (!task.completed)
            ElevatedButton(
              onPressed: () async {
                await ref.read(taskRepositoryProvider).toggleTaskComplete(task.id, true);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Mark Complete'),
            ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final Function(bool) onToggle;
  final VoidCallback onTap;

  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Checkbox(
          value: task.completed,
          onChanged: (value) => onToggle(value ?? false),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null) Text(task.description!),
            if (task.dueDate != null)
              Text(
                'Due: ${task.dueDate!.toString().split(' ')[0]}',
                style: TextStyle(
                  color: task.dueDate!.isBefore(DateTime.now()) && !task.completed
                      ? Colors.red
                      : null,
                ),
              ),
          ],
        ),
        trailing: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getPriorityColor(),
            shape: BoxShape.circle,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../planner/presentation/providers/task_provider.dart';
import '../../../flashcards/presentation/providers/flashcard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final taskStats = ref.watch(taskStatsProvider);
    final dueCardsAsync = ref.watch(dueCardsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, ${user?.name.split(' ').first ?? 'Student'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push('/search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(tasksProvider);
          ref.invalidate(dueCardsCountProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's Overview Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Overview",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: taskStats.when(
                              data: (stats) => _StatCard(
                                icon: Icons.assignment_outlined,
                                label: 'Tasks',
                                value: '${stats['today'] ?? 0}',
                                color: Colors.blue,
                              ),
                              loading: () => const _StatCard(
                                icon: Icons.assignment_outlined,
                                label: 'Tasks',
                                value: '...',
                                color: Colors.blue,
                              ),
                              error: (_, __) => const _StatCard(
                                icon: Icons.assignment_outlined,
                                label: 'Tasks',
                                value: '0',
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: dueCardsAsync.when(
                              data: (count) => _StatCard(
                                icon: Icons.style_outlined,
                                label: 'Cards Due',
                                value: '$count',
                                color: Colors.orange,
                              ),
                              loading: () => const _StatCard(
                                icon: Icons.style_outlined,
                                label: 'Cards Due',
                                value: '...',
                                color: Colors.orange,
                              ),
                              error: (_, __) => const _StatCard(
                                icon: Icons.style_outlined,
                                label: 'Cards Due',
                                value: '0',
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Courses Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Courses',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => context.push('/courses'),
                    child: const Text('See All'),
                  ),
                ],
              ),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _CourseCard(
                        title: 'Course ${index + 1}',
                        onTap: () {
                          // TODO: Navigate to course detail
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Recent Notes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Notes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => context.push('/notes'),
                    child: const Text('See All'),
                  ),
                ],
              ),
              // TODO: Load actual notes
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No notes yet. Create your first note!'),
                ),
              ),
              const SizedBox(height: 24),
              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _QuickActionCard(
                    icon: Icons.note_add_outlined,
                    label: 'New Note',
                    color: Colors.blue,
                    onTap: () => context.push('/notes/new'),
                  ),
                  _QuickActionCard(
                    icon: Icons.style_outlined,
                    label: 'New Deck',
                    color: Colors.orange,
                    onTap: () => context.push('/flashcards'),
                  ),
                  _QuickActionCard(
                    icon: Icons.group_add_outlined,
                    label: 'Join Group',
                    color: Colors.green,
                    onTap: () => context.push('/groups'),
                  ),
                  _QuickActionCard(
                    icon: Icons.timer_outlined,
                    label: 'Pomodoro',
                    color: Colors.purple,
                    onTap: () => context.push('/planner'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateMenu(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.note_add_outlined),
                title: const Text('New Note'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/notes/new');
                },
              ),
              ListTile(
                leading: const Icon(Icons.style_outlined),
                title: const Text('New Flashcard Deck'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/flashcards');
                },
              ),
              ListTile(
                leading: const Icon(Icons.school_outlined),
                title: const Text('New Course'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/courses');
                },
              ),
              ListTile(
                leading: const Icon(Icons.group_add_outlined),
                title: const Text('Create Study Group'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/groups');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _CourseCard({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.school_outlined,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


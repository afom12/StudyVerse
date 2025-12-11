import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../notes/presentation/providers/note_provider.dart';
import '../../../courses/presentation/providers/course_provider.dart';
import '../../../flashcards/presentation/providers/flashcard_deck_provider.dart';
import '../../../planner/presentation/providers/task_provider.dart';
import '../../../pdf/presentation/providers/pdf_provider.dart';
import '../../../../core/models/note_model.dart';
import '../../../../core/models/course_model.dart';
import '../../../../core/models/flashcard_model.dart';
import '../../../../core/models/task_model.dart';
import '../../../../core/models/pdf_model.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  SearchCategory _selectedCategory = SearchCategory.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search notes, courses, flashcards...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase().trim();
            });
          },
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: SearchCategory.values.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_getCategoryLabel(category)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          // Search Results
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildEmptyState()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Start searching',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search across notes, courses, flashcards, tasks, and PDFs',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Consumer(
      builder: (context, ref, child) {
        final notesAsync = ref.watch(notesProvider(null));
        final coursesAsync = ref.watch(coursesProvider);
        final decksAsync = ref.watch(flashcardDecksProvider(null));
        final tasksAsync = ref.watch(tasksProvider);
        final pdfsAsync = ref.watch(pdfsProvider(null));

        // Check if any provider is loading
        if (notesAsync.isLoading || coursesAsync.isLoading || 
            decksAsync.isLoading || tasksAsync.isLoading || pdfsAsync.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = SearchResults();

        // Search Notes
        if (_selectedCategory == SearchCategory.all || _selectedCategory == SearchCategory.notes) {
          final notes = notesAsync.value ?? [];
          results.notes = notes.where((note) {
            return note.title.toLowerCase().contains(_searchQuery);
          }).toList();
        }

        // Search Courses
        if (_selectedCategory == SearchCategory.all || _selectedCategory == SearchCategory.courses) {
          final courses = coursesAsync.value ?? [];
          results.courses = courses.where((course) {
            return course.title.toLowerCase().contains(_searchQuery) ||
                (course.instructor?.toLowerCase().contains(_searchQuery) ?? false);
          }).toList();
        }

        // Search Flashcard Decks
        if (_selectedCategory == SearchCategory.all || _selectedCategory == SearchCategory.flashcards) {
          final decks = decksAsync.value ?? [];
          results.decks = decks.where((deck) {
            return deck.title.toLowerCase().contains(_searchQuery) ||
                (deck.description?.toLowerCase().contains(_searchQuery) ?? false);
          }).toList();
        }

        // Search Tasks
        if (_selectedCategory == SearchCategory.all || _selectedCategory == SearchCategory.tasks) {
          final tasks = tasksAsync.value ?? [];
          results.tasks = tasks.where((task) {
            return task.title.toLowerCase().contains(_searchQuery) ||
                (task.description?.toLowerCase().contains(_searchQuery) ?? false);
          }).toList();
        }

        // Search PDFs
        if (_selectedCategory == SearchCategory.all || _selectedCategory == SearchCategory.pdfs) {
          final pdfs = pdfsAsync.value ?? [];
          results.pdfs = pdfs.where((pdf) {
            return pdf.title.toLowerCase().contains(_searchQuery);
          }).toList();
        }
        final allResults = [
          ...results.notes.map((e) => _SearchResultItem(
                type: SearchResultType.note,
                title: e.title,
                subtitle: e.courseId,
                onTap: () => context.push('/notes/${e.id}/edit?courseId=${e.courseId ?? ''}'),
              )),
          ...results.courses.map((e) => _SearchResultItem(
                type: SearchResultType.course,
                title: e.title,
                subtitle: e.instructor ?? 'Course',
                onTap: () => context.push('/courses/${e.id}'),
              )),
          ...results.decks.map((e) => _SearchResultItem(
                type: SearchResultType.deck,
                title: e.title,
                subtitle: e.description ?? 'Flashcard Deck',
                onTap: () => context.push('/flashcards/decks/${e.id}'),
              )),
          ...results.tasks.map((e) => _SearchResultItem(
                type: SearchResultType.task,
                title: e.title,
                subtitle: e.description ?? 'Task',
                onTap: () => context.push('/planner'),
              )),
          ...results.pdfs.map((e) => _SearchResultItem(
                type: SearchResultType.pdf,
                title: e.title,
                subtitle: 'PDF Document',
                onTap: () => context.push('/pdf/${e.id}'),
              )),
        ];

        if (allResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No results found',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different search term',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: allResults.length,
          itemBuilder: (context, index) {
            final item = allResults[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(_getResultIcon(item.type)),
                title: Text(item.title),
                subtitle: Text(item.subtitle ?? ''),
                trailing: const Icon(Icons.chevron_right),
                onTap: item.onTap,
              ),
            );
          },
        );
      },
    );
  }

  IconData _getResultIcon(SearchResultType type) {
    switch (type) {
      case SearchResultType.note:
        return Icons.note_outlined;
      case SearchResultType.course:
        return Icons.school_outlined;
      case SearchResultType.deck:
        return Icons.style_outlined;
      case SearchResultType.task:
        return Icons.assignment_outlined;
      case SearchResultType.pdf:
        return Icons.picture_as_pdf_outlined;
    }
  }

  String _getCategoryLabel(SearchCategory category) {
    switch (category) {
      case SearchCategory.all:
        return 'All';
      case SearchCategory.notes:
        return 'Notes';
      case SearchCategory.courses:
        return 'Courses';
      case SearchCategory.flashcards:
        return 'Flashcards';
      case SearchCategory.tasks:
        return 'Tasks';
      case SearchCategory.pdfs:
        return 'PDFs';
    }
  }
}

enum SearchCategory {
  all,
  notes,
  courses,
  flashcards,
  tasks,
  pdfs,
}

enum SearchResultType {
  note,
  course,
  deck,
  task,
  pdf,
}

class SearchResults {
  List<NoteModel> notes = [];
  List<CourseModel> courses = [];
  List<FlashcardDeckModel> decks = [];
  List<TaskModel> tasks = [];
  List<PDFModel> pdfs = [];

  SearchResults();

  SearchResults.empty();

  int get totalCount => notes.length + courses.length + decks.length + tasks.length + pdfs.length;
}

class _SearchResultItem {
  final SearchResultType type;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  _SearchResultItem({
    required this.type,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/course_provider.dart';
import '../../../notes/presentation/screens/notes_list_screen.dart';
import '../../../flashcards/presentation/screens/decks_list_screen.dart';
import '../../../pdf/presentation/providers/pdf_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class CourseDetailScreen extends ConsumerWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseProvider(courseId));

    return courseAsync.when(
      data: (course) {
        if (course == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Course Not Found')),
            body: const Center(child: Text('Course not found')),
          );
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(course.title),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.note_outlined), text: 'Notes'),
                  Tab(icon: Icon(Icons.picture_as_pdf_outlined), text: 'PDFs'),
                  Tab(icon: Icon(Icons.style_outlined), text: 'Flashcards'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                NotesListScreen(courseId: courseId),
                _PDFsTab(courseId: courseId),
                DecksListScreen(courseId: courseId),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showCreateMenu(context, ref, courseId),
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showCreateMenu(BuildContext context, WidgetRef ref, String courseId) {
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
                  context.push('/notes/new?courseId=$courseId');
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Upload PDF'),
                onTap: () async {
                  Navigator.pop(context);
                  await _uploadPDF(context, ref, courseId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.style_outlined),
                title: const Text('New Flashcard Deck'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/flashcards?courseId=$courseId');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadPDF(BuildContext context, WidgetRef ref, String courseId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      // Show title input dialog
      final titleController = TextEditingController(text: fileName.replaceAll('.pdf', ''));

      final shouldUpload = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Upload PDF'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'PDF Title',
              hintText: 'Enter a title for this PDF',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Upload'),
            ),
          ],
        ),
      );

      if (shouldUpload != true || titleController.text.trim().isEmpty) return;
      if (!context.mounted) return;

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Uploading PDF...'),
            ],
          ),
        ),
      );

      try {
        await ref.read(pdfRepositoryProvider).uploadPDF(
              courseId: courseId,
              title: titleController.text.trim(),
              file: file,
            );

        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF uploaded successfully!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading PDF: $e')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _PDFsTab extends ConsumerWidget {
  final String courseId;

  const _PDFsTab({required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pdfsAsync = ref.watch(pdfsProvider(courseId));

    return pdfsAsync.when(
      data: (pdfs) {
        if (pdfs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.picture_as_pdf_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No PDFs yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload PDFs to view them here',
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
          itemCount: pdfs.length,
          itemBuilder: (context, index) {
            final pdf = pdfs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(pdf.title),
                subtitle: Text('Uploaded ${_formatDate(pdf.createdAt)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push('/pdf/${pdf.id}');
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}


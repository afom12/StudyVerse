import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/note_model.dart';
import '../providers/note_provider.dart';
import '../../../../features/courses/presentation/providers/course_provider.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;
  final String? courseId;

  const NoteEditorScreen({
    super.key,
    this.noteId,
    this.courseId,
  });

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late QuillController _controller;
  final _titleController = TextEditingController();
  bool _isLoading = true;
  bool _hasChanges = false;
  NoteModel? _currentNote;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
    _controller.document.changes.listen((event) {
      if (!_isLoading) {
        setState(() => _hasChanges = true);
      }
    });
    
    if (widget.noteId != null) {
      _loadNote();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadNote() async {
    if (widget.noteId == null) return;
    
    final noteAsync = ref.read(noteProvider(widget.noteId!));
    noteAsync.whenData((note) {
      if (note != null) {
        setState(() {
          _currentNote = note;
          _titleController.text = note.title;
          final ops = note.content['ops'];
          if (ops is List) {
            _controller.document = Document.fromJson(ops);
          } else {
            _controller.document = Document();
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (widget.courseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course is required')),
      );
      return;
    }

    try {
      final delta = _controller.document.toDelta();
      final content = {'ops': delta.toJson()};
      
      if (_currentNote == null) {
        // Create new note
        await ref.read(noteRepositoryProvider).createNote(
              courseId: widget.courseId!,
              title: _titleController.text.trim(),
              content: content,
            );
      } else {
        // Update existing note
        final updatedNote = NoteModel(
          id: _currentNote!.id,
          courseId: _currentNote!.courseId,
          ownerId: _currentNote!.ownerId,
          title: _titleController.text.trim(),
          content: content,
          attachments: _currentNote!.attachments,
          createdAt: _currentNote!.createdAt,
          updatedAt: DateTime.now(),
        );
        await ref.read(noteRepositoryProvider).updateNote(updatedNote);
      }

      if (mounted) {
        setState(() => _hasChanges = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note saved')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = widget.courseId != null
        ? ref.watch(courseProvider(widget.courseId!))
        : null;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) async {
        if (_hasChanges && !didPop) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Unsaved Changes'),
              content: const Text('You have unsaved changes. Do you want to discard them?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                    if (context.mounted) context.pop();
                  },
                  child: const Text('Discard'),
                ),
              ],
            ),
          );
          if (shouldPop == true && context.mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Note title',
                  border: InputBorder.none,
                ),
                style: Theme.of(context).textTheme.titleLarge,
                onChanged: (_) => setState(() => _hasChanges = true),
              ),
              if (courseAsync?.value != null)
                Text(
                  courseAsync!.value!.title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          actions: [
            if (_hasChanges)
              IconButton(
                icon: const Icon(Icons.save_outlined),
                onPressed: _saveNote,
                tooltip: 'Save',
              ),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'convert',
                  child: Text('Convert to Flashcards'),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Text('Share to Group'),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Text('Export PDF'),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            QuillToolbar.simple(
              configurations: QuillSimpleToolbarConfigurations(
                controller: _controller,
                sharedConfigurations: const QuillSharedConfigurations(),
              ),
            ),
            Expanded(
              child: QuillEditor.basic(
                configurations: QuillEditorConfigurations(
                  controller: _controller,
                  placeholder: 'Start writing...',
                  sharedConfigurations: const QuillSharedConfigurations(),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _saveNote,
          child: const Icon(Icons.save),
        ),
      ),
    );
  }
}


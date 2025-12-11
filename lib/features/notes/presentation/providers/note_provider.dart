import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/note_model.dart';
import '../../data/repositories/note_repository.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final repo = NoteRepository();
  repo.init();
  return repo;
});

final notesProvider = StreamProvider.family<List<NoteModel>, String?>((ref, courseId) {
  return ref.watch(noteRepositoryProvider).watchNotes(courseId: courseId);
});

final noteProvider = FutureProvider.family<NoteModel?, String>((ref, noteId) async {
  return await ref.watch(noteRepositoryProvider).getNote(noteId);
});


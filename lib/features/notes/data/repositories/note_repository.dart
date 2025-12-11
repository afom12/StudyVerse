import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/models/note_model.dart';
import '../../../../services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class NoteRepository {
  static const String _boxName = 'notes';
  Box<Map>? _box;

  Future<void> init() async {
    if (_box == null) {
      _box = await Hive.openBox<Map>(_boxName);
    }
  }

  String? get _userId {
    try {
      return FirebaseService.currentUser?.uid;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveToLocal(NoteModel note) async {
    await init();
    await _box!.put(note.id, note.toJson());
  }

  Future<void> _deleteFromLocal(String noteId) async {
    await init();
    await _box!.delete(noteId);
  }

  List<NoteModel> _getFromLocal({String? courseId}) {
    if (_box == null) return [];
    return _box!.values
        .map((json) => NoteModel.fromJson(Map<String, dynamic>.from(json)))
        .where((note) {
          if (note.ownerId != _userId) return false;
          if (courseId != null && note.courseId != courseId) return false;
          return true;
        })
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> _saveToCloud(NoteModel note) async {
    if (!FirebaseService.isInitialized || _userId == null) return;
    
    try {
      await FirebaseService.firestore
          .collection('notes')
          .doc(note.id)
          .set(note.toJson());
    } catch (e) {
      print('Error saving note to cloud: $e');
    }
  }

  Future<void> _deleteFromCloud(String noteId) async {
    if (!FirebaseService.isInitialized || _userId == null) return;
    
    try {
      await FirebaseService.firestore.collection('notes').doc(noteId).delete();
    } catch (e) {
      print('Error deleting note from cloud: $e');
    }
  }

  Stream<List<NoteModel>> watchNotes({String? courseId}) {
    if (!FirebaseService.isInitialized || _userId == null) {
      return Stream.value(_getFromLocal(courseId: courseId));
    }

    try {
      Query query = FirebaseService.firestore
          .collection('notes')
          .where('ownerId', isEqualTo: _userId);
      
      if (courseId != null) {
        query = query.where('courseId', isEqualTo: courseId);
      }
      
      return query
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        final notes = snapshot.docs
            .map((doc) => NoteModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
        
        // Sync to local storage
        for (final note in notes) {
          _saveToLocal(note);
        }
        
        return notes;
      });
    } catch (e) {
      print('Error watching notes: $e');
      return Stream.value(_getFromLocal(courseId: courseId));
    }
  }

  Future<List<NoteModel>> getNotes({String? courseId}) async {
    if (!FirebaseService.isInitialized || _userId == null) {
      return _getFromLocal(courseId: courseId);
    }

    try {
      Query query = FirebaseService.firestore
          .collection('notes')
          .where('ownerId', isEqualTo: _userId);
      
      if (courseId != null) {
        query = query.where('courseId', isEqualTo: courseId);
      }
      
      final snapshot = await query.orderBy('updatedAt', descending: true).get();

      final notes = snapshot.docs
          .map((doc) => NoteModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Sync to local storage
      for (final note in notes) {
        await _saveToLocal(note);
      }

      return notes;
    } catch (e) {
      print('Error getting notes: $e');
      return _getFromLocal(courseId: courseId);
    }
  }

  Future<NoteModel> createNote({
    required String courseId,
    required String title,
    required Map<String, dynamic> content,
  }) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    final now = DateTime.now();
    final note = NoteModel(
      id: const Uuid().v4(),
      courseId: courseId,
      ownerId: _userId!,
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );

    await _saveToLocal(note);
    await _saveToCloud(note);

    return note;
  }

  Future<void> updateNote(NoteModel note) async {
    final updatedNote = NoteModel(
      id: note.id,
      courseId: note.courseId,
      ownerId: note.ownerId,
      title: note.title,
      content: note.content,
      attachments: note.attachments,
      createdAt: note.createdAt,
      updatedAt: DateTime.now(),
    );

    await _saveToLocal(updatedNote);
    await _saveToCloud(updatedNote);
  }

  Future<void> deleteNote(String noteId) async {
    await _deleteFromLocal(noteId);
    await _deleteFromCloud(noteId);
  }

  Future<NoteModel?> getNote(String noteId) async {
    if (!FirebaseService.isInitialized || _userId == null) {
      // Check local storage
      await init();
      final json = _box!.get(noteId);
      if (json != null) {
        return NoteModel.fromJson(Map<String, dynamic>.from(json));
      }
      return null;
    }

    try {
      final doc = await FirebaseService.firestore
          .collection('notes')
          .doc(noteId)
          .get();
      
      if (doc.exists) {
        final note = NoteModel.fromJson(doc.data()! as Map<String, dynamic>);
        await _saveToLocal(note);
        return note;
      }
      return null;
    } catch (e) {
      print('Error getting note: $e');
      // Fallback to local
      await init();
      final json = _box!.get(noteId);
      if (json != null) {
        return NoteModel.fromJson(Map<String, dynamic>.from(json));
      }
      return null;
    }
  }
}


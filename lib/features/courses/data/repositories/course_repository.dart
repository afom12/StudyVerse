import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/models/course_model.dart';
import '../../../../services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class CourseRepository {
  static const String _boxName = 'courses';
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

  Future<void> _saveToLocal(CourseModel course) async {
    await init();
    await _box!.put(course.id, course.toJson());
  }

  Future<void> _deleteFromLocal(String courseId) async {
    await init();
    await _box!.delete(courseId);
  }

  List<CourseModel> _getFromLocal() {
    if (_box == null) return [];
    return _box!.values
        .map((json) => CourseModel.fromJson(Map<String, dynamic>.from(json)))
        .where((course) => course.ownerId == _userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _saveToCloud(CourseModel course) async {
    if (!FirebaseService.isInitialized || _userId == null) return;
    
    try {
      await FirebaseService.firestore
          .collection('courses')
          .doc(course.id)
          .set(course.toJson());
    } catch (e) {
      print('Error saving course to cloud: $e');
    }
  }

  Future<void> _deleteFromCloud(String courseId) async {
    if (!FirebaseService.isInitialized || _userId == null) return;
    
    try {
      await FirebaseService.firestore.collection('courses').doc(courseId).delete();
    } catch (e) {
      print('Error deleting course from cloud: $e');
    }
  }

  Stream<List<CourseModel>> watchCourses() {
    if (!FirebaseService.isInitialized || _userId == null) {
      return Stream.value(_getFromLocal());
    }

    try {
      return FirebaseService.firestore
          .collection('courses')
          .where('ownerId', isEqualTo: _userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        final courses = snapshot.docs
            .map((doc) => CourseModel.fromJson(doc.data()))
            .toList();
        
        // Sync to local storage
        for (final course in courses) {
          _saveToLocal(course);
        }
        
        return courses;
      });
    } catch (e) {
      print('Error watching courses: $e');
      return Stream.value(_getFromLocal());
    }
  }

  Future<List<CourseModel>> getCourses() async {
    if (!FirebaseService.isInitialized || _userId == null) {
      return _getFromLocal();
    }

    try {
      final snapshot = await FirebaseService.firestore
          .collection('courses')
          .where('ownerId', isEqualTo: _userId)
          .orderBy('createdAt', descending: true)
          .get();

      final courses = snapshot.docs
          .map((doc) => CourseModel.fromJson(doc.data()))
          .toList();

      // Sync to local storage
      for (final course in courses) {
        await _saveToLocal(course);
      }

      return courses;
    } catch (e) {
      print('Error getting courses: $e');
      return _getFromLocal();
    }
  }

  Future<CourseModel> createCourse({
    required String title,
    String? instructor,
    int? semester,
  }) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    final course = CourseModel(
      id: const Uuid().v4(),
      ownerId: _userId!,
      title: title,
      instructor: instructor,
      semester: semester,
      createdAt: DateTime.now(),
    );

    await _saveToLocal(course);
    await _saveToCloud(course);

    return course;
  }

  Future<void> updateCourse(CourseModel course) async {
    await _saveToLocal(course);
    await _saveToCloud(course);
  }

  Future<void> deleteCourse(String courseId) async {
    await _deleteFromLocal(courseId);
    await _deleteFromCloud(courseId);
  }

  Future<CourseModel?> getCourse(String courseId) async {
    if (!FirebaseService.isInitialized || _userId == null) {
      await init();
      final json = _box!.get(courseId);
      if (json != null) {
        return CourseModel.fromJson(Map<String, dynamic>.from(json));
      }
      return null;
    }

    try {
      final doc = await FirebaseService.firestore
          .collection('courses')
          .doc(courseId)
          .get();
      
      if (doc.exists) {
        final course = CourseModel.fromJson(doc.data()!);
        await _saveToLocal(course);
        return course;
      }
      return null;
    } catch (e) {
      print('Error getting course: $e');
      await init();
      final json = _box!.get(courseId);
      if (json != null) {
        return CourseModel.fromJson(Map<String, dynamic>.from(json));
      }
      return null;
    }
  }
}


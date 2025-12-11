import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/models/task_model.dart';
import '../../../../services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class TaskRepository {
  static const String _boxName = 'tasks';
  Box<Map>? _box;

  Future<void> init() async {
    if (_box == null) {
      _box = await Hive.openBox<Map>(_boxName);
    }
  }

  // Get current user ID
  String? get _userId {
    try {
      return FirebaseService.currentUser?.uid;
    } catch (e) {
      return null;
    }
  }

  // Local storage operations
  Future<void> _saveToLocal(TaskModel task) async {
    await init();
    await _box!.put(task.id, task.toJson());
  }

  Future<void> _deleteFromLocal(String taskId) async {
    await init();
    await _box!.delete(taskId);
  }

  List<TaskModel> _getFromLocal() {
    if (_box == null) return [];
    return _box!.values
        .map((json) => TaskModel.fromJson(Map<String, dynamic>.from(json)))
        .where((task) => task.ownerId == _userId)
        .toList();
  }

  // Cloud operations
  Future<void> _saveToCloud(TaskModel task) async {
    if (!FirebaseService.isInitialized || _userId == null) return;
    
    try {
      await FirebaseService.firestore
          .collection('tasks')
          .doc(task.id)
          .set(task.toJson());
    } catch (e) {
      print('Error saving task to cloud: $e');
    }
  }

  Future<void> _deleteFromCloud(String taskId) async {
    if (!FirebaseService.isInitialized || _userId == null) return;
    
    try {
      await FirebaseService.firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      print('Error deleting task from cloud: $e');
    }
  }

  Stream<List<TaskModel>> watchTasks() {
    if (!FirebaseService.isInitialized || _userId == null) {
      // Return local stream if Firebase not initialized
      return Stream.value(_getFromLocal());
    }

    try {
      return FirebaseService.firestore
          .collection('tasks')
          .where('ownerId', isEqualTo: _userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        final tasks = snapshot.docs
            .map((doc) => TaskModel.fromJson(doc.data()))
            .toList();
        
        // Sync to local storage
        for (final task in tasks) {
          _saveToLocal(task);
        }
        
        return tasks;
      });
    } catch (e) {
      print('Error watching tasks: $e');
      return Stream.value(_getFromLocal());
    }
  }

  Future<List<TaskModel>> getTasks() async {
    if (!FirebaseService.isInitialized || _userId == null) {
      return _getFromLocal();
    }

    try {
      final snapshot = await FirebaseService.firestore
          .collection('tasks')
          .where('ownerId', isEqualTo: _userId)
          .orderBy('createdAt', descending: true)
          .get();

      final tasks = snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();

      // Sync to local storage
      for (final task in tasks) {
        await _saveToLocal(task);
      }

      return tasks;
    } catch (e) {
      print('Error getting tasks: $e');
      return _getFromLocal();
    }
  }

  Future<List<TaskModel>> getTodayTasks() async {
    final allTasks = await getTasks();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return allTasks.where((task) {
      if (task.completed) return false;
      if (task.dueDate == null) return false;
      final dueDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      return dueDate.isAtSameMomentAs(today) || dueDate.isBefore(today);
    }).toList();
  }

  Future<TaskModel> createTask({
    required String title,
    String? description,
    DateTime? dueDate,
    String? courseId,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    final task = TaskModel(
      id: const Uuid().v4(),
      ownerId: _userId!,
      title: title,
      description: description,
      dueDate: dueDate,
      courseId: courseId,
      priority: priority,
      createdAt: DateTime.now(),
    );

    await _saveToLocal(task);
    await _saveToCloud(task);

    return task;
  }

  Future<void> updateTask(TaskModel task) async {
    await _saveToLocal(task);
    await _saveToCloud(task);
  }

  Future<void> deleteTask(String taskId) async {
    await _deleteFromLocal(taskId);
    await _deleteFromCloud(taskId);
  }

  Future<void> toggleTaskComplete(String taskId, bool completed) async {
    final tasks = await getTasks();
    final task = tasks.firstWhere((t) => t.id == taskId);
    
    final updatedTask = TaskModel(
      id: task.id,
      ownerId: task.ownerId,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      courseId: task.courseId,
      priority: task.priority,
      completed: completed,
      pomodoroSessions: task.pomodoroSessions,
      createdAt: task.createdAt,
    );

    await updateTask(updatedTask);
  }

  Future<void> addPomodoroSession(String taskId, PomodoroSession session) async {
    final tasks = await getTasks();
    final task = tasks.firstWhere((t) => t.id == taskId);
    
    final updatedSessions = [...task.pomodoroSessions, session];
    final updatedTask = TaskModel(
      id: task.id,
      ownerId: task.ownerId,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      courseId: task.courseId,
      priority: task.priority,
      completed: task.completed,
      pomodoroSessions: updatedSessions,
      createdAt: task.createdAt,
    );

    await updateTask(updatedTask);
  }
}


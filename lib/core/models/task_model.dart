import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String? courseId;
  final TaskPriority priority;
  final bool completed;
  final List<PomodoroSession> pomodoroSessions;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    this.dueDate,
    this.courseId,
    this.priority = TaskPriority.medium,
    this.completed = false,
    this.pomodoroSessions = const [],
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: json['dueDate'] != null
          ? (json['dueDate'] as Timestamp).toDate()
          : null,
      courseId: json['courseId'] as String?,
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == 'TaskPriority.${json['priority']}',
        orElse: () => TaskPriority.medium,
      ),
      completed: json['completed'] as bool? ?? false,
      pomodoroSessions: (json['pomodoroSessions'] as List<dynamic>?)
              ?.map((e) => PomodoroSession.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'courseId': courseId,
      'priority': priority.toString().split('.').last,
      'completed': completed,
      'pomodoroSessions':
          pomodoroSessions.map((e) => e.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

enum TaskPriority { low, medium, high }

class PomodoroSession {
  final DateTime start;
  final DateTime end;

  PomodoroSession({
    required this.start,
    required this.end,
  });

  factory PomodoroSession.fromJson(Map<String, dynamic> json) {
    return PomodoroSession(
      start: (json['start'] as Timestamp).toDate(),
      end: (json['end'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end),
    };
  }

  Duration get duration => end.difference(start);
}


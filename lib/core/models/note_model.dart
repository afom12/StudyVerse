import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String courseId;
  final String ownerId;
  final String title;
  final Map<String, dynamic> content; // Quill delta format
  final List<String> attachments;
  final DateTime updatedAt;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.courseId,
    required this.ownerId,
    required this.title,
    required this.content,
    this.attachments = const [],
    required this.updatedAt,
    required this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      ownerId: json['ownerId'] as String,
      title: json['title'] as String,
      content: json['content'] as Map<String, dynamic>,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'ownerId': ownerId,
      'title': title,
      'content': content,
      'attachments': attachments,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}


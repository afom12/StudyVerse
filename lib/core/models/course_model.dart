import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String ownerId;
  final String title;
  final String? instructor;
  final int? semester;
  final DateTime createdAt;

  CourseModel({
    required this.id,
    required this.ownerId,
    required this.title,
    this.instructor,
    this.semester,
    required this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      title: json['title'] as String,
      instructor: json['instructor'] as String?,
      semester: json['semester'] as int?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'instructor': instructor,
      'semester': semester,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}


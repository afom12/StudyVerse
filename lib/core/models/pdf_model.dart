import 'package:cloud_firestore/cloud_firestore.dart';

class PDFModel {
  final String id;
  final String courseId;
  final String title;
  final String storageUrl;
  final String uploadedBy;
  final List<PDFAnnotation> annotations;
  final DateTime createdAt;

  PDFModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.storageUrl,
    required this.uploadedBy,
    this.annotations = const [],
    required this.createdAt,
  });

  factory PDFModel.fromJson(Map<String, dynamic> json) {
    return PDFModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      title: json['title'] as String,
      storageUrl: json['storageUrl'] as String,
      uploadedBy: json['uploadedBy'] as String,
      annotations: (json['annotations'] as List<dynamic>?)
              ?.map((e) => PDFAnnotation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'storageUrl': storageUrl,
      'uploadedBy': uploadedBy,
      'annotations': annotations.map((e) => e.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class PDFAnnotation {
  final String userId;
  final int page;
  final String text;
  final AnnotationType type;
  final DateTime createdAt;

  PDFAnnotation({
    required this.userId,
    required this.page,
    required this.text,
    required this.type,
    required this.createdAt,
  });

  factory PDFAnnotation.fromJson(Map<String, dynamic> json) {
    return PDFAnnotation(
      userId: json['userId'] as String,
      page: json['page'] as int,
      text: json['text'] as String,
      type: AnnotationType.values.firstWhere(
        (e) => e.toString() == 'AnnotationType.${json['type']}',
        orElse: () => AnnotationType.highlight,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'page': page,
      'text': text,
      'type': type.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

enum AnnotationType { highlight, underline, comment, bookmark }


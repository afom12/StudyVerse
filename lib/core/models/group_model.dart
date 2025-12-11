import 'package:cloud_firestore/cloud_firestore.dart';

class StudyGroupModel {
  final String id;
  final String name;
  final String? description;
  final String createdBy;
  final List<String> members;
  final String inviteCode;
  final DateTime createdAt;

  StudyGroupModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdBy,
    this.members = const [],
    required this.inviteCode,
    required this.createdAt,
  });

  factory StudyGroupModel.fromJson(Map<String, dynamic> json) {
    return StudyGroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdBy: json['createdBy'] as String,
      members: (json['members'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      inviteCode: json['inviteCode'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'members': members,
      'inviteCode': inviteCode,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class GroupMessageModel {
  final String id;
  final String groupId;
  final String userId;
  final String message;
  final String? attachmentUrl;
  final DateTime createdAt;

  GroupMessageModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.message,
    this.attachmentUrl,
    required this.createdAt,
  });

  factory GroupMessageModel.fromJson(Map<String, dynamic> json) {
    return GroupMessageModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      userId: json['userId'] as String,
      message: json['message'] as String,
      attachmentUrl: json['attachmentUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'userId': userId,
      'message': message,
      'attachmentUrl': attachmentUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}


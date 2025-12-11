import 'package:cloud_firestore/cloud_firestore.dart';

class FlashcardDeckModel {
  final String id;
  final String? courseId;
  final String ownerId;
  final String title;
  final String? description;
  final DateTime createdAt;

  FlashcardDeckModel({
    required this.id,
    this.courseId,
    required this.ownerId,
    required this.title,
    this.description,
    required this.createdAt,
  });

  factory FlashcardDeckModel.fromJson(Map<String, dynamic> json) {
    return FlashcardDeckModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String?,
      ownerId: json['ownerId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class FlashcardModel {
  final String id;
  final String deckId;
  final String ownerId;
  final String question;
  final String answer;
  final DateTime lastReviewed;
  final int interval; // days until next review
  final double easiness; // SM-2 easiness factor
  final int repetitions; // number of successful reviews

  FlashcardModel({
    required this.id,
    required this.deckId,
    required this.ownerId,
    required this.question,
    required this.answer,
    required this.lastReviewed,
    required this.interval,
    required this.easiness,
    required this.repetitions,
  });

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json['id'] as String,
      deckId: json['deckId'] as String,
      ownerId: json['ownerId'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      lastReviewed: (json['lastReviewed'] as Timestamp).toDate(),
      interval: json['interval'] as int,
      easiness: json['easiness'] as double,
      repetitions: json['repetitions'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deckId': deckId,
      'ownerId': ownerId,
      'question': question,
      'answer': answer,
      'lastReviewed': Timestamp.fromDate(lastReviewed),
      'interval': interval,
      'easiness': easiness,
      'repetitions': repetitions,
    };
  }

  DateTime get nextReviewDate => lastReviewed.add(Duration(days: interval));
  
  bool get isDue => DateTime.now().isAfter(nextReviewDate) || 
                    DateTime.now().isAtSameMomentAs(nextReviewDate);
}


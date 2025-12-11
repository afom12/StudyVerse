class FlashcardEntity {
  final String id;
  final String deckId;
  final String question;
  final String answer;
  final DateTime lastReviewed;
  final int interval; // days until next review
  final double easiness; // SM-2 easiness factor
  final int repetitions; // number of successful reviews

  FlashcardEntity({
    required this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    required this.lastReviewed,
    required this.interval,
    required this.easiness,
    required this.repetitions,
  });

  FlashcardEntity copyWith({
    String? id,
    String? deckId,
    String? question,
    String? answer,
    DateTime? lastReviewed,
    int? interval,
    double? easiness,
    int? repetitions,
  }) {
    return FlashcardEntity(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      interval: interval ?? this.interval,
      easiness: easiness ?? this.easiness,
      repetitions: repetitions ?? this.repetitions,
    );
  }

  DateTime get nextReviewDate => lastReviewed.add(Duration(days: interval));
  
  bool get isDue => DateTime.now().isAfter(nextReviewDate) || 
                    DateTime.now().isAtSameMomentAs(nextReviewDate);
}


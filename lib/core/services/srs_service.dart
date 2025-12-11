import '../../features/flashcards/domain/entities/flashcard_entity.dart';

/// Spaced Repetition System (SM-2 algorithm)
class SRSService {
  /// Update flashcard based on review quality
  /// Quality: 0 = Again, 1 = Hard, 2 = Good, 3 = Easy
  static FlashcardEntity updateCardReview(
    FlashcardEntity card,
    int quality,
  ) {
    if (quality < 3) {
      // Failed - reset
      card = card.copyWith(
        repetitions: 0,
        interval: 1,
        lastReviewed: DateTime.now(),
      );
    } else {
      // Success - update easiness and interval
      double newEasiness = card.easiness +
          (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
      
      // Ensure easiness doesn't go below 1.3
      if (newEasiness < 1.3) {
        newEasiness = 1.3;
      }

      int newRepetitions = card.repetitions + 1;
      int newInterval;

      if (newRepetitions == 1) {
        newInterval = 1;
      } else if (newRepetitions == 2) {
        newInterval = 6;
      } else {
        newInterval = (card.interval * newEasiness).round();
      }

      card = card.copyWith(
        repetitions: newRepetitions,
        interval: newInterval,
        easiness: newEasiness,
        lastReviewed: DateTime.now(),
      );
    }

    return card;
  }

  /// Get next review date
  static DateTime getNextReviewDate(FlashcardEntity card) {
    return card.lastReviewed.add(Duration(days: card.interval));
  }

  /// Check if card is due for review
  static bool isDue(FlashcardEntity card) {
    final nextReview = getNextReviewDate(card);
    return DateTime.now().isAfter(nextReview) ||
        DateTime.now().isAtSameMomentAs(nextReview);
  }

  /// Get quality rating from user input
  static int getQualityFromRating(String rating) {
    switch (rating.toLowerCase()) {
      case 'again':
        return 0;
      case 'hard':
        return 1;
      case 'good':
        return 2;
      case 'easy':
        return 3;
      default:
        return 2; // Default to 'Good'
    }
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/models/flashcard_model.dart';
import '../../../../services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class FlashcardRepository {
  static const String _decksBoxName = 'flashcard_decks';
  static const String _cardsBoxName = 'flashcards';
  Box<Map>? _decksBox;
  Box<Map>? _cardsBox;

  Future<void> init() async {
    if (_decksBox == null) {
      _decksBox = await Hive.openBox<Map>(_decksBoxName);
    }
    if (_cardsBox == null) {
      _cardsBox = await Hive.openBox<Map>(_cardsBoxName);
    }
  }

  String? get _userId {
    try {
      return FirebaseService.currentUser?.uid;
    } catch (e) {
      return null;
    }
  }

  // Get due cards count
  Future<int> getDueCardsCount() async {
    if (_userId == null) return 0;
    
    try {
      if (FirebaseService.isInitialized) {
        final cardsSnapshot = await FirebaseService.firestore
            .collection('flashcards')
            .where('ownerId', isEqualTo: _userId)
            .get();

        int dueCount = 0;
        for (var doc in cardsSnapshot.docs) {
          final card = FlashcardModel.fromJson(doc.data());
          if (card.isDue) {
            dueCount++;
          }
        }
        return dueCount;
      }
    } catch (e) {
      print('Error getting due cards count: $e');
    }
    
    // Fallback to local storage
    if (_cardsBox != null) {
      final cards = _cardsBox!.values
          .map((json) => FlashcardModel.fromJson(Map<String, dynamic>.from(json)))
          .where((card) => card.isDue)
          .length;
      return cards;
    }
    
    return 0;
  }

  Stream<int> watchDueCardsCount() {
    if (!FirebaseService.isInitialized || _userId == null) {
      return Stream.value(0);
    }

    try {
      return FirebaseService.firestore
          .collection('flashcards')
          .where('ownerId', isEqualTo: _userId)
          .snapshots()
          .map((snapshot) {
        int dueCount = 0;
        for (var doc in snapshot.docs) {
          final card = FlashcardModel.fromJson(doc.data());
          if (card.isDue) {
            dueCount++;
          }
        }
        return dueCount;
      });
    } catch (e) {
      print('Error watching due cards: $e');
      return Stream.value(0);
    }
  }
}


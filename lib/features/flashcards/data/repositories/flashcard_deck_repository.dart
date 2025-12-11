import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/models/flashcard_model.dart';
import '../../../../services/firebase_service.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/srs_service.dart';
import '../../../flashcards/domain/entities/flashcard_entity.dart';

class FlashcardDeckRepository {
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

  Future<void> _saveDeckToLocal(FlashcardDeckModel deck) async {
    await init();
    await _decksBox!.put(deck.id, deck.toJson());
  }

  Future<void> _saveCardToLocal(FlashcardModel card) async {
    await init();
    await _cardsBox!.put(card.id, card.toJson());
  }

  List<FlashcardDeckModel> _getDecksFromLocal({String? courseId}) {
    if (_decksBox == null) return [];
    return _decksBox!.values
        .map((json) => FlashcardDeckModel.fromJson(Map<String, dynamic>.from(json)))
        .where((deck) {
          if (deck.ownerId != _userId) return false;
          if (courseId != null && deck.courseId != courseId) return false;
          return true;
        })
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<FlashcardModel> _getCardsFromLocal(String deckId) {
    if (_cardsBox == null) return [];
    return _cardsBox!.values
        .map((json) => FlashcardModel.fromJson(Map<String, dynamic>.from(json)))
        .where((card) => card.deckId == deckId && card.ownerId == _userId)
        .toList();
  }

  Future<void> _saveDeckToCloud(FlashcardDeckModel deck) async {
    if (!FirebaseService.isInitialized || _userId == null) return;
    try {
      await FirebaseService.firestore
          .collection('flashcard_decks')
          .doc(deck.id)
          .set(deck.toJson());
    } catch (e) {
      print('Error saving deck to cloud: $e');
    }
  }

  Future<void> _saveCardToCloud(FlashcardModel card) async {
    if (!FirebaseService.isInitialized || _userId == null) return;
    try {
      await FirebaseService.firestore
          .collection('flashcards')
          .doc(card.id)
          .set(card.toJson());
    } catch (e) {
      print('Error saving card to cloud: $e');
    }
  }

  Stream<List<FlashcardDeckModel>> watchDecks({String? courseId}) {
    if (!FirebaseService.isInitialized || _userId == null) {
      return Stream.value(_getDecksFromLocal(courseId: courseId));
    }

    try {
      Query query = FirebaseService.firestore
          .collection('flashcard_decks')
          .where('ownerId', isEqualTo: _userId);
      
      if (courseId != null) {
        query = query.where('courseId', isEqualTo: courseId);
      }
      
      return query
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        final decks = snapshot.docs
            .map((doc) => FlashcardDeckModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
        
        for (final deck in decks) {
          _saveDeckToLocal(deck);
        }
        
        return decks;
      });
    } catch (e) {
      print('Error watching decks: $e');
      return Stream.value(_getDecksFromLocal(courseId: courseId));
    }
  }

  Stream<List<FlashcardModel>> watchCards(String deckId) {
    if (!FirebaseService.isInitialized || _userId == null) {
      return Stream.value(_getCardsFromLocal(deckId));
    }

    try {
      return FirebaseService.firestore
          .collection('flashcards')
          .where('deckId', isEqualTo: deckId)
          .where('ownerId', isEqualTo: _userId)
          .snapshots()
          .map((snapshot) {
        final cards = snapshot.docs
            .map((doc) => FlashcardModel.fromJson(doc.data()))
            .toList();
        
        for (final card in cards) {
          _saveCardToLocal(card);
        }
        
        return cards;
      });
    } catch (e) {
      print('Error watching cards: $e');
      return Stream.value(_getCardsFromLocal(deckId));
    }
  }

  Future<List<FlashcardModel>> getDueCards(String deckId) async {
    final cards = await getCards(deckId);
    return cards.where((card) => card.isDue).toList();
  }

  Future<List<FlashcardModel>> getCards(String deckId) async {
    if (!FirebaseService.isInitialized || _userId == null) {
      return _getCardsFromLocal(deckId);
    }

    try {
      final snapshot = await FirebaseService.firestore
          .collection('flashcards')
          .where('deckId', isEqualTo: deckId)
          .where('ownerId', isEqualTo: _userId)
          .get();

      final cards = snapshot.docs
          .map((doc) => FlashcardModel.fromJson(doc.data()))
          .toList();

      for (final card in cards) {
        await _saveCardToLocal(card);
      }

      return cards;
    } catch (e) {
      print('Error getting cards: $e');
      return _getCardsFromLocal(deckId);
    }
  }

  Future<FlashcardDeckModel> createDeck({
    String? courseId,
    required String title,
    String? description,
  }) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    final deck = FlashcardDeckModel(
      id: const Uuid().v4(),
      courseId: courseId,
      ownerId: _userId!,
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );

    await _saveDeckToLocal(deck);
    await _saveDeckToCloud(deck);

    return deck;
  }

  Future<FlashcardModel> createCard({
    required String deckId,
    required String question,
    required String answer,
  }) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    final now = DateTime.now();
    final card = FlashcardModel(
      id: const Uuid().v4(),
      deckId: deckId,
      ownerId: _userId!,
      question: question,
      answer: answer,
      lastReviewed: now,
      interval: 1,
      easiness: 2.5,
      repetitions: 0,
    );

    await _saveCardToLocal(card);
    await _saveCardToCloud(card);

    return card;
  }

  Future<void> updateCardReview(String cardId, String deckId, int quality) async {
    final cards = await getCards(deckId);
    final card = cards.firstWhere((c) => c.id == cardId);
    
    final entity = FlashcardEntity(
      id: card.id,
      deckId: card.deckId,
      question: card.question,
      answer: card.answer,
      lastReviewed: card.lastReviewed,
      interval: card.interval,
      easiness: card.easiness,
      repetitions: card.repetitions,
    );

    final updatedEntity = SRSService.updateCardReview(entity, quality);
    
    final updatedCard = FlashcardModel(
      id: updatedEntity.id,
      deckId: updatedEntity.deckId,
      ownerId: card.ownerId,
      question: updatedEntity.question,
      answer: updatedEntity.answer,
      lastReviewed: updatedEntity.lastReviewed,
      interval: updatedEntity.interval,
      easiness: updatedEntity.easiness,
      repetitions: updatedEntity.repetitions,
    );

    await _saveCardToLocal(updatedCard);
    await _saveCardToCloud(updatedCard);
  }

  Future<void> deleteDeck(String deckId) async {
    // Delete all cards first
    final cards = await getCards(deckId);
    for (final card in cards) {
      await _deleteCard(card.id);
    }
    
    // Delete deck
    await init();
    await _decksBox!.delete(deckId);
    
    if (FirebaseService.isInitialized && _userId != null) {
      try {
        await FirebaseService.firestore
            .collection('flashcard_decks')
            .doc(deckId)
            .delete();
      } catch (e) {
        print('Error deleting deck from cloud: $e');
      }
    }
  }

  Future<void> _deleteCard(String cardId) async {
    await init();
    await _cardsBox!.delete(cardId);
    
    if (FirebaseService.isInitialized && _userId != null) {
      try {
        await FirebaseService.firestore.collection('flashcards').doc(cardId).delete();
      } catch (e) {
        print('Error deleting card from cloud: $e');
      }
    }
  }

  Future<void> deleteCard(String cardId) async {
    await _deleteCard(cardId);
  }
}


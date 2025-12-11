import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/flashcard_model.dart';
import '../../data/repositories/flashcard_deck_repository.dart';

final flashcardDeckRepositoryProvider = Provider<FlashcardDeckRepository>((ref) {
  final repo = FlashcardDeckRepository();
  repo.init();
  return repo;
});

final flashcardDecksProvider = StreamProvider.family<List<FlashcardDeckModel>, String?>((ref, courseId) {
  return ref.watch(flashcardDeckRepositoryProvider).watchDecks(courseId: courseId);
});

final flashcardCardsProvider = StreamProvider.family<List<FlashcardModel>, String>((ref, deckId) {
  return ref.watch(flashcardDeckRepositoryProvider).watchCards(deckId);
});

final dueCardsProvider = FutureProvider.family<List<FlashcardModel>, String>((ref, deckId) async {
  return await ref.read(flashcardDeckRepositoryProvider).getDueCards(deckId);
});


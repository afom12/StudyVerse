import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/flashcard_repository.dart';

final flashcardRepositoryProvider = Provider<FlashcardRepository>((ref) {
  final repo = FlashcardRepository();
  repo.init();
  return repo;
});

final dueCardsCountProvider = StreamProvider<int>((ref) {
  return ref.watch(flashcardRepositoryProvider).watchDueCardsCount();
});


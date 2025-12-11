import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/flashcard_deck_provider.dart';

class DeckDetailScreen extends ConsumerWidget {
  final String deckId;

  const DeckDetailScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(flashcardCardsProvider(deckId));
    final dueCardsAsync = ref.watch(dueCardsProvider(deckId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Detail'),
        actions: [
          dueCardsAsync.when(
            data: (dueCards) {
              if (dueCards.isNotEmpty) {
                return IconButton(
                  icon: Badge(
                    label: Text('${dueCards.length}'),
                    child: const Icon(Icons.play_arrow),
                  ),
                  onPressed: () {
                    context.push('/flashcards/review/$deckId');
                  },
                  tooltip: 'Start Review',
                );
              }
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () {
                  context.push('/flashcards/review/$deckId');
                },
                tooltip: 'Start Review',
              );
            },
            loading: () => const IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: null,
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: cardsAsync.when(
        data: (cards) {
          if (cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.style_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No cards yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first flashcard',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: Icon(
                    card.isDue ? Icons.priority_high : Icons.check_circle_outline,
                    color: card.isDue ? Colors.orange : Colors.green,
                  ),
                  title: Text(card.question),
                  subtitle: Text('Reviewed ${_formatDate(card.lastReviewed)}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Answer:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(card.answer),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text('Interval: ${card.interval} days'),
                              const SizedBox(width: 16),
                              Text('Repetitions: ${card.repetitions}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $err'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCardDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCardDialog(BuildContext context, WidgetRef ref) {
    final questionController = TextEditingController();
    final answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Flashcard'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  hintText: 'Enter the question',
                ),
                autofocus: true,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(
                  labelText: 'Answer',
                  hintText: 'Enter the answer',
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (questionController.text.trim().isEmpty ||
                  answerController.text.trim().isEmpty) {
                return;
              }

              try {
                await ref.read(flashcardDeckRepositoryProvider).createCard(
                      deckId: deckId,
                      question: questionController.text.trim(),
                      answer: answerController.text.trim(),
                    );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Card added!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}


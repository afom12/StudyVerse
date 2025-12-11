import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/flashcard_model.dart';
import '../providers/flashcard_deck_provider.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final String deckId;

  const ReviewScreen({super.key, required this.deckId});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  bool _showAnswer = false;
  int _currentIndex = 0;
  List<FlashcardModel> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final dueCards = await ref.read(flashcardDeckRepositoryProvider).getDueCards(widget.deckId);
    setState(() {
      _cards = dueCards;
      _isLoading = false;
    });
  }

  Future<void> _rateCard(int quality) async {
    if (_currentIndex >= _cards.length) return;

    final card = _cards[_currentIndex];
    await ref.read(flashcardDeckRepositoryProvider).updateCardReview(
          card.id,
          widget.deckId,
          quality,
        );

    setState(() {
      _showAnswer = false;
      _currentIndex++;
    });

    if (_currentIndex >= _cards.length) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review complete!')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                'No cards due for review',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Great job! All cards are up to date.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Back to Deck'),
              ),
            ],
          ),
        ),
      );
    }

    final card = _cards[_currentIndex];
    final progress = (_currentIndex + 1) / _cards.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Review (${_currentIndex + 1}/${_cards.length})'),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: progress),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      margin: const EdgeInsets.all(24),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Text(
                                _showAnswer ? 'Answer' : 'Question',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                _showAnswer ? card.answer : card.question,
                                style: Theme.of(context).textTheme.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!_showAnswer)
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showAnswer = true;
                          });
                        },
                        icon: const Icon(Icons.visibility),
                        label: const Text('Show Answer'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () => _rateCard(0),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Again'),
                          ),
                          OutlinedButton(
                            onPressed: () => _rateCard(1),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                            ),
                            child: const Text('Hard'),
                          ),
                          ElevatedButton(
                            onPressed: () => _rateCard(2),
                            child: const Text('Good'),
                          ),
                          ElevatedButton(
                            onPressed: () => _rateCard(3),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Easy'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';

class PhraseProgressScreen extends StatefulWidget {
  final int unlockedLetters; // Открытые буквы
  final String fullPhrase; // Полная фраза (35-40 символов)
  final int totalLevels; // Общее количество уровней

  const PhraseProgressScreen({
    super.key,
    required this.unlockedLetters,
    required this.fullPhrase,
    required this.totalLevels,
  });

  @override
  State<PhraseProgressScreen> createState() => _PhraseProgressScreenState();
}

class _PhraseProgressScreenState extends State<PhraseProgressScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Прогресс')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: LinearProgressIndicator(
                value: widget.unlockedLetters / widget.totalLevels,
                backgroundColor: theme.secondaryContainer,
                color: theme.secondary,
                minHeight: 20,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${widget.unlockedLetters}/${widget.totalLevels} уровней пройдено',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            // Отображение фразы
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildPhraseDisplay(),
            ),
            const SizedBox(height: 40),
            // Кнопка продолжения
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryContainer,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'Продолжить игру',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhraseDisplay() {
    int lettersUnlocked = widget.unlockedLetters;
    int lettersToShow = 0;

    for (int i = 0; i < widget.fullPhrase.length; i++) {
      if (lettersUnlocked <= 0) break;

      if (widget.fullPhrase[i] != ' ') {
        lettersUnlocked--;
      }
      lettersToShow++;
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: widget.fullPhrase.split('').asMap().entries.map((entry) {
        final index = entry.key;
        final char = entry.value;
        final isUnlocked = index < lettersToShow;

        final theme = Theme.of(context).colorScheme;

        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isUnlocked ? theme.primaryContainer : Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isUnlocked ? theme.secondaryContainer : Colors.grey,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              isUnlocked
                  ? char
                  : char == ' '
                  ? ' '
                  : '?',
              style: TextStyle(
                color: isUnlocked ? theme.onPrimaryContainer : Colors.grey,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

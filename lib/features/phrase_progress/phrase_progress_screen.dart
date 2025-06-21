import 'package:flutter/material.dart';
import 'package:tg_mini_app/core/globals.dart';
import 'package:tg_mini_app/router.dart';

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
  bool _showVictoryScreen = false;

  @override
  void initState() {
    super.initState();
    if (widget.unlockedLetters >= widget.fullPhrase.length) {
      _showVictoryScreen = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showVictoryScreen) {
      return _buildVictoryScreen();
    }

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

  Widget _buildVictoryScreen() {
    final theme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: theme.surfaceVariant.withOpacity(0.3),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Анимированная иконка победы
              Icon(Icons.celebration, color: theme.primary, size: 100),
              const SizedBox(height: 24),

              // Заголовок
              Text(
                'ПОБЕДА!',
                style: textTheme.displayMedium?.copyWith(
                  color: theme.primary,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: theme.primary.withOpacity(0.3),
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Контейнер с фразой
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadow.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Вы собрали фразу:',
                      style: textTheme.titleLarge?.copyWith(
                        color: theme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.fullPhrase,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        color: theme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Промокод (если есть)
              if (Globals.promoCode.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: theme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Ваш промокод:',
                        style: textTheme.titleMedium?.copyWith(
                          color: theme.onSecondaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Globals.promoCode,
                        style: textTheme.headlineMedium?.copyWith(
                          color: theme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Кнопка
              FilledButton(
                onPressed: () => router.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: theme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Назад',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

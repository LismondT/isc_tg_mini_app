import 'package:flutter/material.dart';
import 'package:tg_mini_app/game/main_game.dart';
import 'package:tg_mini_app/router.dart';

class GameOverOverlay extends StatelessWidget {
  static const String id = 'game_over_overlay';

  final MainGame game;
  final BuildContext context;

  const GameOverOverlay({super.key, required this.game, required this.context});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.primary, width: 2),
          ),
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Игра окончена',
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    context: context,
                    icon: Icons.replay,
                    label: 'Повторить',
                    colorScheme: colorScheme,
                    onPressed: () {
                      game.resetGame();
                    },
                  ),
                  _buildActionButton(
                    context: context,
                    icon: Icons.exit_to_app,
                    label: 'В меню',
                    colorScheme: colorScheme,
                    onPressed: () {
                      router.pop(false);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required ColorScheme colorScheme,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: colorScheme.onPrimary),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
    );
  }
}

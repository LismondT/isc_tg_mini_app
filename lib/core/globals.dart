import 'package:tg_mini_app/game/models/level.dart';

class Globals {
  static const String phrase = 'Защита данных — наш приоритет!';
  static final String cleanPhrase = phrase.replaceAll(' ', '');
  static final levelsCount = cleanPhrase.length;

  static List<Level> levels = [];
}

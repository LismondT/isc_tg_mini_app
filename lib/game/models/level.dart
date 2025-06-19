import 'package:tg_mini_app/game/models/wave.dart';

class Level {
  final int id;
  final int duration;
  List<Wave> waves;

  Level({required this.id, required this.duration, required this.waves});

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'],
      duration: json['duration'],
      waves: (json['waves'] as List).map((e) => Wave.fromJson(e)).toList(),
    );
  }
}

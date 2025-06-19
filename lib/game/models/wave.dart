import 'package:tg_mini_app/game/models/enemy_group.dart';

class Wave {
  final double startTime;
  final double endTime;
  List<EnemyGroup> enemies;

  double get duration => endTime - startTime;

  Wave({required this.startTime, required this.endTime, required this.enemies});

  List<double> getSpawnTimes(EnemyGroup group) {
    final interval = duration / group.count;
    return List.generate(group.count, (i) => startTime + i * interval);
  }

  factory Wave.fromJson(Map<String, dynamic> json) {
    return Wave(
      startTime: json['start_time'].toDouble(),
      endTime: json['end_time'].toDouble(),
      enemies: (json['enemies'] as List)
          .map((e) => EnemyGroup.fromJson(e))
          .toList(),
    );
  }
}

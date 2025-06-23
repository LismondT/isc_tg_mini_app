class EnemyGroup {
  final String img;
  final int count;
  final int minHealth;
  final int maxHealth;
  final String movement;
  final String? bulletPattern;

  EnemyGroup({
    required this.img,
    required this.count,
    required this.minHealth,
    required this.maxHealth,
    required this.movement,
    required this.bulletPattern,
  });

  factory EnemyGroup.fromJson(Map<String, dynamic> json) {
    return EnemyGroup(
      img: json['img'] ?? '',
      count: json['count'],
      minHealth: json['min_health'],
      maxHealth: json['max_health'],
      movement: json['movement'],
      bulletPattern: json['bullet_pattern'] ?? '',
    );
  }
}

class EnemyGroup {
  final String img;
  final int count;
  final String movement;
  final String? bulletPattern;

  EnemyGroup({
    required this.img,
    required this.count,
    required this.movement,
    required this.bulletPattern,
  });

  factory EnemyGroup.fromJson(Map<String, dynamic> json) {
    return EnemyGroup(
      img: json['img'],
      count: json['count'],
      movement: json['movement'],
      bulletPattern: json['bullet_pattern'],
    );
  }
}

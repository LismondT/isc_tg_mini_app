class ScheduledEnemy {
  final double spawnTime;
  final String imagePath;
  final String movementPattern;
  final String? bulletPattern;

  final int minHealth;
  final int maxHealth;

  ScheduledEnemy({
    required this.spawnTime,
    required this.imagePath,
    required this.minHealth,
    required this.maxHealth,
    required this.movementPattern,
    required this.bulletPattern,
  });
}

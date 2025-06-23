class PlayerProgress {
  static final Map<int, double> _levelToShootSpeed = {1: .25, 2: .20, 3: .15};
  static final Map<int, int> _levelToDamage = {1: 1, 2: 2, 3: 3};

  int get shootSpeedMaxLevel => _levelToShootSpeed.length;
  int get damageMaxLevel => _levelToDamage.length;
  int get gunMaxLevel => 3;

  late final double shootSpeed;
  late final int damage;
  late final int guns;

  PlayerProgress({
    required int shootSpeedLevel,
    required int damageLevel,
    required int gunsLevel,
  }) {
    shootSpeed = _levelToShootSpeed[shootSpeedLevel]!;
    damage = _levelToDamage[damageLevel]!;
    guns = gunsLevel;
  }
}

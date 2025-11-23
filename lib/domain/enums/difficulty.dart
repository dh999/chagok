enum Difficulty {
  easy('EASY', '쉬움', 1),
  medium('MEDIUM', '보통', 2),
  hard('HARD', '어려움', 3);

  final String value;
  final String label;
  final int blockValue;

  const Difficulty(this.value, this.label, this.blockValue);

  static Difficulty fromString(String value) {
    return Difficulty.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Difficulty.easy,
    );
  }
}

enum GoalCategory {
  finance('FINANCE', '재테크', '🏦'),
  study('STUDY', '학습', '📖'),
  health('HEALTH', '건강', '🏃'),
  career('CAREER', '커리어', '💼');

  final String value;
  final String label;
  final String emoji;

  const GoalCategory(this.value, this.label, this.emoji);

  static GoalCategory fromString(String value) {
    return GoalCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GoalCategory.study,
    );
  }
}

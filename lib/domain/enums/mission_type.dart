enum MissionType {
  study('STUDY', '학습', '📚'),
  saving('SAVING', '저축', '💰'),
  health('HEALTH', '건강', '💪'),
  task('TASK', '할일', '✅');

  final String value;
  final String label;
  final String emoji;

  const MissionType(this.value, this.label, this.emoji);

  static MissionType fromString(String value) {
    return MissionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MissionType.task,
    );
  }
}

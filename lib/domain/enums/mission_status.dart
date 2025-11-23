enum MissionStatus {
  pending('PENDING', '대기중'),
  completed('COMPLETED', '완료'),
  skipped('SKIPPED', '스킵'),
  failed('FAILED', '실패');

  final String value;
  final String label;

  const MissionStatus(this.value, this.label);

  static MissionStatus fromString(String value) {
    return MissionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MissionStatus.pending,
    );
  }

  bool get isCompleted => this == MissionStatus.completed;
  bool get isPending => this == MissionStatus.pending;
  bool get isFailed => this == MissionStatus.failed;
}

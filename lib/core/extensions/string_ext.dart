extension StringExt on String {
  /// 첫 글자만 대문자
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// null이거나 빈 문자열인지 확인
  bool get isNullOrEmpty => isEmpty;

  /// 유효한 이메일인지 확인
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// 숫자만 추출
  String get digitsOnly => replaceAll(RegExp(r'[^0-9]'), '');

  /// 최대 길이로 자르기
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }
}

extension NullableStringExt on String? {
  /// null이거나 빈 문자열인지 확인
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// null이 아니고 비어있지 않은지 확인
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}

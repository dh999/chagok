import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  /// 오늘 자정 (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);

  /// 오늘 끝 (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// 이번 달 첫날
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// 이번 달 마지막날
  DateTime get endOfMonth => DateTime(year, month + 1, 0);

  /// 오늘인지 확인
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// 어제인지 확인
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// 같은 날인지 확인
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// YYYY-MM-DD 형식
  String get toDateString => DateFormat('yyyy-MM-dd').format(this);

  /// M월 d일 형식
  String get toKoreanDate => DateFormat('M월 d일').format(this);

  /// yyyy년 M월 형식
  String get toKoreanMonth => DateFormat('yyyy년 M월').format(this);

  /// 두 날짜 사이 일수
  int daysBetween(DateTime other) {
    return startOfDay.difference(other.startOfDay).inDays.abs();
  }
}

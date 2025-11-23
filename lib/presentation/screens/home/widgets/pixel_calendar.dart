import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../providers/mission_provider.dart';

class PixelCalendar extends ConsumerStatefulWidget {
  const PixelCalendar({super.key});

  @override
  ConsumerState<PixelCalendar> createState() => _PixelCalendarState();
}

class _PixelCalendarState extends ConsumerState<PixelCalendar> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final monthlyMissions = ref.watch(
      monthlyMissionsProvider((year: _focusedDay.year, month: _focusedDay.month)),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime(2100, 12, 31),
        focusedDay: _focusedDay,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          leftChevronIcon: const Icon(
            Icons.chevron_left,
            color: AppColors.primary,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right,
            color: AppColors.primary,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
          weekendStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
          cellMargin: EdgeInsets.all(4),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, monthlyMissions.valueOrNull ?? {});
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildDayCell(
              day,
              monthlyMissions.valueOrNull ?? {},
              isToday: true,
            );
          },
          outsideBuilder: (context, day, focusedDay) {
            return const SizedBox.shrink();
          },
        ),
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day,
    Map<DateTime, List<dynamic>> missions, {
    bool isToday = false,
  }) {
    final dayMissions = missions[day.startOfDay];
    final hasCompleted = dayMissions?.any((m) => m.isCompleted) ?? false;
    final allCompleted = dayMissions?.isNotEmpty == true &&
        dayMissions!.every((m) => m.isCompleted);
    final hasFailed = day.isBefore(DateTime.now().startOfDay) &&
        dayMissions?.isNotEmpty == true &&
        !allCompleted;

    Color backgroundColor;
    Color textColor;

    if (isToday) {
      backgroundColor = AppColors.primary.withOpacity(0.2);
      textColor = AppColors.primary;
    } else if (allCompleted) {
      backgroundColor = AppColors.calendarSuccess;
      textColor = Colors.white;
    } else if (hasFailed) {
      backgroundColor = AppColors.calendarFailed;
      textColor = AppColors.textSecondary;
    } else {
      backgroundColor = Colors.transparent;
      textColor = AppColors.textPrimary;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: isToday
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: allCompleted
            ? [
                BoxShadow(
                  color: AppColors.calendarSuccess.withOpacity(0.3),
                  blurRadius: 4,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: isToday || allCompleted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

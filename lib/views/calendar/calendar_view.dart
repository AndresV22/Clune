import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:clune/controllers/calendar_controller.dart';
import 'package:clune/controllers/main_nav_controller.dart';
import 'package:clune/controllers/daily_log_controller.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/app_text_styles.dart';
import 'package:clune/utils/date_utils.dart';
import 'package:clune/utils/enums.dart';
import 'package:clune/utils/log_dot_mapper.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';
import 'package:clune/widgets/period_history_sheet.dart';

/// Vista de calendario mensual con colores de fase estilo Clue.
class CalendarView extends GetView<CalendarController> {
  const CalendarView({super.key});

  static const _weekdays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context),
          _buildMonthHeader(context),
          _buildWeekdayHeader(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.dayInfoMap.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildCalendarGrid();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final clune = context.clune;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
      child: Row(
        children: [
          const SizedBox(width: 40),
          Expanded(
            child: Text(
              'calendar_title'.tr,
              style: clune.headingMedium,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: openPeriodHistorySheet,
            icon: const Icon(Icons.water_drop_outlined, color: AppColors.primaryRed),
            tooltip: 'period_history'.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(BuildContext context) {
    return Obx(() {
      final clune = context.clune;
      final month = controller.focusedMonth.value;
      final label = DateFormat('MMMM yyyy', 'es_ES').format(month);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: controller.previousMonth,
              icon: Icon(Icons.chevron_left, color: clune.textPrimary),
            ),
            Text(
              label[0].toUpperCase() + label.substring(1),
              style: clune.headingMedium,
            ),
            IconButton(
              onPressed: controller.nextMonth,
              icon: Icon(Icons.chevron_right, color: clune.textPrimary),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildWeekdayHeader(BuildContext context) {
    final clune = context.clune;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: _weekdays
            .map(
              (d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: clune.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final month = controller.focusedMonth.value;
    final dayInfoMap = Map<String, CalendarDayInfo>.from(controller.dayInfoMap);
    final days = AppDateUtils.getCalendarDays(month);

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.72,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final date = days[index];
        if (date == null) {
          return const SizedBox.shrink();
        }
        return _buildDayCell(context, date, dayInfoMap);
      },
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime date,
    Map<String, CalendarDayInfo> dayInfoMap,
  ) {
    final clune = context.clune;
    final normalized = AppDateUtils.normalizeDate(date);
    final info = dayInfoMap[normalized.toIso8601String()] ??
        CalendarDayInfo(
          date: normalized,
          isToday: normalized == AppDateUtils.normalizeDate(DateTime.now()),
        );

    final style = _cellStyle(info.type, clune);
    final logColors = info.logs.expand((log) => LogDotMapper.colorsForLog(log)).take(4).toList();

    return GestureDetector(
      onTap: () => _showDayDetail(context, date, info),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(8),
          border: info.isToday
              ? Border.all(color: clune.textPrimary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (logColors.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: logColors.map(_buildLogPill).toList(),
                ),
              )
            else
              const SizedBox(height: 10),
            Text(
              '${date.day}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: info.isToday ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
                color: style.textColor,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildLogPill(Color color) {
    return Container(
      width: 4,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  _CellStyle _cellStyle(DayType type, CluneThemeColors clune) {
    switch (type) {
      case DayType.menstruation:
        return _CellStyle(
          background: AppColors.primaryRed,
          textColor: Colors.white,
        );
      case DayType.menstruationPredicted:
        return _CellStyle(
          background: AppColors.primaryPink.withValues(alpha: 0.85),
          textColor: clune.textPrimary,
        );
      case DayType.fertile:
        return _CellStyle(
          background: AppColors.primaryTeal.withValues(alpha: 0.75),
          textColor: Colors.white,
        );
      case DayType.ovulation:
        return _CellStyle(
          background: AppColors.primaryTeal,
          textColor: Colors.white,
        );
      case DayType.normal:
        return _CellStyle(
          background: clune.inputFill,
          textColor: clune.textPrimary,
        );
    }
  }

  void _showDayDetail(BuildContext context, DateTime date, CalendarDayInfo info) {
    final clune = context.clune;
    controller.selectDay(date);
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: clune.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppDateUtils.formatTodayOrDate(date),
              style: clune.headingMedium,
            ),
            if (info.type != DayType.normal) ...[
              const SizedBox(height: 8),
              Text(_phaseLabel(info.type), style: clune.bodySmall),
            ],
            const SizedBox(height: 16),
            if (info.logs.isEmpty)
              Text('calendar_no_log'.tr, style: clune.bodyLarge)
            else
              ...info.logs.map((log) => _LogSummaryTile(log: log)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.find<MainNavController>().changeTab(2);
                  Get.find<DailyLogController>().changeDate(date);
                },
                child: Text(info.logs.isEmpty ? 'calendar_log'.tr : 'calendar_edit'.tr),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _phaseLabel(DayType type) {
    switch (type) {
      case DayType.menstruation:
        return 'calendar_phase_menstruation'.tr;
      case DayType.menstruationPredicted:
        return 'calendar_phase_menstruation_predicted'.tr;
      case DayType.fertile:
        return 'calendar_phase_fertile'.tr;
      case DayType.ovulation:
        return 'calendar_phase_ovulation'.tr;
      case DayType.normal:
        return '';
    }
  }
}

class _CellStyle {
  final Color background;
  final Color textColor;

  const _CellStyle({
    required this.background,
    required this.textColor,
  });
}

class _LogSummaryTile extends StatelessWidget {
  final dynamic log;

  const _LogSummaryTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    final items = <String>[];
    if (log.bleeding != BleedingLevel.none) {
      items.add('Sangrado: ${log.bleeding.name}');
    }
    if (log.cramps) items.add('Cólicos');
    if (log.pain != PainLevel.none) items.add('Dolor: ${log.pain.name}');
    if (log.symptoms.isNotEmpty) items.add('Síntomas: ${log.symptoms.join(", ")}');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(items.join(' · '), style: clune.bodyMedium),
    );
  }
}

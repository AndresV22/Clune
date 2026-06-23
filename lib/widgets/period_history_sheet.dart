import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/app_text_styles.dart';
import 'package:clune/controllers/daily_log_controller.dart';
import 'package:clune/models/cycle_record.dart';
import 'package:clune/utils/date_utils.dart';
import 'package:clune/utils/date_picker_utils.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';

/// Diálogo para registrar o editar un periodo menstrual.
class PeriodFormDialog extends StatefulWidget {
  final CycleRecord? existing;

  const PeriodFormDialog({super.key, this.existing});

  static Future<void> show({CycleRecord? existing}) {
    return showAppDialog(PeriodFormDialog(existing: existing));
  }

  @override
  State<PeriodFormDialog> createState() => _PeriodFormDialogState();
}

class _PeriodFormDialogState extends State<PeriodFormDialog> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _startDate = existing.startDate;
      _endDate = existing.endDate ?? existing.startDate;
    } else {
      final today = DateTime.now();
      _startDate = today;
      _endDate = today;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final clune = context.clune;

    return AlertDialog(
      title: Text(
        isEditing ? 'period_edit'.tr : 'period_title'.tr,
        style: TextStyle(color: clune.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('period_range'.tr, style: AppTextStyles.label.copyWith(color: clune.textPrimary)),
          const SizedBox(height: 8),
          Material(
            color: clune.inputFill,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _pickRange,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.date_range, color: AppColors.primaryTeal, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _formatRangeLabel(),
                        style: AppTextStyles.bodyLarge.copyWith(color: clune.textPrimary),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: clune.textSecondary, size: 20),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'period_range_hint'.tr,
            style: AppTextStyles.bodySmall.copyWith(color: clune.textSecondary),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
        ElevatedButton(
          onPressed: _save,
          child: Text('period_save'.tr),
        ),
      ],
    );
  }

  String _formatRangeLabel() {
    final start = AppDateUtils.normalizeDate(_startDate);
    final end = AppDateUtils.normalizeDate(_endDate);
    if (start == end) {
      return AppDateUtils.formatShortDate(start);
    }
    if (start.year == end.year && start.month == end.month) {
      return '${start.day} – ${AppDateUtils.formatShortDate(end)}';
    }
    return '${AppDateUtils.formatShortDate(start)} – ${AppDateUtils.formatShortDate(end)}';
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showAppDateRangePicker(
      initialDateRange: DateTimeRange(
        start: AppDateUtils.normalizeDate(_startDate),
        end: AppDateUtils.normalizeDate(_endDate),
      ),
      firstDate: now.subtract(const Duration(days: 1095)),
      lastDate: now,
    );
    if (picked == null) return;

    setState(() {
      _startDate = AppDateUtils.normalizeDate(picked.start);
      _endDate = AppDateUtils.normalizeDate(picked.end);
    });
  }

  Future<void> _save() async {
    final controller = Get.find<DailyLogController>();
    final normalizedStart = AppDateUtils.normalizeDate(_startDate);
    final normalizedEnd = AppDateUtils.normalizeDate(_endDate);

    if (widget.existing != null) {
      final cycle = widget.existing!
        ..startDate = normalizedStart
        ..endDate = normalizedEnd
        ..updatedAt = DateTime.now();
      await Get.find<DailyLogController>().updatePeriod(cycle);
    } else {
      await controller.savePeriod(startDate: normalizedStart, endDate: normalizedEnd);
    }

    Get.back();
  }
}

/// Abre el sheet de historial de periodos.
void openPeriodHistorySheet() {
  Get.bottomSheet(
    const PeriodHistorySheet(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

/// Sheet para gestionar periodos históricos.
class PeriodHistorySheet extends StatelessWidget {
  const PeriodHistorySheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DailyLogController>();
    final clune = context.clune;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: clune.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: clune.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('period_history'.tr, style: clune.headingMedium),
                        const SizedBox(height: 4),
                        Text(
                          'period_history_subtitle'.tr,
                          style: clune.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => PeriodFormDialog.show(),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('period_add'.tr),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Obx(() {
                final cycles = controller.periodHistory;
                if (cycles.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'period_history_empty'.tr,
                      style: clune.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  itemCount: cycles.length,
                  separatorBuilder: (_, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final cycle = cycles[ cycles.length - 1 - index ];
                    return _PeriodListTile(cycle: cycle);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodListTile extends StatelessWidget {
  final CycleRecord cycle;

  const _PeriodListTile({required this.cycle});

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    final end = cycle.endDate;
    final label = end != null
        ? '${AppDateUtils.formatShortDate(cycle.startDate)} – ${AppDateUtils.formatShortDate(end)}'
        : '${AppDateUtils.formatShortDate(cycle.startDate)} (${'period_active'.tr})';
    final days = end != null
        ? AppDateUtils.daysBetween(cycle.startDate, end) + 1
        : null;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryRed.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.water_drop, color: AppColors.primaryRed, size: 20),
      ),
      title: Text(label, style: clune.bodyLarge),
      subtitle: days != null
          ? Text('$days ${'period_days'.tr}', style: clune.bodySmall)
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => PeriodFormDialog.show(existing: cycle),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.primaryRed, size: 20),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showAppDialog<bool>(
      AlertDialog(
        title: Text('period_delete_title'.tr),
        content: Text('period_delete_message'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Get.find<DailyLogController>().deletePeriod(cycle.id);
    }
  }
}

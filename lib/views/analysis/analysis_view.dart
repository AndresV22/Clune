import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:clune/controllers/analysis_controller.dart';
import 'package:clune/widgets/cycle_predictions_section.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/app_text_styles.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';
import 'package:clune/utils/enums.dart';
import 'package:clune/utils/date_utils.dart';
import 'package:clune/services/statistics_service.dart';

/// Pantalla de análisis con estadísticas, gráficos y predicciones.
class AnalysisView extends GetView<AnalysisController> {
  const AnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    return SafeArea(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryTeal),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.loadAnalysis,
          color: AppColors.primaryTeal,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('analysis_title'.tr, style: clune.headingMedium),
                const SizedBox(height: 24),
                _buildStatsCards(context),
                const SizedBox(height: 32),
                _buildChartSection(
                  context,
                  'analysis_cycle_history'.tr,
                  _buildLineChart(context, controller.cycleHistory),
                ),
                const SizedBox(height: 24),
                _buildChartSection(
                  context,
                  'analysis_period_history'.tr,
                  _buildBarChart(context, controller.periodHistory, AppColors.primaryRed),
                ),
                const SizedBox(height: 24),
                _buildChartSection(
                  context,
                  'analysis_pain_history'.tr,
                  _buildLineChart(context, controller.painHistory, color: AppColors.orange),
                ),
                const SizedBox(height: 24),
                _buildSymptomFrequencyChart(context),
                const SizedBox(height: 24),
                _buildMoodChart(context),
                const SizedBox(height: 32),
                _buildPredictionsSection(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'analysis_avg_cycle'.tr,
            value: '${controller.avgCycleLength.value.round()} días',
            color: AppColors.primaryTeal,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'analysis_avg_period'.tr,
            value: '${controller.avgPeriodLength.value.round()} días',
            color: AppColors.primaryRed,
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection(BuildContext context, String title, Widget chart) {
    final clune = context.clune;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: clune.label),
        const SizedBox(height: 4),
        Text(
          '${'analysis_regularity'.tr}: ${controller.regularityText}',
          style: clune.bodySmall,
        ),
        const SizedBox(height: 12),
        SizedBox(height: 180, child: chart),
      ],
    );
  }

  Widget _buildLineChart(
    BuildContext context,
    RxList<ChartDataPoint> points, {
    Color color = AppColors.primaryTeal,
  }) {
    if (points.isEmpty) return _emptyChart(context);
    final clune = context.clune;
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < points.length) {
                  return Text(points[idx].label, style: clune.bodySmall);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) =>
                  Text('${value.toInt()}', style: clune.bodySmall),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, RxList<ChartDataPoint> points, Color color) {
    if (points.isEmpty) return _emptyChart(context);
    final clune = context.clune;
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < points.length) {
                  return Text(points[idx].label, style: clune.bodySmall);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) =>
                  Text('${value.toInt()}', style: clune.bodySmall),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: points.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value,
                color: color,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSymptomFrequencyChart(BuildContext context) {
    final clune = context.clune;
    final freqs = controller.symptomFrequencies;
    if (freqs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('analysis_symptom_freq'.tr, style: clune.label),
        const SizedBox(height: 12),
        ...freqs.take(5).map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(f.label, style: clune.bodySmall),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: f.percentage / 100,
                      backgroundColor: clune.divider,
                      color: AppColors.primaryTeal,
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${f.percentage.round()}%', style: clune.bodySmallPrimary),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildMoodChart(BuildContext context) {
    final clune = context.clune;
    final moods = controller.moodDistribution;
    if (moods.isEmpty || moods.values.every((v) => v == 0)) return const SizedBox.shrink();

    final total = moods.values.fold(0, (a, b) => a + b);
    final colors = {
      MoodType.happy: AppColors.yellow,
      MoodType.calm: AppColors.primaryTeal,
      MoodType.irritable: AppColors.orange,
      MoodType.anxious: AppColors.purple,
      MoodType.sad: AppColors.blue,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('analysis_mood_dist'.tr, style: clune.label),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 30,
              sections: moods.entries.where((e) => e.value > 0).map((e) {
                return PieChartSectionData(
                  value: e.value.toDouble(),
                  title: '${((e.value / total) * 100).round()}%',
                  color: colors[e.key],
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionsSection(BuildContext context) {
    final clune = context.clune;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('analysis_predictions'.tr, style: clune.label),
        const SizedBox(height: 12),
        CyclePredictionsSection(
          nextPeriodText: controller.nextPeriodText.value,
          nextFertileWindowText: controller.nextFertileWindowText.value,
          painPredictionText: controller.painPredictionText.value,
          moodPredictionText: controller.moodPredictionText.value,
          hasEnoughLogsForPersonalPredictions:
              controller.hasEnoughLogsForPersonalPredictions.value,
          trackingLogCount: controller.trackingLogCount.value,
        ),
        if (controller.symptomPredictions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('analysis_upcoming_symptoms'.tr, style: clune.label),
          const SizedBox(height: 8),
          ...controller.symptomPredictions.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.label, style: clune.bodyLarge),
                          if (p.date != null)
                            Text(
                              AppDateUtils.formatShortDate(p.date!),
                              style: clune.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '${p.probability.round()}%',
                      style: clune.label.copyWith(color: AppColors.primaryTeal),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  Widget _emptyChart(BuildContext context) {
    return Center(
      child: Text('Sin datos suficientes', style: context.clune.bodyMedium),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: clune.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headingMedium.copyWith(
              color: color,
              foreground: null,
            ),
          ),
        ],
      ),
    );
  }
}

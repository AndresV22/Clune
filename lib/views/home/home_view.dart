import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/controllers/home_controller.dart';
import 'package:clune/controllers/main_nav_controller.dart';
import 'package:clune/widgets/cycle_ring/cycle_ring_widget.dart';
import 'package:clune/widgets/daily_log_prompt.dart';
import 'package:clune/widgets/cycle_predictions_section.dart';
import 'package:clune/widgets/medication_reminder_card.dart';
import 'package:clune/widgets/pain_prediction_section.dart';
import 'package:clune/app/theme/app_colors.dart';
import 'package:clune/app/theme/clune_theme_colors.dart';
import 'package:clune/widgets/hormone_info_card.dart';
import 'package:clune/widgets/suggested_articles_section.dart';

/// Pantalla principal con anillo de ciclo estilo Clue.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.reloadData,
            color: AppColors.primaryTeal,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const _HomeTitleHeader(),
                  const SizedBox(height: 16),
                  Obx(() {
                    controller.selectedCycleDay.value;
                    return CycleRingWidget(
                      data: controller.ringData.value,
                      centerMessage: controller.centerMessage.value,
                      todaySubtitle: controller.todaySubtitle.value,
                      phaseLinkText: controller.phaseLinkText.value,
                      onPhaseTap: controller.showPhaseInfo,
                      onDaySelected: controller.selectCycleDay,
                      isViewingToday: controller.isViewingToday,
                      onResetToToday: controller.resetToToday,
                    );
                  }),
                  const SizedBox(height: 20),
                  DailyLogPrompt(
                    onTap: () => Get.find<MainNavController>().changeTab(2),
                  ),
                  const SizedBox(height: 24),
                  _buildPainSection(context),
                  const SizedBox(height: 24),
                  _buildPredictions(context),
                  const SizedBox(height: 24),
                  _buildHormoneSection(context),
                  const SizedBox(height: 24),
                  _buildSuggestedArticles(context),
                  const SizedBox(height: 32),
                  _buildFooter(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 16, right: 20),
              child: _FloatingMenuButton(onTap: controller.openMenu),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPainSection(BuildContext context) {
    final clune = context.clune;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('pain_prediction_title'.tr, style: clune.label),
          const SizedBox(height: 12),
          Obx(() => MedicationReminderCard(
                reminder: controller.medicationReminder.value,
                onUpdated: controller.reloadPainAndMedication,
              )),
          const SizedBox(height: 12),
          Obx(() => PainPredictionSection(
                forecasts: controller.painForecasts.toList(),
                topSymptoms: controller.topPainSymptoms.toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildPredictions(BuildContext context) {
    final clune = context.clune;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('home_predictions'.tr, style: clune.label),
          const SizedBox(height: 12),
          Obx(() => CyclePredictionsSection(
                nextPeriodText: controller.nextPeriodText.value,
                nextFertileWindowText: controller.nextFertileWindowText.value,
                painPredictionText: controller.painPredictionText.value,
                moodPredictionText: controller.moodPredictionText.value,
                hasEnoughLogsForPersonalPredictions:
                    controller.hasEnoughLogsForPersonalPredictions.value,
                trackingLogCount: controller.trackingLogCount.value,
              )),
        ],
      ),
    );
  }

  Widget _buildHormoneSection(BuildContext context) {
    final clune = context.clune;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('home_hormones_title'.tr, style: clune.label),
          const SizedBox(height: 12),
          Obx(() {
            final info = controller.hormonePhaseInfo.value;
            if (info == null) return const SizedBox.shrink();
            return Column(
              children: [
                if (controller.usesHormonalContraceptive.value) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: clune.chipBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'home_hormonal_contraceptive_notice'.tr,
                      style: clune.bodySmall,
                    ),
                  ),
                ],
                HormoneInfoCard(info: info),
                const SizedBox(height: 8),
                Text('home_hormones_disclaimer'.tr, style: clune.bodySmall),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSuggestedArticles(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() => SuggestedArticlesSection(
            articles: controller.suggestedArticles.toList(),
            onSeeAll: () => Get.find<MainNavController>().changeTab(4),
          )),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final clune = context.clune;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Text(
          'home_footer'.tr,
          style: clune.bodySmall.copyWith(
            color: clune.textSecondary,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _HomeTitleHeader extends StatefulWidget {
  const _HomeTitleHeader();

  @override
  State<_HomeTitleHeader> createState() => _HomeTitleHeaderState();
}

class _HomeTitleHeaderState extends State<_HomeTitleHeader> {
  int _tapCount = 0;
  DateTime? _lastTap;

  void _onTitleTap() {
    final now = DateTime.now();
    if (_lastTap != null &&
        now.difference(_lastTap!) > const Duration(seconds: 2)) {
      _tapCount = 0;
    }
    _lastTap = now;
    _tapCount++;

    if (_tapCount >= 5) {
      _tapCount = 0;
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(
            'home_easter_egg_message'.tr,
            textAlign: TextAlign.center,
            style: ctx.clune.bodyLarge,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('close'.tr),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: GestureDetector(
          onTap: _onTitleTap,
          behavior: HitTestBehavior.opaque,
          child: Text(
            'home_title'.tr,
            style: clune.headingMedium,
          ),
        ),
      ),
    );
  }
}

class _FloatingMenuButton extends StatelessWidget {
  final VoidCallback onTap;

  const _FloatingMenuButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final clune = context.clune;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: clune.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: clune.cardBorder,
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(Icons.menu, size: 20, color: clune.textPrimary),
      ),
    );
  }
}

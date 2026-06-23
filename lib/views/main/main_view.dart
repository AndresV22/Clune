import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clune/controllers/main_nav_controller.dart';
import 'package:clune/views/home/home_view.dart';
import 'package:clune/views/calendar/calendar_view.dart';
import 'package:clune/views/daily_log/daily_log_view.dart';
import 'package:clune/views/analysis/analysis_view.dart';
import 'package:clune/views/articles/articles_view.dart';
import 'package:clune/widgets/bottom_nav_bar.dart';

/// Shell principal con navegación inferior de 5 tabs.
class MainView extends GetView<MainNavController> {
  const MainView({super.key});

  static const _pages = [
    HomeView(),
    CalendarView(),
    DailyLogView(),
    AnalysisView(),
    ArticlesView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: _pages,
          )),
      bottomNavigationBar: const CluneBottomNavBar(),
    );
  }
}

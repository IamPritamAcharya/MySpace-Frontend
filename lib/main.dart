import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:myspace/app/bindings/initial_binding.dart';
import 'package:myspace/app/config/app_theme.dart';
import 'package:myspace/controllers/navigation_controller.dart';
import 'package:myspace/controllers/theme_controller.dart';
import 'package:myspace/leetcode_widget/heatmap/heatmap_workmanager.dart';
import 'package:myspace/leetcode_widget/heatmap/widget_launch_bridge.dart';
import 'package:myspace/leetcode_widget/heatmap/widget_updater.dart';
import 'package:myspace/ui/screens/shell_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HeatmapWorkmanager.initialize();
  final Uri? launchedFromWidget =
      await HomeWidget.initiallyLaunchedFromHomeWidget();

  runApp(MyApp(launchedFromWidget: launchedFromWidget));
}

class MyApp extends StatefulWidget {
  final Uri? launchedFromWidget;

  const MyApp({
    super.key,
    required this.launchedFromWidget,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    InitialBinding().dependencies();
    WidgetLaunchBridge.configure();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.launchedFromWidget == null) return;

      if (Get.isRegistered<NavigationController>()) {
        Get.find<NavigationController>().changePage(3);
      }

      await HeatmapWidgetUpdater.updateHeatmap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'MySpace',
        theme: AppTheme.fromSeed(themeCtrl.seedColor),
        home: const ShellScreen(),
      ),
    );
  }
}
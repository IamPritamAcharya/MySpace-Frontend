import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myspace/app/bindings/initial_binding.dart';
import 'package:myspace/app/config/app_theme.dart';
import 'package:myspace/controllers/theme_controller.dart';
import 'package:myspace/ui/screens/shell_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    InitialBinding().dependencies();

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

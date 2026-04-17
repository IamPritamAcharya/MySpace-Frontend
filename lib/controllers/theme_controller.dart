import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AppColor {
  green('Green', Colors.greenAccent, Icons.eco_rounded),
  blue('Blue', Colors.blueAccent, Icons.water_drop_rounded),
  purple('Purple', Colors.purpleAccent, Icons.auto_awesome_rounded),
  pink('Pink', Colors.pinkAccent, Icons.favorite_rounded),
  orange('Orange', Colors.orangeAccent, Icons.local_fire_department_rounded),
  teal('Teal', Colors.tealAccent, Icons.spa_rounded),
  indigo('Indigo', Colors.indigoAccent, Icons.nights_stay_rounded),
  red('Red', Colors.redAccent, Icons.whatshot_rounded);

  const AppColor(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

class ThemeController extends GetxController {
  final _selectedColor = AppColor.green.obs;

  AppColor get selectedColor => _selectedColor.value;
  Color get seedColor => _selectedColor.value.color;

  void changeColor(AppColor color) {
    _selectedColor.value = color;
  }
}

import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

class ThemeController extends GetxController {
  final isDark = false.obs;
  ThemeMode get themeMode => isDark.value ? ThemeMode.dark : ThemeMode.light;
  void toggle() => isDark.value = !isDark.value;
}

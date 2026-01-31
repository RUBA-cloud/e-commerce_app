import 'package:ecommerce_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final isDark = false.obs;
  ThemeMode get themeMode => isDark.value ? ThemeMode.dark : ThemeMode.light;
  void toggle() => isDark.value = !isDark.value;


  void getUserThemeandLanguage() {
    isDark.value = UserModel.currentUser?.themee =='dark' ? true : false;
    String language = UserModel.currentUser?.language ?? 'en';
    Get.changeTheme(isDark.value ? ThemeData.dark() : ThemeData.light());
    Get.updateLocale(Locale(language));
  }
}

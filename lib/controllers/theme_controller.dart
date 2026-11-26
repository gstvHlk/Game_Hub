import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Controla o modo claro/escuro (funcionalidade extra).
class ThemeController extends GetxController {
  static const String _storageKey = 'dark_mode';
  final GetStorage _box = GetStorage();

  final RxBool isDark = true.obs;

  @override
  void onInit() {
    super.onInit();
    isDark.value = _box.read<bool>(_storageKey) ?? true;
  }

  ThemeMode get themeMode => isDark.value ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    isDark.value = !isDark.value;
    Get.changeThemeMode(themeMode);
    _box.write(_storageKey, isDark.value);
  }
}

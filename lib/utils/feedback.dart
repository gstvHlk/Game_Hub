import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Mostra um Get.snackbar padronizado em todo o app.
void showFeedback(
  String title,
  String message, {
  bool isError = false,
  IconData? icon,
}) {
  if (Get.isSnackbarOpen) {
    Get.closeCurrentSnackbar();
  }

  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(12),
    borderRadius: 12,
    maxWidth: 520,
    duration: const Duration(seconds: 2),
    backgroundColor: isError ? Colors.red.shade700 : const Color(0xE6221C33),
    colorText: Colors.white,
    icon: Icon(
      icon ?? (isError ? Icons.error_outline : Icons.check_circle_outline),
      color: Colors.white,
    ),
  );
}

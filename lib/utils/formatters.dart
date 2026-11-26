import 'package:flutter/material.dart';

/// Converte "2022-10-04" em "04/10/2022".
String formatDate(String raw) {
  if (raw.trim().isEmpty) return 'Não informada';
  final date = DateTime.tryParse(raw);
  if (date == null) return raw;
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}

/// Retorna um texto padrão quando o valor está vazio.
String orDefault(String value, [String fallback = 'Não informado']) {
  final text = value.trim();
  return text.isEmpty || text == '?' ? fallback : text;
}

/// Limpa entidades HTML e tags que às vezes vêm na descrição da API.
String cleanDescription(String text) {
  return text
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&#039;', "'")
      .replaceAll('&#39;', "'")
      .replaceAll('&quot;', '"')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('\r\n', '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}

String plural(int count, String singular, String pluralForm) =>
    '$count ${count == 1 ? singular : pluralForm}';

IconData platformIcon(String platform) {
  final p = platform.toLowerCase();
  final windows = p.contains('windows');
  final browser = p.contains('browser');
  if (windows && browser) return Icons.devices;
  if (browser) return Icons.language;
  return Icons.desktop_windows_outlined;
}

/// Nome mais curto para exibir nos cards.
String shortPlatform(String platform) {
  final p = platform.toLowerCase();
  final windows = p.contains('windows');
  final browser = p.contains('browser');
  if (windows && browser) return 'PC • Navegador';
  if (browser) return 'Navegador';
  if (windows) return 'PC';
  return platform;
}

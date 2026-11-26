import 'package:url_launcher/url_launcher.dart';

import 'feedback.dart';

/// Abre um link externo (site do jogo, FreeToGame etc.) em nova aba/navegador.
Future<void> openLink(String url) async {
  final uri = Uri.tryParse(url.trim());
  if (url.trim().isEmpty || uri == null || !uri.hasScheme) {
    showFeedback('Link indisponível', 'Este link não foi informado pela API.',
        isError: true);
    return;
  }

  try {
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
    if (!opened) {
      showFeedback('Não foi possível abrir', url, isError: true);
    }
  } catch (_) {
    showFeedback('Não foi possível abrir', url, isError: true);
  }
}

import 'package:flutter/material.dart';

/// Imagem carregada da internet (Image.network) com indicador de
/// carregamento e placeholder quando a imagem estiver indisponível.
class GameImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;

  const GameImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) return _placeholder(context);

    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      // Na Web, se o servidor de imagens não permitir CORS, o Flutter usa
      // uma tag <img> como alternativa, evitando imagens quebradas.
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.videogame_asset_off_outlined,
        size: 36,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}

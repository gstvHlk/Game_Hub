import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/game_image.dart';
import '../components/source_attribution.dart';
import '../components/state_views.dart';
import '../controllers/favorite_controller.dart';
import '../controllers/game_controller.dart';
import '../models/game_detail_model.dart';
import '../models/game_model.dart';
import '../utils/formatters.dart';
import '../utils/link_utils.dart';

/// Tela de detalhes: faz uma nova requisição GET /game?id=ID.
class GameDetailPage extends StatefulWidget {
  final GameModel game;

  const GameDetailPage({super.key, required this.game});

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  final GameController controller = Get.find<GameController>();
  final FavoriteController favoriteController = Get.find<FavoriteController>();

  @override
  void initState() {
    super.initState();
    controller.fetchGameDetail(widget.game.id);
  }

  /// Usa os dados completos do detalhe quando já carregados.
  GameModel get _gameForFavorite =>
      controller.gameDetail.value?.id == widget.game.id
          ? controller.gameDetail.value!.toGameModel()
          : widget.game;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        actions: [
          Obx(() {
            final isFav = favoriteController.isFavorite(widget.game.id);
            return IconButton(
              tooltip: isFav ? 'Remover dos favoritos' : 'Favoritar',
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.pinkAccent : null),
              onPressed: () =>
                  favoriteController.toggleFavorite(_gameForFavorite),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingDetail.value) {
          return const LoadingView(message: 'Carregando detalhes do jogo...');
        }

        final error = controller.detailError.value;
        if (error != null) {
          return ErrorView(
            message: error,
            onRetry: () => controller.fetchGameDetail(widget.game.id),
            secondaryLabel: 'Voltar',
            onSecondary: () => Get.back(),
          );
        }

        final detail = controller.gameDetail.value;
        if (detail == null || detail.id != widget.game.id) {
          return ErrorView(
            message: 'Detalhes indisponíveis para este jogo.',
            onRetry: () => controller.fetchGameDetail(widget.game.id),
          );
        }

        return _DetailContent(
          detail: detail,
          heroTag: 'game-image-${widget.game.id}',
          onToggleFavorite: () =>
              favoriteController.toggleFavorite(detail.toGameModel()),
        );
      }),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final GameDetailModel detail;
  final String heroTag;
  final VoidCallback onToggleFavorite;

  const _DetailContent({
    required this.detail,
    required this.heroTag,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final favoriteController = Get.find<FavoriteController>();
    final requirements = detail.minimumSystemRequirements;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem e título
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Hero(
                    tag: heroTag,
                    child: GameImage(url: detail.thumbnail),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(detail.title,
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              if (detail.developer.isNotEmpty)
                Text(detail.developer,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.category_outlined, size: 18),
                    label: Text(detail.genre),
                  ),
                  Chip(
                    avatar: Icon(platformIcon(detail.platform), size: 18),
                    label: Text(detail.platform),
                  ),
                  if (detail.status.isNotEmpty)
                    Chip(
                      avatar: const Icon(Icons.circle,
                          size: 12, color: Colors.green),
                      label: Text(detail.status),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Ações: jogar e favoritar
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: detail.gameUrl.isEmpty
                        ? null
                        : () => openLink(detail.gameUrl),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Acessar o jogo'),
                  ),
                  Obx(() {
                    final isFav = favoriteController.isFavorite(detail.id);
                    return FilledButton.tonalIcon(
                      onPressed: onToggleFavorite,
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                      label: Text(
                          isFav ? 'Remover dos favoritos' : 'Favoritar'),
                    );
                  }),
                ],
              ),

              _SectionTitle('Sobre o jogo'),
              SelectableText(
                cleanDescription(detail.description).isEmpty
                    ? 'Descrição não informada.'
                    : cleanDescription(detail.description),
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),

              _SectionTitle('Informações'),
              _InfoCard(rows: [
                _InfoRow('Gênero', orDefault(detail.genre)),
                _InfoRow('Plataforma', orDefault(detail.platform, 'Não informada')),
                _InfoRow('Desenvolvedora', orDefault(detail.developer, 'Não informada')),
                _InfoRow('Publicadora', orDefault(detail.publisher, 'Não informada')),
                _InfoRow('Lançamento', formatDate(detail.releaseDate)),
              ]),

              if (detail.screenshots.isNotEmpty) ...[
                _SectionTitle('Capturas de tela'),
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: detail.screenshots.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GameImage(
                        url: detail.screenshots[index],
                        width: 320,
                        height: 180,
                      ),
                    ),
                  ),
                ),
              ],

              _SectionTitle('Requisitos mínimos de sistema'),
              if (requirements != null && !requirements.isEmpty)
                _InfoCard(rows: [
                  _InfoRow('Sistema', orDefault(requirements.os)),
                  _InfoRow('Processador', orDefault(requirements.processor)),
                  _InfoRow('Memória', orDefault(requirements.memory)),
                  _InfoRow('Placa de vídeo', orDefault(requirements.graphics)),
                  _InfoRow('Armazenamento', orDefault(requirements.storage)),
                ])
              else
                Text(
                  'Requisitos não informados pela API '
                  '(comum em jogos de navegador).',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),

              if (detail.freetogameProfileUrl.isNotEmpty) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => openLink(detail.freetogameProfileUrl),
                  icon: const Icon(Icons.link),
                  label: const Text('Ver página do jogo no FreeToGame'),
                ),
              ],
              const SizedBox(height: 8),
              const SourceAttribution(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> rows;

  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            for (int i = 0; i < rows.length; i++) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(rows[i].label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ),
                    Expanded(
                      child: Text(rows[i].value,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              if (i < rows.length - 1) const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }
}

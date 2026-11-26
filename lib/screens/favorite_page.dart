import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/game_image.dart';
import '../components/state_views.dart';
import '../controllers/favorite_controller.dart';
import '../models/game_model.dart';
import '../utils/formatters.dart';
import 'game_detail_page.dart';

/// Lista pessoal de jogos favoritos (RxList + Obx).
class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FavoriteController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: Obx(() {
        final favorites = controller.favorites;

        if (favorites.isEmpty) {
          return EmptyView(
            icon: Icons.favorite_border,
            title: 'Nenhum favorito ainda',
            message:
                'Abra os detalhes de um jogo e toque em "Favoritar" para adicioná-lo aqui.',
            actionLabel: 'Explorar jogos',
            onAction: () => Get.back(),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: favorites.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _FavoriteTile(
                  game: favorites[index],
                  onRemove: () => controller.removeFavorite(favorites[index]),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  plural(favorites.length, 'jogo favorito', 'jogos favoritos'),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  final GameModel game;
  final VoidCallback onRemove;

  const _FavoriteTile({required this.game, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Card(
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            onTap: () => Get.to(() => GameDetailPage(game: game)),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GameImage(url: game.thumbnail, width: 96, height: 54),
            ),
            title: Text(game.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${game.genre} • ${shortPlatform(game.platform)}'),
            trailing: TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remover'),
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ),
    );
  }
}

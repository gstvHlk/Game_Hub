import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/filter_bottom_sheet.dart';
import '../components/game_card.dart';
import '../components/source_attribution.dart';
import '../components/state_views.dart';
import '../controllers/favorite_controller.dart';
import '../controllers/game_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/game_model.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import 'favorite_page.dart';
import 'game_detail_page.dart';

/// Tela inicial: listagem de jogos (GET /games), busca, filtros e favoritos.
class GameListPage extends StatefulWidget {
  const GameListPage({super.key});

  @override
  State<GameListPage> createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage> {
  final GameController controller = Get.find<GameController>();
  final FavoriteController favoriteController = Get.find<FavoriteController>();
  final ThemeController themeController = Get.find<ThemeController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(GameModel game) => Get.to(() => GameDetailPage(game: game));

  void _openFavorites() => Get.to(() => const FavoritePage());

  void _openFilters() {
    Get.bottomSheet(
      const FilterBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    controller.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.sports_esports),
            SizedBox(width: 8),
            Text('Game Hub', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchGames,
          ),
          Obx(
            () => IconButton(
              tooltip: 'Filtros e ordenação',
              onPressed: _openFilters,
              icon: Badge(
                isLabelVisible: controller.hasActiveFilters,
                smallSize: 8,
                child: const Icon(Icons.tune),
              ),
            ),
          ),
          Obx(
            () => IconButton(
              tooltip: 'Favoritos',
              onPressed: _openFavorites,
              icon: Badge(
                isLabelVisible: favoriteController.favorites.isNotEmpty,
                label: Text('${favoriteController.favorites.length}'),
                child: const Icon(Icons.favorite_outline),
              ),
            ),
          ),
          Obx(
            () => IconButton(
              tooltip: themeController.isDark.value
                  ? 'Modo claro'
                  : 'Modo escuro',
              onPressed: themeController.toggleTheme,
              icon: Icon(themeController.isDark.value
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          _buildSearchField(),
          _buildFilterSummary(),
          Expanded(child: Obx(_buildContent)),
          const SourceAttribution(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: TextField(
            controller: _searchController,
            onChanged: controller.updateSearch,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Buscar jogo pelo nome...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Obx(
                () => controller.searchQuery.value.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        tooltip: 'Limpar busca',
                        icon: const Icon(Icons.close),
                        onPressed: _clearSearch,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSummary() {
    return Obx(() {
      final chips = <Widget>[];

      if (controller.selectedPlatform.value != GameFilters.all) {
        chips.add(_filterChip(
          'Plataforma: ${GameFilters.labelFor(GameFilters.platforms, controller.selectedPlatform.value)}',
          () => controller.applyFilters(
            platform: GameFilters.all,
            category: controller.selectedCategory.value,
            sort: controller.selectedSort.value,
          ),
        ));
      }
      if (controller.selectedCategory.value != GameFilters.all) {
        chips.add(_filterChip(
          'Categoria: ${GameFilters.labelFor(GameFilters.categories, controller.selectedCategory.value)}',
          () => controller.applyFilters(
            platform: controller.selectedPlatform.value,
            category: GameFilters.all,
            sort: controller.selectedSort.value,
          ),
        ));
      }
      if (controller.selectedSort.value.isNotEmpty) {
        chips.add(_filterChip(
          'Ordem: ${GameFilters.labelFor(GameFilters.sorts, controller.selectedSort.value)}',
          () => controller.applyFilters(
            platform: controller.selectedPlatform.value,
            category: controller.selectedCategory.value,
            sort: '',
          ),
        ));
      }

      final showCount = !controller.isLoading.value &&
          controller.errorMessage.value == null &&
          controller.games.isNotEmpty;

      if (chips.isEmpty && !showCount) return const SizedBox(height: 4);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (showCount)
              Text(
                plural(controller.visibleGames.length, 'jogo', 'jogos'),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ...chips,
            if (chips.isNotEmpty)
              TextButton.icon(
                onPressed: controller.clearFilters,
                icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                label: const Text('Limpar filtros'),
              ),
          ],
        ),
      );
    });
  }

  Widget _filterChip(String label, VoidCallback onDeleted) {
    return InputChip(
      label: Text(label),
      onDeleted: onDeleted,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildContent() {
    if (controller.isLoading.value) {
      return const LoadingView(message: 'Carregando jogos...');
    }

    final error = controller.errorMessage.value;
    if (error != null) {
      return ErrorView(message: error, onRetry: controller.fetchGames);
    }

    if (controller.games.isEmpty) {
      return EmptyView(
        icon: Icons.videogame_asset_off_outlined,
        title: 'Nenhum jogo encontrado',
        message: 'Não há jogos para os filtros selecionados.',
        actionLabel: 'Limpar filtros',
        onAction: controller.clearFilters,
      );
    }

    final games = controller.visibleGames;
    if (games.isEmpty) {
      return EmptyView(
        icon: Icons.search_off,
        title: 'Nenhum jogo encontrado',
        message: 'Nenhum resultado para "${controller.searchQuery.value}".',
        actionLabel: 'Limpar busca',
        onAction: _clearSearch,
      );
    }

    return RefreshIndicator(
      onRefresh: controller.fetchGames,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 360,
          mainAxisExtent: 300,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return GameCard(game: game, onTap: () => _openDetail(game));
        },
      ),
    );
  }
}

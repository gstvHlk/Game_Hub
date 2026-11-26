import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/game_model.dart';
import '../utils/feedback.dart';

/// Lista reativa de favoritos (RxList + Obx).
/// Extra: os favoritos são persistidos com GetStorage.
class FavoriteController extends GetxController {
  static const String _storageKey = 'favorite_games';
  final GetStorage _box = GetStorage();

  final RxList<GameModel> favorites = <GameModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  bool isFavorite(int id) => favorites.any((game) => game.id == id);

  void addFavorite(GameModel game) {
    // Impede duplicidade comparando pelo ID.
    if (isFavorite(game.id)) {
      showFeedback('Já está nos favoritos', game.title,
          icon: Icons.info_outline);
      return;
    }
    favorites.add(game);
    _saveToStorage();
    showFeedback('Adicionado aos favoritos', game.title, icon: Icons.favorite);
  }

  void removeFavorite(GameModel game) {
    favorites.removeWhere((item) => item.id == game.id);
    _saveToStorage();
    showFeedback('Removido dos favoritos', game.title,
        icon: Icons.heart_broken_outlined);
  }

  void toggleFavorite(GameModel game) {
    if (isFavorite(game.id)) {
      removeFavorite(game);
    } else {
      addFavorite(game);
    }
  }

  void _loadFromStorage() {
    try {
      final raw = _box.read(_storageKey);
      if (raw is List) {
        favorites.assignAll(
          raw
              .whereType<Map>()
              .map((item) => GameModel.fromJson(Map<String, dynamic>.from(item))),
        );
      }
    } catch (_) {
      favorites.clear();
    }
  }

  void _saveToStorage() {
    _box.write(_storageKey, favorites.map((game) => game.toJson()).toList());
  }
}

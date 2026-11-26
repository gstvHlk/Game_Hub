import 'package:get/get.dart';

import '../models/game_detail_model.dart';
import '../models/game_model.dart';
import '../services/api_exception.dart';
import '../services/game_service.dart';
import '../utils/constants.dart';

/// Coordena as chamadas ao [GameService] e guarda o estado das telas:
/// lista de jogos, carregamento, erros, busca, filtros e detalhes.
class GameController extends GetxController {
  final GameService _service = Get.find<GameService>();

  // ----------------------------- Listagem -----------------------------------
  final RxList<GameModel> games = <GameModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  // ------------------------------- Busca ------------------------------------
  final RxString searchQuery = ''.obs;

  // --------------------------- Filtros/ordem --------------------------------
  final RxString selectedPlatform = GameFilters.all.obs;
  final RxString selectedCategory = GameFilters.all.obs;
  final RxString selectedSort = ''.obs;

  // ------------------------------ Detalhes ----------------------------------
  final Rxn<GameDetailModel> gameDetail = Rxn<GameDetailModel>();
  final RxBool isLoadingDetail = false.obs;
  final RxnString detailError = RxnString();
  int? _currentDetailId;

  // Controle simples para respeitar o limite de ~10 requisições/segundo.
  DateTime? _lastRequestAt;
  static const Duration _minInterval = Duration(milliseconds: 150);

  @override
  void onInit() {
    super.onInit();
    fetchGames();
  }

  /// Jogos exibidos: resultado da API filtrado localmente pela busca
  /// (sem diferenciar maiúsculas/minúsculas).
  List<GameModel> get visibleGames {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return games.toList();
    return games
        .where((game) => game.title.toLowerCase().contains(query))
        .toList();
  }

  bool get hasActiveFilters =>
      selectedPlatform.value != GameFilters.all ||
      selectedCategory.value != GameFilters.all ||
      selectedSort.value.isNotEmpty;

  /// GET /games com os parâmetros selecionados.
  Future<void> fetchGames() async {
    if (isLoading.value) return; // evita requisições duplicadas

    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _respectRateLimit();
      final result = await _service.fetchGames(
        platform: selectedPlatform.value,
        category: selectedCategory.value,
        sortBy: selectedSort.value,
      );
      games.assignAll(result);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Ocorreu um erro inesperado ao carregar os jogos.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Aplica filtros/ordenação e faz uma nova requisição HTTP.
  Future<void> applyFilters({
    required String platform,
    required String category,
    required String sort,
  }) async {
    final changed = platform != selectedPlatform.value ||
        category != selectedCategory.value ||
        sort != selectedSort.value;

    selectedPlatform.value = platform;
    selectedCategory.value = category;
    selectedSort.value = sort;

    // Evita requisição desnecessária quando nada mudou e já há dados.
    if (!changed && games.isNotEmpty && errorMessage.value == null) return;

    await fetchGames();
  }

  /// Limpa os filtros e volta para a listagem padrão (GET /games).
  Future<void> clearFilters() async {
    selectedPlatform.value = GameFilters.all;
    selectedCategory.value = GameFilters.all;
    selectedSort.value = '';
    await fetchGames();
  }

  void updateSearch(String value) => searchQuery.value = value;

  void clearSearch() => searchQuery.value = '';

  /// GET /game?id=ID — sempre faz uma nova requisição ao abrir os detalhes.
  Future<void> fetchGameDetail(int id) async {
    _currentDetailId = id;
    gameDetail.value = null;
    detailError.value = null;
    isLoadingDetail.value = true;

    try {
      await _respectRateLimit();
      final detail = await _service.fetchGameDetail(id);
      if (_currentDetailId == id) gameDetail.value = detail;
    } on ApiException catch (e) {
      if (_currentDetailId == id) detailError.value = e.message;
    } catch (_) {
      if (_currentDetailId == id) {
        detailError.value = 'Ocorreu um erro inesperado ao carregar o jogo.';
      }
    } finally {
      if (_currentDetailId == id) isLoadingDetail.value = false;
    }
  }

  Future<void> _respectRateLimit() async {
    final last = _lastRequestAt;
    if (last != null) {
      final elapsed = DateTime.now().difference(last);
      if (elapsed < _minInterval) {
        await Future.delayed(_minInterval - elapsed);
      }
    }
    _lastRequestAt = DateTime.now();
  }
}

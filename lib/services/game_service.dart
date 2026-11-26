import 'dart:convert';

import 'package:get/get.dart';

import '../models/game_detail_model.dart';
import '../models/game_model.dart';
import 'api_exception.dart';

/// Responsável por TODAS as requisições HTTP à API FreeToGame.
///
/// Endpoints utilizados:
///  - GET /games                       -> listar todos os jogos
///  - GET /game?id=540                 -> detalhes de um jogo
///  - GET /games?category=shooter      -> filtrar por categoria
///  - GET /games?platform=windows      -> filtrar por plataforma
///  - GET /games?sort-by=alphabetical  -> ordenar
class GameService extends GetConnect {
  static const String apiBaseUrl = 'https://www.freetogame.com/api';

  // Em requisições GET o GetConnect envia "content-type: application/json"
  // por padrão. No navegador isso força uma requisição extra de "preflight"
  // (CORS). Como não enviamos corpo, usamos "text/plain", que é um tipo
  // considerado simples pelo navegador.
  static const String _simpleContentType = 'text/plain';

  GameService() : super(timeout: const Duration(seconds: 20)) {
    baseUrl = apiBaseUrl;
  }

  /// Método genérico de listagem: trata listagem, filtros e ordenação.
  /// Parâmetros vazios ou "all" são omitidos da requisição.
  Future<List<GameModel>> fetchGames({
    String? platform,
    String? category,
    String? sortBy,
  }) async {
    final query = <String, dynamic>{};
    if (_hasValue(platform)) query['platform'] = platform!;
    if (_hasValue(category)) query['category'] = category!;
    if (_hasValue(sortBy)) query['sort-by'] = sortBy!;

    final response = await _get('/games', query: query);

    // Quando nenhum jogo é encontrado a API responde 404 com um objeto
    // {"status": 0, "status_message": "..."}. Tratamos como lista vazia.
    if (response.statusCode == 404) return [];
    _checkStatus(response);

    final data = _decode(response);
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => GameModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    if (data is Map && data['status'] == 0) return [];

    throw const ApiException(
        'A API retornou um formato inesperado para a lista de jogos.');
  }

  /// Consulta os detalhes de um jogo: GET /game?id=ID
  Future<GameDetailModel> fetchGameDetail(int id) async {
    final response = await _get('/game', query: {'id': '$id'});

    if (response.statusCode == 404) {
      throw const ApiException('Jogo não encontrado na API.', statusCode: 404);
    }
    _checkStatus(response);

    final data = _decode(response);
    if (data is Map && data['id'] != null) {
      return GameDetailModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw const ApiException(
        'A API retornou um formato inesperado para os detalhes do jogo.');
  }

  // ---------------------------------------------------------------------------
  // Auxiliares
  // ---------------------------------------------------------------------------

  bool _hasValue(String? value) =>
      value != null && value.isNotEmpty && value != 'all';

  Future<Response<dynamic>> _get(String path,
      {Map<String, dynamic>? query}) async {
    try {
      return await get<dynamic>(
        path,
        query: (query == null || query.isEmpty) ? null : query,
        contentType: _simpleContentType,
      );
    } catch (_) {
      throw const ApiException(
          'Não foi possível conectar ao servidor. Verifique sua conexão com a internet.');
    }
  }

  void _checkStatus(Response response) {
    final code = response.statusCode;

    if (code == null || code == 0) {
      throw const ApiException(
          'Falha de conexão com a API. Verifique sua internet e tente novamente.');
    }
    if (code == 429) {
      throw const ApiException(
          'Muitas requisições em pouco tempo. Aguarde alguns segundos.',
          statusCode: 429);
    }
    if (code >= 500) {
      throw ApiException(
          'O servidor da FreeToGame está indisponível no momento (erro $code).',
          statusCode: code);
    }
    if (code < 200 || code >= 300) {
      throw ApiException('Erro na requisição (HTTP $code).', statusCode: code);
    }
  }

  dynamic _decode(Response response) {
    final body = response.body;
    if (body is List || body is Map) return body;

    final text = response.bodyString;
    if (text == null || text.trim().isEmpty) {
      throw const ApiException('A API retornou uma resposta vazia.');
    }
    try {
      return jsonDecode(text);
    } on FormatException {
      throw const ApiException('A API retornou dados em formato inválido.');
    }
  }
}

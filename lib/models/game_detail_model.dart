import '../utils/json_utils.dart';
import 'game_model.dart';

/// Requisitos mínimos de sistema (normalmente só existem em jogos de PC).
class SystemRequirements {
  final String os;
  final String processor;
  final String memory;
  final String graphics;
  final String storage;

  const SystemRequirements({
    required this.os,
    required this.processor,
    required this.memory,
    required this.graphics,
    required this.storage,
  });

  factory SystemRequirements.fromJson(Map<String, dynamic> json) {
    return SystemRequirements(
      os: parseString(json['os']),
      processor: parseString(json['processor']),
      memory: parseString(json['memory']),
      graphics: parseString(json['graphics']),
      storage: parseString(json['storage']),
    );
  }

  bool get isEmpty => [os, processor, memory, graphics, storage]
      .every((value) => value.isEmpty || value == '?');
}

/// Representa o retorno de `GET /game?id=ID`, com informações adicionais.
class GameDetailModel {
  final int id;
  final String title;
  final String thumbnail;
  final String status;
  final String shortDescription;
  final String description;
  final String gameUrl;
  final String genre;
  final String platform;
  final String publisher;
  final String developer;
  final String releaseDate;
  final String freetogameProfileUrl;
  final SystemRequirements? minimumSystemRequirements;
  final List<String> screenshots;

  const GameDetailModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.status,
    required this.shortDescription,
    required this.description,
    required this.gameUrl,
    required this.genre,
    required this.platform,
    required this.publisher,
    required this.developer,
    required this.releaseDate,
    required this.freetogameProfileUrl,
    required this.minimumSystemRequirements,
    required this.screenshots,
  });

  factory GameDetailModel.fromJson(Map<String, dynamic> json) {
    final requirementsJson = json['minimum_system_requirements'];
    final screenshotsJson = json['screenshots'];

    return GameDetailModel(
      id: parseInt(json['id']),
      title: parseString(json['title'], fallback: 'Sem título'),
      thumbnail: parseString(json['thumbnail']),
      status: parseString(json['status']),
      shortDescription: parseString(json['short_description']),
      description: parseString(
        json['description'],
        fallback: parseString(json['short_description']),
      ),
      gameUrl: parseString(json['game_url']),
      genre: parseString(json['genre'], fallback: 'Não informado'),
      platform: parseString(json['platform'], fallback: 'Não informada'),
      publisher: parseString(json['publisher']),
      developer: parseString(json['developer']),
      releaseDate: parseString(json['release_date']),
      freetogameProfileUrl: parseString(json['freetogame_profile_url']),
      minimumSystemRequirements: requirementsJson is Map
          ? SystemRequirements.fromJson(
              Map<String, dynamic>.from(requirementsJson))
          : null,
      screenshots: screenshotsJson is List
          ? screenshotsJson
              .whereType<Map>()
              .map((item) => parseString(item['image']))
              .where((url) => url.isNotEmpty)
              .toList()
          : const [],
    );
  }

  /// Converte o detalhe em um [GameModel] para salvar nos favoritos.
  GameModel toGameModel() => GameModel(
        id: id,
        title: title,
        thumbnail: thumbnail,
        shortDescription: shortDescription,
        gameUrl: gameUrl,
        genre: genre,
        platform: platform,
        publisher: publisher,
        developer: developer,
        releaseDate: releaseDate,
        freetogameProfileUrl: freetogameProfileUrl,
      );
}

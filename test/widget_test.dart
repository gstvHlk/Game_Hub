import 'package:flutter_test/flutter_test.dart';
import 'package:game_hub/models/game_detail_model.dart';
import 'package:game_hub/models/game_model.dart';
import 'package:game_hub/utils/formatters.dart';

void main() {
  test('GameModel.fromJson converte o JSON da listagem', () {
    final game = GameModel.fromJson({
      'id': 540,
      'title': 'Overwatch',
      'thumbnail': 'https://www.freetogame.com/g/540/thumbnail.jpg',
      'genre': 'Shooter',
      'platform': 'PC (Windows)',
      'release_date': '2022-10-04',
    });

    expect(game.id, 540);
    expect(game.title, 'Overwatch');
    expect(game.genre, 'Shooter');
    expect(game.publisher, ''); // campo ausente não quebra o app
  });

  test('GameDetailModel trata campos opcionais ausentes', () {
    final detail = GameDetailModel.fromJson({
      'id': 1,
      'title': 'Jogo de navegador',
      'platform': 'Web Browser',
    });

    expect(detail.minimumSystemRequirements, isNull);
    expect(detail.screenshots, isEmpty);
    expect(detail.toGameModel().id, 1);
  });

  test('formatDate converte para o padrão brasileiro', () {
    expect(formatDate('2022-10-04'), '04/10/2022');
    expect(formatDate(''), 'Não informada');
  });
}

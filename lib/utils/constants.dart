/// Opção de filtro: [value] vai para a API, [label] aparece na tela.
class FilterOption {
  final String value;
  final String label;

  const FilterOption(this.value, this.label);
}

class GameFilters {
  GameFilters._();

  static const String all = 'all';

  /// Parâmetro `platform`.
  static const List<FilterOption> platforms = [
    FilterOption(all, 'Todas'),
    FilterOption('windows', 'Windows'),
    FilterOption('browser', 'Navegador'),
  ];

  /// Parâmetro `category` ("Todas" omite o parâmetro).
  static const List<FilterOption> categories = [
    FilterOption(all, 'Todas'),
    FilterOption('shooter', 'Shooter'),
    FilterOption('mmorpg', 'MMORPG'),
    FilterOption('strategy', 'Strategy'),
    FilterOption('racing', 'Racing'),
    FilterOption('moba', 'MOBA'),
    FilterOption('battle-royale', 'Battle Royale'),
    FilterOption('card', 'Card'),
    FilterOption('sports', 'Sports'),
  ];

  /// Parâmetro `sort-by` ("" = ordem padrão da API, parâmetro omitido).
  static const List<FilterOption> sorts = [
    FilterOption('', 'Padrão'),
    FilterOption('popularity', 'Popularidade'),
    FilterOption('alphabetical', 'Alfabética'),
    FilterOption('release-date', 'Lançamento'),
  ];

  static String labelFor(List<FilterOption> options, String value) {
    return options
        .firstWhere((o) => o.value == value, orElse: () => options.first)
        .label;
  }
}

class AppLinks {
  AppLinks._();

  static const String freeToGame = 'https://www.freetogame.com';
}

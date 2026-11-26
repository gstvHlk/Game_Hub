# 🎮 Game Hub

Catálogo de jogos gratuitos desenvolvido em **Flutter + GetX**, consumindo a API REST pública **[FreeToGame](https://www.freetogame.com/api-doc)**.

## 👤 Identificação

| | |
|---|---|
| **Aluno** | Gustavo H. da S. Holek |
| **Curso** | Análise e Desenvolvimento de Sistemas — UniSENAI Chapecó/SC |
| **Disciplina** | Desenvolvimento Mobile — Flutter |
| **Turma** | _preencher_ |
| **Aplicação publicada** | https://SEU-USUARIO.github.io/game_hub/ |

## ✅ Funcionalidades

- Listagem de jogos (`GET /games`) em grade responsiva com `GridView.builder` e `Image.network`
- Detalhes do jogo com nova requisição (`GET /game?id=ID`): descrição, gênero, plataforma, desenvolvedora, publicadora, lançamento, requisitos mínimos, capturas de tela e link do jogo
- Filtro por **plataforma** (`platform`), **categoria** (`category`) e **ordenação** (`sort-by`) — cada um gera uma nova requisição; também é possível combiná-los
- Busca local por nome (sem diferenciar maiúsculas/minúsculas)
- Favoritos com `RxList` + `Obx`, sem duplicidade (comparação por ID)
- Tratamento de carregamento, erros (com "Tentar novamente") e listas vazias
- Link ativo para a fonte dos dados: FreeToGame.com

**Extras:** favoritos persistidos com GetStorage, modo claro/escuro, pull-to-refresh, layout responsivo, carrossel de screenshots e combinação de filtros.

## 🗂️ Estrutura

```
lib/
  models/        game_model.dart, game_detail_model.dart
  services/      game_service.dart (GetConnect), api_exception.dart
  controllers/   game_controller.dart, favorite_controller.dart, theme_controller.dart
  screens/       game_list_page.dart, game_detail_page.dart, favorite_page.dart
  components/    game_card.dart, game_image.dart, filter_bottom_sheet.dart,
                 state_views.dart, source_attribution.dart
  utils/         constants.dart, formatters.dart, feedback.dart, link_utils.dart, json_utils.dart
  theme/         app_theme.dart
  main.dart
```

## ▶️ Como executar

Pré-requisito: Flutter 3.29 ou superior (`flutter --version`).

```bash
flutter create .          # gera as pastas de plataforma (web/, windows/...) se ainda não existirem
flutter pub get
flutter run -d chrome     # executa no navegador
```

Testes: `flutter test`

## 🌐 Publicação (GitHub Pages)

```bash
flutter build web --base-href "/game_hub/"
```

O repositório já possui o workflow `.github/workflows/deploy.yml`, que gera e publica o `build/web` automaticamente a cada push na branch `main` (em **Settings → Pages**, selecione **Source: GitHub Actions**).

## 📡 API

- Base: `https://www.freetogame.com/api`
- Documentação: https://www.freetogame.com/api-doc
- Dados fornecidos por [FreeToGame.com](https://www.freetogame.com)

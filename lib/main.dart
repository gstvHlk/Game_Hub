import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'controllers/favorite_controller.dart';
import 'controllers/game_controller.dart';
import 'controllers/theme_controller.dart';
import 'screens/game_list_page.dart';
import 'services/game_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Armazenamento local (usado para persistir favoritos e o tema).
  await GetStorage.init();

  // Injeção de dependências com GetX.
  Get.put(GameService(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  Get.put(FavoriteController(), permanent: true);
  Get.put(GameController(), permanent: true);

  runApp(const GameHubApp());
}

class GameHubApp extends StatelessWidget {
  const GameHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      title: 'Game Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeController.themeMode,
      home: const GameListPage(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import '../utils/constants.dart';

/// BottomSheet com os filtros de plataforma, categoria e a ordenação.
/// Ao aplicar, o controller faz uma nova requisição GET /games.
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final GameController controller = Get.find<GameController>();

  late String _platform = controller.selectedPlatform.value;
  late String _category = controller.selectedCategory.value;
  late String _sort = controller.selectedSort.value;

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Filtros e ordenação',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            _section(context, 'Plataforma', Icons.devices_other),
            _chips(GameFilters.platforms, _platform,
                (value) => setState(() => _platform = value)),
            _section(context, 'Categoria', Icons.category_outlined),
            _chips(GameFilters.categories, _category,
                (value) => setState(() => _category = value)),
            _section(context, 'Ordenação', Icons.sort),
            _chips(GameFilters.sorts, _sort,
                (value) => setState(() => _sort = value)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                _close();
                controller.applyFilters(
                  platform: _platform,
                  category: _category,
                  sort: _sort,
                );
              },
              icon: const Icon(Icons.check),
              label: const Text('Aplicar filtros'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                _close();
                controller.clearFilters();
              },
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Limpar filtros'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(title, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }

  Widget _chips(
    List<FilterOption> options,
    String selected,
    ValueChanged<String> onSelected,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options
          .map(
            (option) => ChoiceChip(
              label: Text(option.label),
              selected: option.value == selected,
              onSelected: (_) => onSelected(option.value),
            ),
          )
          .toList(),
    );
  }
}

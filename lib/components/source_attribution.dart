import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/link_utils.dart';

/// Identifica a fonte dos dados com link ativo para FreeToGame.com.
class SourceAttribution extends StatelessWidget {
  const SourceAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Dados fornecidos por ', style: theme.textTheme.bodySmall),
            InkWell(
              onTap: () => openLink(AppLinks.freeToGame),
              child: Text(
                'FreeToGame.com',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kanban_project/l10n/app_localizations.dart';

import 'kanban_app_bar.dart';

class DynamicAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DynamicAppBar({
    required this.selectedIndex,
    super.key,
  });

  final int selectedIndex;

  @override
  Size get preferredSize => selectedIndex == 0
      ? const KanbanAppBar().preferredSize
      : const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    if (selectedIndex == 0) {
      return const KanbanAppBar();
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Text(
        l10n.profileAccountTitle,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

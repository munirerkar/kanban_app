import 'package:flutter/material.dart';

class KanbanBottomBar extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback onTasksPressed;
  final VoidCallback onProfilePressed;

  const KanbanBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onTasksPressed,
    required this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color selectedColor = theme.colorScheme.onPrimary;
    final Color unselectedColor = theme.colorScheme.onPrimary.withValues(alpha: 0.75);

    return BottomAppBar(
      color: theme.colorScheme.primary,
      surfaceTintColor: theme.colorScheme.onSurface,
      elevation: 8.0,
      shape: const CircularNotchedRectangle(),
      height: 60,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.home_outlined,
                color: selectedIndex == 0 ? selectedColor : unselectedColor,
                size: 30,
              ),
              onPressed: onTasksPressed,
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                Icons.person_outline,
                color: selectedIndex == 1 ? selectedColor : unselectedColor,
                size: 30,
              ),
              onPressed: onProfilePressed,
            ),
          ],
        ),
      ),
    );
  }
}

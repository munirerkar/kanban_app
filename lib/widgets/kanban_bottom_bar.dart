import 'package:flutter/material.dart';

class KanbanBottomBar extends StatelessWidget {
  const KanbanBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              icon: Icon(Icons.home_outlined, color: theme.colorScheme.onPrimary, size: 32),
              onPressed: () {
              },
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
              },
              child: Text(
                'Go to Word Ninja',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
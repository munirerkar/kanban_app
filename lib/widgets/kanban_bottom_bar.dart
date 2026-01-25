import 'package:flutter/material.dart';

class KanbanBottomBar extends StatelessWidget {
  const KanbanBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).primaryColor,
      surfaceTintColor: Colors.white,
      elevation: 8.0,
      shape: const CircularNotchedRectangle(),
      height: 60,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home_outlined, color: Colors.white, size: 32),
              onPressed: () {
              },
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
              },
              child: const Text(
                'Go to Word Ninja',
                style: TextStyle(
                  color: Colors.white,
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
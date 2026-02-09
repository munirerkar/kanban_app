import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

class KanbanBottomBar extends StatelessWidget {
  final VoidCallback onHomePressed;

  const KanbanBottomBar({super.key, required this.onHomePressed});

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://buymeacoffee.com/munirerkar');
    if (!await launchUrl(url)) {
      // TODO: Handle the error
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
              onPressed: onHomePressed, // Use the passed callback
            ),
            const Spacer(),
            TextButton(
              onPressed: _launchURL,
              child: Text(
                l10n.buyMeACoffee,
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

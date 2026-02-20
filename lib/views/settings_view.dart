import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/settings_view_model.dart';
import '../l10n/app_localizations.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = context.watch<SettingsViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildSectionHeader(context, l10n.settingsAppearance),
                _buildThemeSelector(context, settingsViewModel, l10n),
                const Divider(),
                _buildSectionHeader(context, l10n.settingsLanguage),
                _buildLanguageSelector(context, settingsViewModel, l10n),
                const Divider(),
                _buildSectionHeader(context, l10n.settingsAbout),
                _buildVersionTile(l10n),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(l10n.settingsLicenses),
                  onTap: () => showLicensePage(context: context),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: ListTile(
              leading: const Icon(Icons.coffee_outlined),
              title: Text(l10n.buyMeACoffee),
              onTap: () => _openBuyMeACoffee(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionTile(AppLocalizations l10n) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        String version = 'Loading...';
        if (snapshot.hasData) {
          version = '${snapshot.data!.version}+${snapshot.data!.buildNumber}';
        }
        return ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.settingsVersion),
          subtitle: Text(version),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, SettingsViewModel viewModel, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.brightness_6_outlined),
      title: Text(l10n.settingsTheme),
      trailing: DropdownButton<ThemeMode>(
        value: viewModel.themeMode,
        underline: const SizedBox.shrink(),
        items: [
          DropdownMenuItem(
            value: ThemeMode.system,
            child: Text(l10n.settingsThemeSystem),
          ),
          DropdownMenuItem(
            value: ThemeMode.light,
            child: Text(l10n.settingsThemeLight),
          ),
          DropdownMenuItem(
            value: ThemeMode.dark,
            child: Text(l10n.settingsThemeDark),
          ),
        ],
        onChanged: (mode) {
          if (mode != null) {
            viewModel.setThemeMode(mode);
          }
        },
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, SettingsViewModel viewModel, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.language_outlined),
      title: Text(l10n.settingsLanguage),
      trailing: DropdownButton<Locale>(
        value: viewModel.locale,
        underline: const SizedBox.shrink(),
        items: [
          DropdownMenuItem(
            value: const Locale('en'),
            child: Text(l10n.settingsLanguageEnglish),
          ),
          DropdownMenuItem(
            value: const Locale('tr'),
            child: Text(l10n.settingsLanguageTurkish),
          ),
        ],
        onChanged: (locale) {
          if (locale != null) {
            viewModel.setLocale(locale);
          }
        },
      ),
    );
  }
  Future<void> _openBuyMeACoffee(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri.parse('https://buymeacoffee.com/munirerkar');

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      if (!opened) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authNetworkErrorFallback)),
      );
    }
  }
}

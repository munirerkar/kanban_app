import 'package:flutter/material.dart';
import 'package:kanban_project/viewmodels/settings_view_model.dart';
import 'package:kanban_project/viewmodels/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:kanban_project/views/app_view.dart';
import 'package:kanban_project/viewmodels/task_view_model.dart';
import 'package:kanban_project/app/theme.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, child) {
          return MaterialApp(
            title: 'Kanban',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsViewModel.themeMode, // Listen to theme changes
            locale: settingsViewModel.locale, // Listen to locale changes
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppView(),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:kanban_project/viewmodels/auth_view_model.dart';
import 'package:kanban_project/viewmodels/settings_view_model.dart';
import 'package:kanban_project/viewmodels/workspace_view_model.dart';
import 'package:provider/provider.dart';
import 'package:kanban_project/viewmodels/task_view_model.dart';
import 'package:kanban_project/views/app_view.dart';
import 'package:kanban_project/views/login_view.dart';
import 'package:kanban_project/app/theme.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authViewModel = AuthViewModel();
  await authViewModel.checkLoginStatus();

  runApp(MyApp(authViewModel: authViewModel));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.authViewModel, super.key});

  final AuthViewModel authViewModel;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>.value(value: authViewModel),
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => WorkspaceViewModel()),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, child) {
          return MaterialApp(
            title: 'Kanban',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsViewModel.themeMode,
            locale: settingsViewModel.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              if (settingsViewModel.locale != null) {
                return settingsViewModel.locale;
              }

              if (deviceLocale != null) {
                for (final supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode ==
                      deviceLocale.languageCode) {
                    return supportedLocale;
                  }
                }
              }

              return const Locale('en');
            },
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.isCheckingAuth) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primary,
            body: const SizedBox.shrink(),
          );
        }

        if (authViewModel.isAuthenticated) {
          return const AppView();
        }

        return const LoginView();
      },
    );
  }
}

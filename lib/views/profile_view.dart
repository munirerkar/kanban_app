import 'package:flutter/material.dart';
import 'package:kanban_project/l10n/app_localizations.dart';
import 'package:kanban_project/viewmodels/auth_view_model.dart';
import 'package:kanban_project/views/login_view.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authViewModel = context.watch<AuthViewModel>();

    final user = authViewModel.currentUser;
    final String displayName = user?.name.trim().isNotEmpty == true
        ? user!.name
        : l10n.profileUnknownName;
    final String displayEmail = user?.email?.trim().isNotEmpty == true
        ? user!.email!
        : l10n.profileUnknownEmail;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        children: [
          Align(
            child: CircleAvatar(
              radius: 44,
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            displayName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            displayEmail,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: authViewModel.isLoading
                  ? null
                  : () async {
                      try {
                        await context.read<AuthViewModel>().logout();
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginView()),
                          (route) => false,
                        );
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.authUnexpectedLogoutError),
                          ),
                        );
                      }
                    },
              icon: authViewModel.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              label: Text(l10n.profileLogoutButton),
            ),
          ),
        ],
      ),
    );
  }
}

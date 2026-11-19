import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_state.dart';
import '../../core/sync/sync_status.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(sessionControllerProvider);
    final api = ref.watch(apiClientProvider);
    final sync = ref.watch(syncControllerProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'User: ${user?.displayName ?? user?.username ?? 'Unknown'}',
                  ),
                  if (user != null) Text('Username: ${user.username}'),
                  if (user != null) Text('Role: ${user.role}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Server',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(api.baseUrl ?? 'Not configured'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Offline sync',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Status: ${sync.state.name}'),
                  Text('Pending changes: ${sync.pendingChanges}'),
                  Text('Pending conflicts: ${sync.pendingConflicts}'),
                  if (sync.message != null) Text(sync.message!),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: sync.state == SyncState.syncing
                        ? null
                        : () => ref
                              .read(syncControllerProvider.notifier)
                              .syncNow(),
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync now'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              await ref.read(sessionControllerProvider.notifier).logout();
              if (context.mounted) Navigator.of(context).pop();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(sessionControllerProvider.notifier).clearServer();
              if (context.mounted) Navigator.of(context).pop();
            },
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Change server'),
          ),
        ],
      ),
    );
  }
}

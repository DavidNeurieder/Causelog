import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/auth_state.dart';
import '../../core/errors/app_exception.dart';

final projectsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final json = await api.getJson('/api/v1/projects');
  final items = (json['items'] as List?) ?? const [];
  return items.whereType<Map<String, dynamic>>().toList();
});

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(sessionControllerProvider);
    final projects = ref.watch(projectsProvider);
    final userName = auth is AuthAuthenticated ? auth.user.displayName : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(projectsProvider),
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'logout') {
                ref.read(sessionControllerProvider.notifier).logout();
              } else if (v == 'server') {
                ref.read(sessionControllerProvider.notifier).clearServer();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'logout', child: Text('Sign out')),
              PopupMenuItem(value: 'server', child: Text('Change server')),
            ],
          ),
        ],
      ),
      body: projects.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Welcome${userName.isNotEmpty ? ', $userName' : ''}'),
                  const SizedBox(height: 8),
                  const Text('No projects yet.'),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final p = items[i];
              return Card(
                child: ListTile(
                  title: Text(p['title'] as String? ?? '(untitled)'),
                  subtitle: Text((p['summary'] as String?)?.trim().isNotEmpty == true
                      ? p['summary'] as String
                      : 'Status: ${p['status'] ?? 'active'}'),
                  trailing: Chip(label: Text(p['status'] as String? ?? 'active')),
                  onTap: () {
                    // M3/M4: navigate to project detail
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Project "${p['title']}" — detail view coming in M3/M4')),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e is AppException ? e.message : 'Failed to load projects'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(projectsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

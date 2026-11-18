import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/errors/app_exception.dart';

final projectMembersProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, projectId) async {
  final api = ref.watch(apiClientProvider);
  final json = await api.getJson('/api/v1/projects/$projectId/members');
  final items = (json['items'] as List?) ?? const [];
  return items.whereType<Map<String, dynamic>>().toList();
});

class ProjectMembersScreen extends ConsumerWidget {
  final String projectId;
  const ProjectMembersScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(projectMembersProvider(projectId));
    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: async.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No members found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final m = items[i];
              final user = (m['user'] as Map?)?.cast<String, dynamic>() ?? const {};
              final name = (user['display_name'] as String?)?.trim().isNotEmpty == true
                  ? user['display_name'] as String
                  : (user['username'] as String? ?? 'Unknown');
              final username = user['username'] as String? ?? '';
              final role = m['role'] as String? ?? 'member';
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(name),
                  subtitle: Text(username.isNotEmpty ? '@$username' : ''),
                  trailing: Chip(label: Text(role)),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(e is AppException ? e.message : 'Failed to load members'),
          ),
        ),
      ),
    );
  }
}

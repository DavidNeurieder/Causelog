import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/api/api_client.dart';
import '../../core/errors/app_exception.dart';

final decisionsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, projectId) async {
      final api = ref.watch(apiClientProvider);
      final json = await api.getJson('/api/v1/projects/$projectId/decisions');
      final items = (json['items'] as List?) ?? const [];
      return items.whereType<Map<String, dynamic>>().toList();
    });

class DecisionsScreen extends ConsumerWidget {
  final String projectId;
  const DecisionsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisions = ref.watch(decisionsProvider(projectId));
    return Scaffold(
      appBar: AppBar(title: const Text('Decisions')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createDecision(context, ref),
        child: const Icon(Icons.add),
      ),
      body: decisions.when(
        data: (items) {
          if (items.isEmpty)
            return const Center(child: Text('No decisions yet.'));
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(decisionsProvider(projectId));
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final d = items[i];
                return Card(
                  child: ListTile(
                    title: Text(d['title'] as String? ?? '(untitled)'),
                    subtitle: Text(d['status'] as String? ?? 'open'),
                    onTap: () =>
                        context.go('/projects/$projectId/decisions/${d['id']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(context, ref, d['id'] as String),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            e is AppException ? e.message : 'Failed to load decisions',
          ),
        ),
      ),
    );
  }

  Future<void> _createDecision(BuildContext context, WidgetRef ref) async {
    final title = TextEditingController();
    final contextCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New decision'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contextCtrl,
              decoration: const InputDecoration(labelText: 'Context'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (ok != true || title.text.trim().isEmpty) return;
    try {
      final api = ref.read(apiClientProvider);
      await api.postJson(
        '/api/v1/projects/$projectId/decisions',
        idempotencyKey: ApiClient.newIdempotencyKey('create-decision'),
        data: {'title': title.text.trim(), 'context': contextCtrl.text.trim()},
      );
      ref.invalidate(decisionsProvider(projectId));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is AppException ? e.message : 'Failed to create decision',
            ),
          ),
        );
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, String id) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.deleteJson('/api/v1/decisions/$id', data: {});
      ref.invalidate(decisionsProvider(projectId));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is AppException ? e.message : 'Failed to delete decision',
            ),
          ),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/errors/app_exception.dart';

final experimentsProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, projectId) async {
  final api = ref.watch(apiClientProvider);
  final json = await api.getJson('/api/v1/projects/$projectId/experiments');
  final items = (json['items'] as List?) ?? const [];
  return items.whereType<Map<String, dynamic>>().toList();
});

class ExperimentsScreen extends ConsumerWidget {
  final String projectId;
  const ExperimentsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experiments = ref.watch(experimentsProvider(projectId));
    return Scaffold(
      appBar: AppBar(title: const Text('Experiments')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(context, ref),
        child: const Icon(Icons.add),
      ),
      body: experiments.when(
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('No experiments yet.'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final e = items[i];
              return Card(
                child: ListTile(
                  title: Text(e['title'] as String? ?? '(untitled)'),
                  subtitle: Text(e['status'] as String? ?? 'planned'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(context, ref, e['id'] as String),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e is AppException ? e.message : 'Failed to load experiments')),
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final title = TextEditingController();
    final hypothesis = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New experiment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            TextField(controller: hypothesis, decoration: const InputDecoration(labelText: 'Hypothesis'), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create')),
        ],
      ),
    );
    if (ok != true || title.text.trim().isEmpty) return;
    try {
      final api = ref.read(apiClientProvider);
      await api.postJson('/api/v1/projects/$projectId/experiments', data: {
        'title': title.text.trim(),
        'hypothesis': hypothesis.text.trim(),
      });
      ref.invalidate(experimentsProvider(projectId));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is AppException ? e.message : 'Failed to create experiment')));
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, String id) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.deleteJson('/api/v1/experiments/$id', data: {});
      ref.invalidate(experimentsProvider(projectId));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is AppException ? e.message : 'Failed to delete experiment')));
      }
    }
  }
}

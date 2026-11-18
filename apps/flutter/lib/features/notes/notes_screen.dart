import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/api/api_client.dart';
import '../../core/errors/app_exception.dart';

final notesProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, projectId) async {
  final api = ref.watch(apiClientProvider);
  final json = await api.getJson('/api/v1/projects/$projectId/notes');
  final items = (json['items'] as List?) ?? const [];
  return items.whereType<Map<String, dynamic>>().toList();
});

class NotesScreen extends ConsumerWidget {
  final String projectId;
  const NotesScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider(projectId));
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(context, ref),
        child: const Icon(Icons.add),
      ),
      body: notes.when(
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('No notes yet.'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final n = items[i];
              return Card(
                child: ListTile(
                  title: Text(n['title'] as String? ?? '(untitled)'),
                  subtitle: Text(
                    (n['body'] as String? ?? '').trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => context.go('/projects/$projectId/notes/${n['id']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(context, ref, n['id'] as String),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e is AppException ? e.message : 'Failed to load notes')),
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final title = TextEditingController();
    final body = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            TextField(controller: body, decoration: const InputDecoration(labelText: 'Body (Markdown)'), maxLines: 4),
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
      await api.postJson('/api/v1/projects/$projectId/notes', idempotencyKey: ApiClient.newIdempotencyKey('create-note'), data: {
        'title': title.text.trim(),
        'body': body.text.trim(),
      });
      ref.invalidate(notesProvider(projectId));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is AppException ? e.message : 'Failed to create note')));
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, String id) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.deleteJson('/api/v1/notes/$id', data: {});
      ref.invalidate(notesProvider(projectId));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is AppException ? e.message : 'Failed to delete note')));
      }
    }
  }
}

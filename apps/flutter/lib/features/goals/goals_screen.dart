import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/errors/app_exception.dart';

final goalsProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, projectId) async {
  final api = ref.watch(apiClientProvider);
  final json = await api.getJson('/api/v1/projects/$projectId/goals');
  final items = (json['items'] as List?) ?? const [];
  return items.whereType<Map<String, dynamic>>().toList();
});

class GoalsScreen extends ConsumerWidget {
  final String projectId;
  const GoalsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider(projectId));
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createGoal(context, ref),
        child: const Icon(Icons.add),
      ),
      body: goals.when(
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('No goals yet.'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final g = items[i];
              return Card(
                child: ListTile(
                  title: Text(g['title'] as String? ?? '(untitled)'),
                  subtitle: Text(g['status'] as String? ?? 'open'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteGoal(context, ref, g['id'] as String),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e is AppException ? e.message : 'Failed to load goals')),
      ),
    );
  }

  Future<void> _createGoal(BuildContext context, WidgetRef ref) async {
    final title = TextEditingController();
    final body = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            TextField(controller: body, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
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
      await api.postJson('/api/v1/projects/$projectId/goals', data: {
        'title': title.text.trim(),
        'body': body.text.trim(),
      });
      ref.invalidate(goalsProvider(projectId));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is AppException ? e.message : 'Failed to create goal')),
        );
      }
    }
  }

  Future<void> _deleteGoal(BuildContext context, WidgetRef ref, String goalId) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.deleteJson('/api/v1/goals/$goalId', data: {});
      ref.invalidate(goalsProvider(projectId));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is AppException ? e.message : 'Failed to delete goal')),
        );
      }
    }
  }
}

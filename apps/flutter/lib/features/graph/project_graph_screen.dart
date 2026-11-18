import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/errors/app_exception.dart';

final graphProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, projectId) async {
  final api = ref.watch(apiClientProvider);
  return api.getJson('/api/v1/projects/$projectId/graph');
});

class ProjectGraphScreen extends ConsumerWidget {
  final String projectId;
  const ProjectGraphScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(graphProvider(projectId));
    return Scaffold(
      appBar: AppBar(title: const Text('Graph')),
      body: async.when(
        data: (data) {
          final nodes = (data['nodes'] as List?) ?? const [];
          final edges = (data['edges'] as List?) ?? const [];
          if (nodes.isEmpty) return const Center(child: Text('No graph data yet.'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Nodes (${nodes.length})', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final n in nodes.whereType<Map>())
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(n['title'] as String? ?? n['id'] as String? ?? ''),
                    subtitle: Text(n['entity_type'] as String? ?? ''),
                  ),
                ),
              const SizedBox(height: 16),
              Text('Edges (${edges.length})', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final e in edges.whereType<Map>())
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(e['kind'] as String? ?? 'edge'),
                    subtitle: Text('${e['from_type']}:${e['from_id']} → ${e['to_type']}:${e['to_id']}'),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e is AppException ? e.message : '$e')),
      ),
    );
  }
}

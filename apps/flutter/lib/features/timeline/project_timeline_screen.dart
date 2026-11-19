import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/errors/app_exception.dart';

final timelineProvider = FutureProvider.autoDispose
    .family<List<dynamic>, String>((ref, projectId) async {
      final api = ref.watch(apiClientProvider);
      final json = await api.getJson('/api/v1/projects/$projectId/timeline');
      return (json['items'] as List?) ?? const [];
    });

class ProjectTimelineScreen extends ConsumerWidget {
  final String projectId;
  const ProjectTimelineScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(timelineProvider(projectId));
    return Scaffold(
      appBar: AppBar(title: const Text('Timeline')),
      body: async.when(
        data: (items) {
          if (items.isEmpty)
            return const Center(child: Text('No timeline events yet.'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final e = items[i] as Map<String, dynamic>;
              final title =
                  e['title'] as String? ??
                  e['note'] as String? ??
                  e['kind'] as String? ??
                  'Event';
              final description =
                  e['description'] as String? ??
                  e['experiment_title'] as String? ??
                  '';
              return Card(
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(
                    '${e['kind'] ?? ''}${description.isNotEmpty ? ' • $description' : ''}',
                  ),
                  trailing: Text(
                    '${e['at_ms'] ?? ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(e is AppException ? e.message : '$e')),
      ),
    );
  }
}

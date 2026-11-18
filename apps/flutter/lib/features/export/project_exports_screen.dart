import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/errors/app_exception.dart';

final exportsProvider = FutureProvider.autoDispose.family<List<dynamic>, String>((ref, projectId) async {
  final api = ref.watch(apiClientProvider);
  final json = await api.getJson('/api/v1/projects/$projectId/exports');
  return (json['items'] as List?) ?? const [];
});

class ProjectExportsScreen extends ConsumerWidget {
  final String projectId;
  const ProjectExportsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(exportsProvider(projectId));
    final baseUrl = ref.watch(apiClientProvider).baseUrl ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Exports')),
      body: async.when(
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('No export formats available.'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final e = items[i] as Map<String, dynamic>;
              final urlPath = e['url'] as String? ?? '';
              final fullUrl = urlPath.startsWith('http') ? urlPath : '$baseUrl$urlPath';
              return Card(
                child: ListTile(
                  title: Text((e['format'] as String? ?? 'export').toUpperCase()),
                  subtitle: Text('${e['description'] ?? ''}\n$fullUrl'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy URL',
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: fullUrl));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export URL copied')));
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e is AppException ? e.message : '$e')),
      ),
    );
  }
}

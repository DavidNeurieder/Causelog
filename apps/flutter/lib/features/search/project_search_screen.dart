import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/errors/app_exception.dart';

class ProjectSearchScreen extends ConsumerStatefulWidget {
  final String projectId;
  const ProjectSearchScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectSearchScreen> createState() =>
      _ProjectSearchScreenState();
}

class _ProjectSearchScreenState extends ConsumerState<ProjectSearchScreen> {
  final _controller = TextEditingController();
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _future = _run(q);
    });
  }

  Future<List<Map<String, dynamic>>> _run(String q) async {
    final api = ref.read(apiClientProvider);
    final json = await api.getJson(
      '/api/v1/search',
      query: {'q': q, 'project_id': widget.projectId},
    );
    final items = (json['items'] as List?) ?? const [];
    return items.whereType<Map<String, dynamic>>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Search in project',
                      hintText: 'Enter query',
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _search, child: const Text('Search')),
              ],
            ),
          ),
          Expanded(
            child: _future == null
                ? const Center(child: Text('Enter a query to search.'))
                : FutureBuilder<List<Map<String, dynamic>>>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        final e = snap.error;
                        return Center(
                          child: Text(e is AppException ? e.message : '$e'),
                        );
                      }
                      final items = snap.data ?? const [];
                      if (items.isEmpty)
                        return const Center(child: Text('No results.'));
                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          for (final entry in _grouped(items).entries) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 4),
                              child: Text(
                                entry.key.toUpperCase(),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            for (final r in entry.value)
                              Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(
                                    r['title'] as String? ?? '(untitled)',
                                  ),
                                  subtitle: Text(
                                    r['snippet'] as String? ?? '',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    final type = r['entity_type'] as String?;
                                    final id = r['entity_id'] as String?;
                                    if (type == null || id == null) return;
                                    switch (type) {
                                      case 'goal':
                                        context.go(
                                          '/projects/${widget.projectId}/goals/$id',
                                        );
                                      case 'decision':
                                        context.go(
                                          '/projects/${widget.projectId}/decisions/$id',
                                        );
                                      case 'experiment':
                                        context.go(
                                          '/projects/${widget.projectId}/experiments/$id',
                                        );
                                      case 'note':
                                        context.go(
                                          '/projects/${widget.projectId}/notes/$id',
                                        );
                                    }
                                  },
                                ),
                              ),
                          ],
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

Map<String, List<Map<String, dynamic>>> _grouped(
  List<Map<String, dynamic>> items,
) {
  final grouped = <String, List<Map<String, dynamic>>>{};
  for (final r in items) {
    final type = r['entity_type'] as String? ?? 'other';
    grouped.putIfAbsent(type, () => []).add(r);
  }
  return grouped;
}

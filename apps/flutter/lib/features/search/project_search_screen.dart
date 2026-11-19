import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final r = items[i];
                          return Card(
                            child: ListTile(
                              title: Text(
                                r['title'] as String? ?? '(untitled)',
                              ),
                              subtitle: Text(
                                '${r['entity_type'] ?? ''} • ${r['snippet'] ?? ''}',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

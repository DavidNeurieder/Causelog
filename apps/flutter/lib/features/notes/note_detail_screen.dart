import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/errors/app_exception.dart';

final noteDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  final api = ref.watch(apiClientProvider);
  return api.getJson('/api/v1/notes/$id');
});

final noteRevisionsProvider = FutureProvider.autoDispose.family<List<dynamic>, String>((ref, id) async {
  final api = ref.watch(apiClientProvider);
  final json = await api.getJson('/api/v1/notes/$id/revisions');
  return (json['items'] as List?) ?? const [];
});

class NoteDetailScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String noteId;
  const NoteDetailScreen({super.key, required this.projectId, required this.noteId});

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _saving = false;
  TextEditingController? _title;
  TextEditingController? _body;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _title?.dispose();
    _body?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noteAsync = ref.watch(noteDetailProvider(widget.noteId));
    return noteAsync.when(
      data: (note) {
        _title ??= TextEditingController(text: note['title'] as String? ?? '');
        _body ??= TextEditingController(text: note['body'] as String? ?? '');
        return Scaffold(
          appBar: AppBar(
            title: const Text('Note'),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saving ? null : () => _save(note),
              ),
            ],
            bottom: TabBar(controller: _tabs, tabs: const [Tab(text: 'Edit'), Tab(text: 'Preview'), Tab(text: 'History')]),
          ),
          body: TabBarView(
            controller: _tabs,
            children: [
              _editTab(),
              Markdown(data: _body?.text ?? ''),
              _historyTab(),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(), body: Center(child: Text(e is AppException ? e.message : '$e'))),
    );
  }

  Widget _editTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
        const SizedBox(height: 12),
        TextField(controller: _body, decoration: const InputDecoration(labelText: 'Body (Markdown)'), maxLines: 16),
      ],
    );
  }

  Widget _historyTab() {
    final revs = ref.watch(noteRevisionsProvider(widget.noteId));
    return revs.when(
      data: (items) {
        if (items.isEmpty) return const Center(child: Text('No revisions yet.'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final r = items[i] as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Text('Revision ${i + 1}'),
                subtitle: Text('Created: ${r['created_at_ms'] ?? ''}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(r['snapshot'] as String? ?? ''),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e is AppException ? e.message : '$e')),
    );
  }

  Future<void> _save(Map<String, dynamic> note) async {
    setState(() => _saving = true);
    try {
      final api = ref.read(apiClientProvider);
      await api.patchJson('/api/v1/notes/${widget.noteId}', data: {
        'title': _title?.text.trim() ?? note['title'],
        'body': _body?.text ?? note['body'],
      });
      ref.invalidate(noteDetailProvider(widget.noteId));
      ref.invalidate(noteRevisionsProvider(widget.noteId));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is AppException ? e.message : '$e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

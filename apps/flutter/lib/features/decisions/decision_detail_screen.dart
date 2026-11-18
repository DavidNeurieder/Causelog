import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/api/api_client.dart';
import '../../core/errors/app_exception.dart';

final decisionDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  final api = ref.watch(apiClientProvider);
  return api.getJson('/api/v1/decisions/$id');
});

final decisionRevisionsProvider = FutureProvider.autoDispose.family<List<dynamic>, String>((ref, id) async {
  final api = ref.watch(apiClientProvider);
  final json = await api.getJson('/api/v1/decisions/$id/revisions');
  return (json['items'] as List?) ?? const [];
});

class DecisionDetailScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String decisionId;
  const DecisionDetailScreen({super.key, required this.projectId, required this.decisionId});

  @override
  ConsumerState<DecisionDetailScreen> createState() => _DecisionDetailScreenState();
}

class _DecisionDetailScreenState extends ConsumerState<DecisionDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _saving = false;
  TextEditingController? _title;
  TextEditingController? _contextCtrl;
  TextEditingController? _rationale;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _title?.dispose();
    _contextCtrl?.dispose();
    _rationale?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(decisionDetailProvider(widget.decisionId));
    return async.when(
      data: (d) {
        _title ??= TextEditingController(text: d['title'] as String? ?? '');
        _contextCtrl ??= TextEditingController(text: d['context'] as String? ?? '');
        _rationale ??= TextEditingController(text: d['rationale'] as String? ?? '');
        final options = (d['options'] as List?) ?? const [];
        final status = d['status'] as String? ?? 'open';
        return Scaffold(
          appBar: AppBar(
            title: const Text('Decision'),
            actions: [
              IconButton(icon: const Icon(Icons.save), onPressed: _saving ? null : () => _save(d)),
              PopupMenuButton<String>(
                onSelected: (v) => _resolve(v),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'decided', child: Text('Mark decided')),
                  PopupMenuItem(value: 'rejected', child: Text('Mark rejected')),
                ],
              ),
            ],
            bottom: TabBar(controller: _tabs, tabs: const [Tab(text: 'Details'), Tab(text: 'Options'), Tab(text: 'History')]),
          ),
          body: TabBarView(
            controller: _tabs,
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Chip(label: Text('Status: $status')),
                  const SizedBox(height: 12),
                  TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
                  const SizedBox(height: 12),
                  TextField(controller: _contextCtrl, decoration: const InputDecoration(labelText: 'Context'), maxLines: 5),
                  const SizedBox(height: 12),
                  TextField(controller: _rationale, decoration: const InputDecoration(labelText: 'Rationale'), maxLines: 5),
                ],
              ),
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: options.length,
                itemBuilder: (context, i) {
                  final o = options[i] as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(o['label'] as String? ?? o['id'] as String? ?? 'Option', style: Theme.of(context).textTheme.titleMedium),
                        if ((o['pros'] as String?)?.isNotEmpty == true) ...[const SizedBox(height: 4), Text('Pros: ${o['pros']}')],
                        if ((o['cons'] as String?)?.isNotEmpty == true) ...[const SizedBox(height: 4), Text('Cons: ${o['cons']}')],
                      ]),
                    ),
                  );
                },
              ),
              _historyTab(),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(), body: Center(child: Text(e is AppException ? e.message : '$e'))),
    );
  }

  Widget _historyTab() {
    final revs = ref.watch(decisionRevisionsProvider(widget.decisionId));
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
                children: [Padding(padding: const EdgeInsets.all(12), child: SelectableText(r['snapshot'] as String? ?? ''))],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e is AppException ? e.message : '$e')),
    );
  }

  Future<void> _save(Map<String, dynamic> d) async {
    setState(() => _saving = true);
    try {
      final api = ref.read(apiClientProvider);
      await api.patchJson('/api/v1/decisions/${widget.decisionId}', data: {
        'title': _title?.text.trim() ?? d['title'],
        'context': _contextCtrl?.text ?? d['context'],
        'options': d['options'] ?? [],
      });
      ref.invalidate(decisionDetailProvider(widget.decisionId));
      ref.invalidate(decisionRevisionsProvider(widget.decisionId));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is AppException ? e.message : '$e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _resolve(String status) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.postJson('/api/v1/decisions/${widget.decisionId}/resolve', idempotencyKey: ApiClient.newIdempotencyKey('resolve-decision'), data: {
        'status': status,
        'rationale': _rationale?.text.trim() ?? '',
      });
      ref.invalidate(decisionDetailProvider(widget.decisionId));
      ref.invalidate(decisionRevisionsProvider(widget.decisionId));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is AppException ? e.message : '$e')));
    }
  }
}

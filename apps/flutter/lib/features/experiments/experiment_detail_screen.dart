import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/api/api_client.dart';
import '../../core/errors/app_exception.dart';

final experimentDetailProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, id) async {
      final api = ref.watch(apiClientProvider);
      return api.getJson('/api/v1/experiments/$id');
    });

class ExperimentDetailScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String experimentId;
  const ExperimentDetailScreen({
    super.key,
    required this.projectId,
    required this.experimentId,
  });

  @override
  ConsumerState<ExperimentDetailScreen> createState() =>
      _ExperimentDetailScreenState();
}

class _ExperimentDetailScreenState
    extends ConsumerState<ExperimentDetailScreen> {
  bool _saving = false;
  TextEditingController? _title;
  TextEditingController? _hypothesis;
  TextEditingController? _result;
  TextEditingController? _lesson;

  @override
  void dispose() {
    _title?.dispose();
    _hypothesis?.dispose();
    _result?.dispose();
    _lesson?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(experimentDetailProvider(widget.experimentId));
    return async.when(
      data: (data) {
        final exp =
            (data['experiment'] as Map?)?.cast<String, dynamic>() ?? data;
        final events = (data['events'] as List?) ?? const [];
        _title ??= TextEditingController(text: exp['title'] as String? ?? '');
        _hypothesis ??= TextEditingController(
          text: exp['hypothesis'] as String? ?? '',
        );
        _result ??= TextEditingController(text: exp['result'] as String? ?? '');
        _lesson ??= TextEditingController(text: exp['lesson'] as String? ?? '');
        String status = exp['status'] as String? ?? 'planned';
        return Scaffold(
          appBar: AppBar(
            title: const Text('Experiment'),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saving ? null : () => _save(exp, status),
              ),
              IconButton(
                icon: const Icon(Icons.note_add),
                onPressed: () => _extractLesson(context),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addEvent(context),
            child: const Icon(Icons.add_comment),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue:
                    ['planned', 'ongoing', 'done', 'abandoned'].contains(status)
                    ? status
                    : 'planned',
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'planned', child: Text('Planned')),
                  DropdownMenuItem(value: 'ongoing', child: Text('Ongoing')),
                  DropdownMenuItem(value: 'done', child: Text('Done')),
                  DropdownMenuItem(
                    value: 'abandoned',
                    child: Text('Abandoned'),
                  ),
                ],
                onChanged: (v) {
                  status = v ?? status;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _hypothesis,
                decoration: const InputDecoration(labelText: 'Hypothesis'),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _result,
                decoration: const InputDecoration(labelText: 'Result'),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lesson,
                decoration: const InputDecoration(labelText: 'Lesson'),
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              Text('Events', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (events.isEmpty) const Text('No events yet.'),
              for (final e in events.whereType<Map>())
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(e['kind'] as String? ?? 'event'),
                    subtitle: Text(e['note'] as String? ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${e['at_ms'] ?? ''}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              _deleteEvent(context, e['id'] as String? ?? ''),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(e is AppException ? e.message : '$e')),
      ),
    );
  }

  Future<void> _save(Map<String, dynamic> exp, String status) async {
    setState(() => _saving = true);
    try {
      final api = ref.read(apiClientProvider);
      await api.patchJson(
        '/api/v1/experiments/${widget.experimentId}',
        data: {
          'title': _title?.text.trim() ?? exp['title'],
          'hypothesis': _hypothesis?.text ?? exp['hypothesis'],
          'status': status,
          'result': _result?.text ?? exp['result'],
          'lesson': _lesson?.text ?? exp['lesson'],
        },
      );
      ref.invalidate(experimentDetailProvider(widget.experimentId));
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is AppException ? e.message : '$e')),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteEvent(BuildContext context, String eventId) async {
    if (eventId.isEmpty) return;
    try {
      final api = ref.read(apiClientProvider);
      await api.deleteJson(
        '/api/v1/experiments/${widget.experimentId}/events/$eventId',
      );
      ref.invalidate(experimentDetailProvider(widget.experimentId));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Event deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is AppException ? e.message : '$e')),
        );
      }
    }
  }

  Future<void> _extractLesson(BuildContext context) async {
    try {
      final api = ref.read(apiClientProvider);
      final data = await api.postJson(
        '/api/v1/experiments/${widget.experimentId}/extract',
        data: {'title': _title?.text.trim(), 'body': _lesson?.text.trim()},
      );
      ref.invalidate(experimentDetailProvider(widget.experimentId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lesson extracted: ${data is Map ? data['id'] : ''}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is AppException ? e.message : '$e')),
        );
      }
    }
  }

  Future<void> _addEvent(BuildContext context) async {
    final note = TextEditingController();
    String kind = 'observation';
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: kind,
              decoration: const InputDecoration(labelText: 'Kind'),
              items: const [
                DropdownMenuItem(
                  value: 'observation',
                  child: Text('Observation'),
                ),
                DropdownMenuItem(
                  value: 'measurement',
                  child: Text('Measurement'),
                ),
                DropdownMenuItem(value: 'milestone', child: Text('Milestone')),
              ],
              onChanged: (v) => kind = v ?? kind,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: note,
              decoration: const InputDecoration(labelText: 'Note'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (ok != true || note.text.trim().isEmpty) return;
    try {
      final api = ref.read(apiClientProvider);
      await api.postJson(
        '/api/v1/experiments/${widget.experimentId}/events',
        idempotencyKey: ApiClient.newIdempotencyKey('create-event'),
        data: {'kind': kind, 'note': note.text.trim()},
      );
      ref.invalidate(experimentDetailProvider(widget.experimentId));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is AppException ? e.message : '$e')),
        );
      }
    }
  }
}

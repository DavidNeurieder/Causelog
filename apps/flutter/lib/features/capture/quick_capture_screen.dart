import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/api/api_client.dart';
import '../../core/errors/app_exception.dart';

class QuickCaptureScreen extends ConsumerStatefulWidget {
  final String projectId;
  const QuickCaptureScreen({super.key, required this.projectId});

  @override
  ConsumerState<QuickCaptureScreen> createState() => _QuickCaptureScreenState();
}

class _QuickCaptureScreenState extends ConsumerState<QuickCaptureScreen> {
  String _kind = 'note';
  String? _experimentId;
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _busy = false;
  String? _error;
  String? _idempotencyKey;
  List<Map<String, dynamic>> _experiments = const [];

  @override
  void initState() {
    super.initState();
    _loadExperiments();
  }

  Future<void> _loadExperiments() async {
    try {
      final api = ref.read(apiClientProvider);
      final json = await api.getJson(
        '/api/v1/projects/${widget.projectId}/experiments',
      );
      final items = (json['items'] as List?) ?? const [];
      if (mounted) {
        setState(
          () => _experiments = items.whereType<Map<String, dynamic>>().toList(),
        );
      }
    } catch (_) {
      // optional
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Title is required');
      return;
    }
    if (_kind == 'observation' &&
        (_experimentId == null || _experimentId!.isEmpty)) {
      setState(() => _error = 'Select an experiment for an observation');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      await api.postJson(
        '/api/v1/capture',
        idempotencyKey: (_idempotencyKey ??= ApiClient.newIdempotencyKey(
          'capture',
        )),
        data: {
          'project_id': widget.projectId,
          'kind': _kind,
          'title': title,
          'body': _body.text.trim(),
          'experiment_id': _kind == 'observation' ? _experimentId : null,
        },
      );
      if (mounted) {
        _idempotencyKey = null;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Captured')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick capture')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'note', label: Text('Note')),
              ButtonSegment(value: 'observation', label: Text('Observation')),
              ButtonSegment(
                value: 'decision_draft',
                label: Text('Decision draft'),
              ),
            ],
            selected: {_kind},
            onSelectionChanged: (s) => setState(() => _kind = s.first),
          ),
          const SizedBox(height: 16),
          if (_kind == 'observation')
            DropdownButtonFormField<String>(
              initialValue: _experimentId,
              decoration: const InputDecoration(labelText: 'Experiment'),
              items: _experiments
                  .map(
                    (e) => DropdownMenuItem(
                      value: e['id'] as String,
                      child: Text(e['title'] as String? ?? e['id'] as String),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _experimentId = v),
            ),
          if (_kind == 'observation') const SizedBox(height: 12),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title / Summary'),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _body,
            decoration: const InputDecoration(labelText: 'Details'),
            maxLines: 6,
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          FilledButton.icon(
            onPressed: _busy ? null : _submit,
            icon: _busy
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

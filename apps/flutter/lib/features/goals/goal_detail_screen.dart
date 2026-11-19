import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/errors/app_exception.dart';

final goalDetailProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, id) async {
      final api = ref.watch(apiClientProvider);
      return api.getJson('/api/v1/goals/$id');
    });

class GoalDetailScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String goalId;
  const GoalDetailScreen({
    super.key,
    required this.projectId,
    required this.goalId,
  });

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  bool _saving = false;
  TextEditingController? _title;
  TextEditingController? _body;
  String _status = 'open';
  bool _initialized = false;

  @override
  void dispose() {
    _title?.dispose();
    _body?.dispose();
    super.dispose();
  }

  void _init(Map<String, dynamic> goal) {
    if (_initialized) return;
    _title = TextEditingController(text: goal['title'] as String? ?? '');
    _body = TextEditingController(text: goal['body'] as String? ?? '');
    _status = goal['status'] as String? ?? 'open';
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final goalAsync = ref.watch(goalDetailProvider(widget.goalId));
    return goalAsync.when(
      data: (goal) {
        _init(goal);
        return _build(context, goal);
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(e is AppException ? e.message : '$e')),
      ),
    );
  }

  Widget _build(BuildContext context, Map<String, dynamic> goal) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saving
                ? null
                : () async {
                    setState(() => _saving = true);
                    try {
                      final api = ref.read(apiClientProvider);
                      await api.patchJson(
                        '/api/v1/goals/${widget.goalId}',
                        data: {
                          'title': _title?.text.trim() ?? '',
                          'body': _body?.text.trim() ?? '',
                          'status': _status,
                        },
                      );
                      ref.invalidate(goalDetailProvider(widget.goalId));
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Saved')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e is AppException ? e.message : '$e'),
                          ),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _saving = false);
                    }
                  },
          ),
        ],
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
                ['open', 'ongoing', 'done', 'dropped'].contains(_status)
                ? _status
                : 'open',
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'open', child: Text('Open')),
              DropdownMenuItem(value: 'ongoing', child: Text('Ongoing')),
              DropdownMenuItem(value: 'done', child: Text('Done')),
              DropdownMenuItem(value: 'dropped', child: Text('Dropped')),
            ],
            onChanged: (v) => setState(() => _status = v ?? _status),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _body,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 8,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/errors/app_exception.dart';

final goalDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  final api = ref.watch(apiClientProvider);
  return api.getJson('/api/v1/goals/$id');
});

class GoalDetailScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String goalId;
  const GoalDetailScreen({super.key, required this.projectId, required this.goalId});

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final goalAsync = ref.watch(goalDetailProvider(widget.goalId));
    return goalAsync.when(
      data: (goal) => _build(context, goal),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(), body: Center(child: Text(e is AppException ? e.message : '$e'))),
    );
  }

  Widget _build(BuildContext context, Map<String, dynamic> goal) {
    final title = TextEditingController(text: goal['title'] as String? ?? '');
    final body = TextEditingController(text: goal['body'] as String? ?? '');
    String status = goal['status'] as String? ?? 'open';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saving ? null : () async {
              setState(() => _saving = true);
              try {
                final api = ref.read(apiClientProvider);
                await api.patchJson('/api/v1/goals/${widget.goalId}', data: {
                  'title': title.text.trim(),
                  'body': body.text.trim(),
                  'status': status,
                });
                ref.invalidate(goalDetailProvider(widget.goalId));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is AppException ? e.message : '$e')));
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
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: ['open', 'ongoing', 'done', 'dropped'].contains(status) ? status : 'open',
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'open', child: Text('Open')),
              DropdownMenuItem(value: 'ongoing', child: Text('Ongoing')),
              DropdownMenuItem(value: 'done', child: Text('Done')),
              DropdownMenuItem(value: 'dropped', child: Text('Dropped')),
            ],
            onChanged: (v) => status = v ?? status,
          ),
          const SizedBox(height: 12),
          TextField(controller: body, decoration: const InputDecoration(labelText: 'Description'), maxLines: 8),
        ],
      ),
    );
  }
}

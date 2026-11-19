import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/api/api_client.dart';
import '../../core/errors/app_exception.dart';

final projectMembersProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, projectId) async {
      final api = ref.watch(apiClientProvider);
      final json = await api.getJson('/api/v1/projects/$projectId/members');
      final items = (json['items'] as List?) ?? const [];
      return items.whereType<Map<String, dynamic>>().toList();
    });

class ProjectMembersScreen extends ConsumerStatefulWidget {
  final String projectId;
  const ProjectMembersScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectMembersScreen> createState() =>
      _ProjectMembersScreenState();
}

class _ProjectMembersScreenState extends ConsumerState<ProjectMembersScreen> {
  bool _busy = false;

  Future<void> _addMember() async {
    final userId = TextEditingController();
    String role = 'member';
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: userId,
                decoration: const InputDecoration(labelText: 'User ID'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'member', child: Text('Member')),
                  DropdownMenuItem(value: 'owner', child: Text('Owner')),
                ],
                onChanged: (v) => setDialogState(() => role = v ?? role),
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
      ),
    );
    if (ok != true || userId.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      final api = ref.read(apiClientProvider);
      await api.postJson(
        '/api/v1/projects/${widget.projectId}/members',
        data: {'user_id': userId.text.trim(), 'role': role},
      );
      ref.invalidate(projectMembersProvider(widget.projectId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is AppException ? e.message : 'Failed to add member',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _removeMember(String userId) async {
    setState(() => _busy = true);
    try {
      final api = ref.read(apiClientProvider);
      await api.deleteJson(
        '/api/v1/projects/${widget.projectId}/members/$userId',
      );
      ref.invalidate(projectMembersProvider(widget.projectId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is AppException ? e.message : 'Failed to remove member',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(projectMembersProvider(widget.projectId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(
            onPressed: _busy ? null : _addMember,
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
      body: async.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No members found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final m = items[i];
              final user =
                  (m['user'] as Map?)?.cast<String, dynamic>() ?? const {};
              final userId = user['id'] as String? ?? '';
              final name =
                  (user['display_name'] as String?)?.trim().isNotEmpty == true
                  ? user['display_name'] as String
                  : (user['username'] as String? ?? 'Unknown');
              final username = user['username'] as String? ?? '';
              final role = m['role'] as String? ?? 'member';
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(name),
                  subtitle: Text(username.isNotEmpty ? '@$username' : ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(label: Text(role)),
                      IconButton(
                        onPressed: _busy ? null : () => _removeMember(userId),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              e is AppException ? e.message : 'Failed to load members',
            ),
          ),
        ),
      ),
    );
  }
}

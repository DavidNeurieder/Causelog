import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/errors/app_exception.dart';

final projectProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, id) async {
      final api = ref.watch(apiClientProvider);
      return api.getJson('/api/v1/projects/$id');
    });

final projectStatsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, id) async {
      final api = ref.watch(apiClientProvider);
      return api.getJson('/api/v1/projects/$id/stats');
    });

class ProjectDetailScreen extends ConsumerWidget {
  final String id;
  const ProjectDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectProvider(id));
    final statsAsync = ref.watch(projectStatsProvider(id));

    return projectAsync.when(
      data: (project) => Scaffold(
        appBar: AppBar(
          title: Text(project['title'] as String? ?? 'Project'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(projectProvider(id));
                ref.invalidate(projectStatsProvider(id));
              },
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') _editProject(context, ref, project);
                if (v == 'delete') _deleteProject(context, ref);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit project')),
                PopupMenuItem(value: 'delete', child: Text('Delete project')),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.go('/projects/$id/capture'),
          icon: const Icon(Icons.bolt),
          label: const Text('Quick capture'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if ((project['summary'] as String?)?.trim().isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(project['summary'] as String),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Status: ${project['status'] ?? 'active'}')),
              ],
            ),
            const SizedBox(height: 16),
            Text('Overview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            statsAsync.when(
              data: (s) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatCard(label: 'Goals', value: '${s['goals_total'] ?? 0}'),
                  _StatCard(
                    label: 'Decisions',
                    value: '${s['decisions_total'] ?? 0}',
                  ),
                  _StatCard(
                    label: 'Experiments',
                    value: '${s['experiments_total'] ?? 0}',
                  ),
                  _StatCard(label: 'Notes', value: '${s['notes_total'] ?? 0}'),
                ],
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Text(
                'Stats unavailable: ${e is AppException ? e.message : e}',
              ),
            ),
            const SizedBox(height: 24),
            Text('Sections', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _SectionTile(
              title: 'Goals',
              subtitle: 'Track objectives',
              onTap: () => context.go('/projects/$id/goals'),
            ),
            _SectionTile(
              title: 'Decisions',
              subtitle: 'Options, rationale, revisions',
              onTap: () => context.go('/projects/$id/decisions'),
            ),
            _SectionTile(
              title: 'Experiments',
              subtitle: 'Hypotheses and observations',
              onTap: () => context.go('/projects/$id/experiments'),
            ),
            _SectionTile(
              title: 'Notes',
              subtitle: 'Lessons and knowledge',
              onTap: () => context.go('/projects/$id/notes'),
            ),
            _SectionTile(
              title: 'Timeline',
              subtitle: 'Chronological history',
              onTap: () => context.go('/projects/$id/timeline'),
            ),
            _SectionTile(
              title: 'Graph',
              subtitle: 'Relationships',
              onTap: () => context.go('/projects/$id/graph'),
            ),
            _SectionTile(
              title: 'Search',
              subtitle: 'Find knowledge',
              onTap: () => context.go('/projects/$id/search'),
            ),
            _SectionTile(
              title: 'Members',
              subtitle: 'Project access',
              onTap: () => context.go('/projects/$id/members'),
            ),
            _SectionTile(
              title: 'Exports',
              subtitle: 'Download project data',
              onTap: () => context.go('/projects/$id/exports'),
            ),
          ],
        ),
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) {
        if (e is AppException && e.statusCode == 401) {
          Future.microtask(
            () => ref.read(sessionControllerProvider.notifier).logout(),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Project')),
          body: Center(
            child: Text(
              e is AppException ? e.message : 'Failed to load project',
            ),
          ),
        );
      },
    );
  }

  Future<void> _editProject(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> project,
  ) async {
    final title = TextEditingController(
      text: project['title'] as String? ?? '',
    );
    final summary = TextEditingController(
      text: project['summary'] as String? ?? '',
    );
    String status = project['status'] as String? ?? 'active';
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: summary,
              decoration: const InputDecoration(labelText: 'Summary'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: ['active', 'paused', 'archived'].contains(status)
                  ? status
                  : 'active',
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'paused', child: Text('Paused')),
                DropdownMenuItem(value: 'archived', child: Text('Archived')),
              ],
              onChanged: (v) => status = v ?? status,
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final api = ref.read(apiClientProvider);
      await api.patchJson(
        '/api/v1/projects/$id',
        data: {
          'title': title.text.trim(),
          'summary': summary.text.trim(),
          'status': status,
        },
      );
      ref.invalidate(projectProvider(id));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is AppException ? e.message : '$e')),
        );
      }
    }
  }

  Future<void> _deleteProject(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete project?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final api = ref.read(apiClientProvider);
      await api.deleteJson('/api/v1/projects/$id', data: {});
      if (context.mounted) context.go('/projects');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is AppException ? e.message : '$e')),
        );
      }
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SectionTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

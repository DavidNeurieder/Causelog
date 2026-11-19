import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/errors/app_exception.dart';

final graphProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, projectId) async {
      final api = ref.watch(apiClientProvider);
      return api.getJson('/api/v1/projects/$projectId/graph');
    });

class ProjectGraphScreen extends ConsumerWidget {
  final String projectId;
  const ProjectGraphScreen({super.key, required this.projectId});

  void _openNode(BuildContext context, Map n) {
    final type = n['entity_type'] as String?;
    final id = n['id'] as String?;
    if (type == null || id == null) return;
    switch (type) {
      case 'goal':
        context.go('/projects/$projectId/goals/$id');
      case 'decision':
        context.go('/projects/$projectId/decisions/$id');
      case 'experiment':
        context.go('/projects/$projectId/experiments/$id');
      case 'note':
        context.go('/projects/$projectId/notes/$id');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(graphProvider(projectId));
    return Scaffold(
      appBar: AppBar(title: const Text('Graph')),
      body: async.when(
        data: (data) {
          final nodes =
              (data['nodes'] as List?)?.whereType<Map>().toList() ?? const [];
          final edges =
              (data['edges'] as List?)?.whereType<Map>().toList() ?? const [];
          if (nodes.isEmpty) {
            return const Center(child: Text('No graph data yet.'));
          }
          return Column(
            children: [
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3,
                  child: SizedBox(
                    width: 900,
                    height: 700,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _GraphEdgePainter(
                              nodes: nodes,
                              edges: edges,
                            ),
                          ),
                        ),
                        for (int i = 0; i < nodes.length; i++)
                          _nodeWidget(context, nodes[i], i, nodes.length),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 180,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Edges (${edges.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    for (final e in edges)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            '${e['kind'] ?? 'edge'} (${e['source'] ?? ''})',
                          ),
                          subtitle: Text(
                            '${e['from_type'] ?? ''}: ${e['from_id'] ?? ''}\n→ ${e['to_type'] ?? ''}: ${e['to_id'] ?? ''}',
                          ),
                          isThreeLine: true,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(e is AppException ? e.message : '$e')),
      ),
    );
  }

  Widget _nodeWidget(BuildContext context, Map node, int index, int total) {
    const radius = 280.0;
    const center = Offset(450, 350);
    final angle = (2 * math.pi * index) / (total == 0 ? 1 : total);
    final x = center.dx + radius * math.cos(angle) - 40;
    final y = center.dy + radius * math.sin(angle) - 20;
    final color = _colorForType(node['entity_type'] as String?);
    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: () => _openNode(context, node),
        child: Container(
          width: 80,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
          ),
          child: Text(
            node['title'] as String? ?? node['id'] as String? ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Color _colorForType(String? type) {
    switch (type) {
      case 'goal':
        return Colors.blue;
      case 'decision':
        return Colors.deepPurple;
      case 'experiment':
        return Colors.teal;
      case 'note':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class _GraphEdgePainter extends CustomPainter {
  final List<Map> nodes;
  final List<Map> edges;
  _GraphEdgePainter({required this.nodes, required this.edges});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1.5;
    const center = Offset(450, 350);
    const radius = 280.0;
    Offset positionOf(Map node, int index) {
      final angle = (2 * math.pi * index) / (nodes.isEmpty ? 1 : nodes.length);
      return Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
    }

    for (final edge in edges) {
      final fromIndex = nodes.indexWhere((n) => n['id'] == edge['from_id']);
      final toIndex = nodes.indexWhere((n) => n['id'] == edge['to_id']);
      if (fromIndex < 0 || toIndex < 0) continue;
      final from = positionOf(nodes[fromIndex], fromIndex);
      final to = positionOf(nodes[toIndex], toIndex);
      canvas.drawLine(from, to, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GraphEdgePainter oldDelegate) => true;
}

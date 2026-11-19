import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../core/errors/app_exception.dart';

final exportsProvider = FutureProvider.autoDispose
    .family<List<dynamic>, String>((ref, projectId) async {
      final api = ref.watch(apiClientProvider);
      final json = await api.getJson('/api/v1/projects/$projectId/exports');
      return (json['items'] as List?) ?? const [];
    });

class ProjectExportsScreen extends ConsumerWidget {
  final String projectId;
  const ProjectExportsScreen({super.key, required this.projectId});

  Future<void> _downloadExport(
    BuildContext context,
    WidgetRef ref,
    String fullUrl,
    String format,
    String? contentType,
  ) async {
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.dio.get<List<int>>(
        fullUrl,
        options: dio.Options(responseType: dio.ResponseType.bytes),
      );
      final bytes = res.data;
      if (bytes == null) throw Exception('Empty response');
      final ext = _extensionFor(format, contentType);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/causelog-$format.$ext');
      await file.writeAsBytes(bytes, flush: true);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path, mimeType: contentType)]),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is AppException ? e.message : '$e')),
        );
      }
    }
  }

  String _extensionFor(String format, String? contentType) {
    if (contentType != null && contentType.contains('zip')) return 'zip';
    switch (format.toLowerCase()) {
      case 'json':
        return 'json';
      case 'md':
        return 'zip';
      case 'html':
        return 'zip';
      case 'zip':
        return 'zip';
      case 'odp':
        return 'odp';
      default:
        return 'bin';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(exportsProvider(projectId));
    final baseUrl = ref.watch(apiClientProvider).baseUrl ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Exports')),
      body: async.when(
        data: (items) {
          if (items.isEmpty)
            return const Center(child: Text('No export formats available.'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final e = items[i] as Map<String, dynamic>;
              final urlPath = e['url'] as String? ?? '';
              final fullUrl = urlPath.startsWith('http')
                  ? urlPath
                  : '$baseUrl$urlPath';
              return Card(
                child: ListTile(
                  title: Text(
                    (e['format'] as String? ?? 'export').toUpperCase(),
                  ),
                  subtitle: Text('${e['description'] ?? ''}\n$fullUrl'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy URL',
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: fullUrl));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Export URL copied'),
                              ),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.download),
                        tooltip: 'Download/share',
                        onPressed: () => _downloadExport(
                          context,
                          ref,
                          fullUrl,
                          e['format'] as String? ?? 'export',
                          e['content_type'] as String?,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(e is AppException ? e.message : '$e')),
      ),
    );
  }
}

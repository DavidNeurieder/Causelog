import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers.dart';
import '../core/sync/sync_status.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    String location = '';
    try {
      location = GoRouterState.of(context).uri.path;
    } catch (_) {
      location = '';
    }
    if (location.startsWith('/settings')) return 1;
    return 0;
  }

  void _onSelect(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/projects');
      case 1:
        context.go('/settings');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;
    final selectedIndex = _selectedIndex(context);
    final sync = ref.watch(syncControllerProvider);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) => _onSelect(context, i),
              labelType: NavigationRailLabelType.all,
              trailing: _SyncRailIndicator(sync: sync),
              trailingAtBottom: true,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.folder_outlined),
                  selectedIcon: Icon(Icons.folder),
                  label: Text('Projects'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          if (sync.pendingChanges > 0 || sync.pendingConflicts > 0)
            MaterialBanner(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              content: Text(
                'Sync: ${sync.pendingChanges} pending, ${sync.pendingConflicts} conflicts',
              ),
              actions: const [SizedBox.shrink()],
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => _onSelect(context, i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _SyncRailIndicator extends StatelessWidget {
  final SyncStatus sync;
  const _SyncRailIndicator({required this.sync});

  @override
  Widget build(BuildContext context) {
    Widget? child;
    if (sync.state == SyncState.syncing) {
      child = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (sync.pendingConflicts > 0 || sync.state == SyncState.error) {
      child = Icon(
        Icons.sync_problem,
        color: Theme.of(context).colorScheme.error,
      );
    } else if (sync.pendingChanges > 0) {
      child = Badge(
        label: Text('${sync.pendingChanges}'),
        child: const Icon(Icons.sync),
      );
    }
    if (child == null) return const SizedBox.shrink();
    return IconButton(
      tooltip: 'Sync status',
      onPressed: () => context.go('/settings'),
      icon: child,
    );
  }
}

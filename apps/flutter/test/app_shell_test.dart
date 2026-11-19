import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:causelog_app/app/providers.dart';
import 'package:causelog_app/app/shell.dart';
import 'package:causelog_app/core/api/api_client.dart';
import 'package:causelog_app/core/storage/local_database.dart';
import 'package:causelog_app/core/sync/sync_service.dart';
import 'package:causelog_app/core/sync/sync_status.dart';

class _TestSyncController extends SyncController {
  _TestSyncController(super.api, super.database, SyncStatus status) {
    state = status;
  }
}

void main() {
  testWidgets('AppShell shows a navigation rail on wide screens', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(1200, 800)),
            child: AppShell(child: SizedBox()),
          ),
        ),
      ),
    );
    expect(find.byType(NavigationRail), findsOneWidget);
  });

  testWidgets('AppShell shows bottom navigation on narrow screens', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(400, 800)),
            child: AppShell(child: SizedBox()),
          ),
        ),
      ),
    );
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('AppShell shows sync banner on narrow screens when pending', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncControllerProvider.overrideWith(
            (ref) => _TestSyncController(
              ApiClient(),
              LocalDatabase(),
              const SyncStatus.idle(pendingChanges: 2, pendingConflicts: 1),
            ),
          ),
        ],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(400, 800)),
            child: AppShell(child: SizedBox()),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(MaterialBanner), findsOneWidget);
    expect(find.text('Sync: 2 pending, 1 conflicts'), findsOneWidget);
  });
}

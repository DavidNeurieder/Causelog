import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:causelog_app/app/shell.dart';

void main() {
  testWidgets('AppShell shows a navigation rail on wide screens', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: const AppShell(child: SizedBox()),
        ),
      ),
    );
    expect(find.byType(NavigationRail), findsOneWidget);
  });

  testWidgets('AppShell shows bottom navigation on narrow screens', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: const AppShell(child: SizedBox()),
        ),
      ),
    );
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}

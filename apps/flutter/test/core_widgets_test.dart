import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:causelog_app/core/widgets/empty_state.dart';
import 'package:causelog_app/core/widgets/error_view.dart';

void main() {
  testWidgets('EmptyState renders message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: EmptyState(message: 'Nothing here yet')),
    );
    expect(find.text('Nothing here yet'), findsOneWidget);
  });

  testWidgets('ErrorView renders error text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ErrorView(error: 'Boom')),
    );
    expect(find.text('Boom'), findsOneWidget);
  });
}

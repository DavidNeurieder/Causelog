import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:causelog_app/app/providers.dart';
import 'package:causelog_app/core/api/api_client.dart';
import 'package:causelog_app/core/auth/auth_state.dart';
import 'package:causelog_app/core/auth/session_controller.dart';
import 'package:causelog_app/core/errors/app_exception.dart';
import 'package:causelog_app/features/authentication/login_screen.dart';

class _FakeApiClient extends ApiClient {
  @override
  String? get baseUrl => 'http://localhost:3000';
}

class _FailingSessionController extends SessionController {
  _FailingSessionController(super.api);

  @override
  Future<void> login(String username, String password) async {
    throw const AppException('Invalid credentials', code: 'invalid_credentials');
  }
}

class _NoopSessionController extends SessionController {
  _NoopSessionController(super.api);
}

void main() {
  testWidgets('login screen shows fields and server URL', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(_FakeApiClient()),
          sessionControllerProvider.overrideWith(
            (ref) => _NoopSessionController(_FakeApiClient()),
          ),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('Sign in'), findsWidgets);
    expect(find.widgetWithText(TextField, 'Username'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
    expect(find.text('http://localhost:3000'), findsOneWidget);
  });

  testWidgets('login screen displays error on failed sign in', (tester) async {
    final api = _FakeApiClient();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          sessionControllerProvider.overrideWith(
            (ref) => _FailingSessionController(api),
          ),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Username'),
      'alice',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'wrong',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Invalid credentials'), findsOneWidget);
  });
}

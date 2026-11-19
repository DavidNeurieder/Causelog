import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for AuthApi
void main() {
  final instance = Openapi().getAuthApi();

  group(AuthApi, () {
    // Current session, user, and CSRF token
    //
    //Future<SessionResponse> getSession() async
    test('test getSession', () async {
      // TODO
    });

    // Log in and create a session
    //
    //Future<SessionResponse> login(LoginRequest loginRequest, { String idempotencyKey }) async
    test('test login', () async {
      // TODO
    });

    // Log out and clear the session
    //
    //Future logout({ String idempotencyKey, CsrfBody csrfBody }) async
    test('test logout', () async {
      // TODO
    });

    // Register a new user (pending admin approval)
    //
    //Future<Register201Response> register(RegisterRequest registerRequest, { String idempotencyKey }) async
    test('test register', () async {
      // TODO
    });

    // Create the first admin user and session (idempotent semantics as today)
    //
    //Future<SessionResponse> setup(SetupRequest setupRequest, { String idempotencyKey }) async
    test('test setup', () async {
      // TODO
    });

  });
}

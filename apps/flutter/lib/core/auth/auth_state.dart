class ApiUser {
  final String id;
  final String username;
  final String displayName;
  final String role;
  final bool approved;
  final int createdAtMs;

  const ApiUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    required this.approved,
    required this.createdAtMs,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) => ApiUser(
    id: json['id'] as String,
    username: json['username'] as String? ?? '',
    displayName:
        json['display_name'] as String? ?? json['username'] as String? ?? '',
    role: json['role'] as String? ?? 'user',
    approved: json['approved'] as bool? ?? false,
    createdAtMs: (json['created_at_ms'] as num?)?.toInt() ?? 0,
  );
}

sealed class AuthState {
  const AuthState();
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class AuthNeedsServer extends AuthState {
  const AuthNeedsServer();
}

class AuthNeedsSetup extends AuthState {
  const AuthNeedsSetup();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthUnapproved extends AuthState {
  final ApiUser user;
  const AuthUnapproved(this.user);
}

class AuthAuthenticated extends AuthState {
  final ApiUser user;
  final String csrfToken;
  const AuthAuthenticated({required this.user, required this.csrfToken});
}

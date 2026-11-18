class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  const AppException(this.message, {this.code, this.statusCode});

  factory AppException.unauthenticated([String message = 'Unauthenticated']) =>
      AppException(message, code: 'unauthenticated', statusCode: 401);

  factory AppException.forbidden([String message = 'Forbidden']) =>
      AppException(message, code: 'forbidden', statusCode: 403);

  factory AppException.network([String message = 'Network error']) =>
      AppException(message, code: 'network');

  @override
  String toString() => 'AppException($code, $statusCode): $message';
}

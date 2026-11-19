import 'dart:io';
import 'dart:math';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

import '../errors/app_exception.dart';

class ApiClient {
  Dio? _dio;
  PersistCookieJar? _cookieJar;
  String? _baseUrl;
  String? csrfToken;

  Dio get dio {
    final d = _dio;
    if (d == null) {
      throw const AppException('Server not configured', code: 'no_server');
    }
    return d;
  }

  bool get isConfigured => _dio != null;
  String? get baseUrl => _baseUrl;

  Future<void> configure(String baseUrl) async {
    _baseUrl = baseUrl;
    final dir = await getApplicationSupportDirectory();
    final safe = baseUrl.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final cookiePath = '${dir.path}/cookies/$safe';
    await Directory(cookiePath).create(recursive: true);
    _cookieJar = PersistCookieJar(storage: FileStorage(cookiePath));

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {'Accept': 'application/json'},
        // Let us inspect 4xx responses ourselves.
        validateStatus: (s) => s != null && s < 500,
      ),
    );
    dio.interceptors.add(CookieManager(_cookieJar!));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final method = options.method.toUpperCase();
          if (method != 'GET' && method != 'HEAD' && csrfToken != null) {
            options.headers['X-CSRF-Token'] = csrfToken;
            if (options.data is Map) {
              (options.data as Map).putIfAbsent('csrf_token', () => csrfToken);
            }
          }
          handler.next(options);
        },
      ),
    );
    _dio = dio;
  }

  Never throwFor(Response response) {
    final data = response.data;
    String message = 'Request failed';
    String? code;
    if (data is Map) {
      message = (data['error'] as String?) ?? message;
      code = data['code'] as String?;
    }
    final status = response.statusCode;
    if (status == 401) {
      throw AppException(
        message,
        code: code ?? 'unauthenticated',
        statusCode: 401,
      );
    }
    if (status == 403) {
      throw AppException(message, code: code ?? 'forbidden', statusCode: 403);
    }
    if (status == 404) {
      throw AppException(message, code: code ?? 'not_found', statusCode: 404);
    }
    if (status == 409) {
      throw AppException(message, code: code ?? 'conflict', statusCode: 409);
    }
    throw AppException(message, code: code, statusCode: status);
  }

  static String newIdempotencyKey([String prefix = 'req']) {
    final rand = Random();
    final a = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final b = rand.nextInt(1 << 32).toRadixString(36);
    return '$prefix-$a-$b';
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final res = await dio.get(path, queryParameters: query);
      if (res.statusCode != null && res.statusCode! >= 400) throwFor(res);
      if (res.data is Map<String, dynamic>)
        return res.data as Map<String, dynamic>;
      return {'data': res.data};
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<dynamic> postJson(
    String path, {
    Object? data,
    String? idempotencyKey,
  }) async {
    try {
      final res = await dio.post(
        path,
        data: data ?? <String, dynamic>{},
        options: idempotencyKey == null
            ? null
            : Options(headers: {'Idempotency-Key': idempotencyKey}),
      );
      if (res.statusCode != null && res.statusCode! >= 400) throwFor(res);
      return res.data;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<dynamic> patchJson(
    String path, {
    Object? data,
    String? idempotencyKey,
  }) async {
    try {
      final res = await dio.patch(
        path,
        data: data ?? <String, dynamic>{},
        options: idempotencyKey == null
            ? null
            : Options(headers: {'Idempotency-Key': idempotencyKey}),
      );
      if (res.statusCode != null && res.statusCode! >= 400) throwFor(res);
      return res.data;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<void> deleteJson(
    String path, {
    Object? data,
    String? idempotencyKey,
  }) async {
    try {
      final res = await dio.delete(
        path,
        data: data,
        options: idempotencyKey == null
            ? null
            : Options(headers: {'Idempotency-Key': idempotencyKey}),
      );
      if (res.statusCode != null && res.statusCode! >= 400) throwFor(res);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  AppException _mapDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return AppException.network(e.message ?? 'Network error');
    }
    return AppException(e.message ?? 'Request failed', code: 'request_failed');
  }

  Future<void> clearSession() async {
    await _cookieJar?.deleteAll();
    csrfToken = null;
  }
}

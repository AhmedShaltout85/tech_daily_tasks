import 'package:dio/dio.dart';
import 'dart:developer';

class DioClient {
  static const String _baseUrl = 'http://localhost:9999/tasks-api/api';
  static final DioClient instance = DioClient._();
  late final Dio _dio;
  String? _token;

  DioClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        log('REQUEST: ${options.method} ${options.path}');
        log('DATA: ${options.data}');
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
          log('TOKEN ADDED: Bearer $_token');
        } else {
          log('NO TOKEN - Request may be unauthorized');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        log('RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (error, handler) {
        log('ERROR: ${error.response?.statusCode} ${error.requestOptions.path}');
        log('ERROR DATA: ${error.response?.data}');
        return handler.next(error);
      },
    ));
  }

  factory DioClient() => instance;

  Dio get dio => _dio;

  void setToken(String token) => _token = token;

  void clearToken() => _token = null;

  String? get token => _token;
}

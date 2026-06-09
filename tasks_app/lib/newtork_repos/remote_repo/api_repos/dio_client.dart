import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  // static const String _baseUrl = 'http://localhost:9999/tasks-api/api'; //LOCALHOST(LOCAL_SERVER)
  // static const String _baseUrl = 'http://172.18.0.101:9999/tasks-api/api'; //LOCALHOST(ONLINE_SERVER)
  static const String _baseUrl =
      'http://41.33.226.211:8099/tasks-api/api'; //PUBLIC_SERVER(PUBLIC_ONLINE_SERVER)
  static final DioClient instance = DioClient._();
  late final Dio _dio;
  String? _token;
  // [REFRESH_TOKEN] Stores the refresh token used to obtain new access tokens on 401
  String? _refreshToken;
  // [REFRESH_TOKEN] Flag to prevent concurrent refresh requests
  bool _isRefreshing = false;
  // [REFRESH_TOKEN] Queue of requests waiting for token refresh to complete
  final Queue<_PendingRequest> _pendingRequests = Queue();

  // [REFRESH_TOKEN] Callback invoked after successful token refresh — persists new tokens to cache
  Function(String newAccessToken, String newRefreshToken)? onTokensRefreshed;
  // [REFRESH_TOKEN] Callback invoked when refresh fails — triggers logout and redirect to login
  VoidCallback? onSessionExpired;

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
        // [2026-06-07] Skip adding Bearer token for auth endpoints to avoid sending expired token on refresh
        if (_token != null && !_isAuthEndpoint(options.path)) {
          options.headers['Authorization'] = 'Bearer $_token';
          log('TOKEN ADDED: Bearer $_token');
        } else {
          log('NO TOKEN or auth endpoint - Request may be unauthorized');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        log('RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      // [REFRESH_TOKEN] On 401 error, attempt automatic token refresh (skip auth endpoints to prevent loops)
      onError: (error, handler) {
        log('ERROR: ${error.response?.statusCode} ${error.requestOptions.path}');
        log('ERROR DATA: ${error.response?.data}');

        // [2026-06-07] Catch both 401 and 403 for token refresh (backend may return 403 for expired JWT)
        if ((error.response?.statusCode == 401 || error.response?.statusCode == 403) &&
            !_isAuthEndpoint(error.requestOptions.path)) {
          _handleTokenRefresh(error, handler);
          return;
        }

        handler.next(error);
      },
    ));
  }

  factory DioClient() => instance;

  Dio get dio => _dio;

  void setToken(String token) => _token = token;

  void clearToken() => _token = null;

  String? get token => _token;

  // [REFRESH_TOKEN] Setter for refresh token
  void setRefreshToken(String refreshToken) => _refreshToken = refreshToken;

  // [REFRESH_TOKEN] Clear refresh token (used on sign-out or session expiry)
  void clearRefreshToken() => _refreshToken = null;

  // [REFRESH_TOKEN] Getter for refresh token
  String? get refreshToken => _refreshToken;

  // [REFRESH_TOKEN] Returns true if the path is an auth endpoint (should not trigger refresh)
  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/signin') ||
        path.contains('/auth/refresh-token') ||
        path.contains('/auth/signup');
  }

  // [REFRESH_TOKEN] Core refresh logic: called when a 401 is received on a non-auth endpoint
  Future<void> _handleTokenRefresh(
      DioException error, ErrorInterceptorHandler handler) async {
    // [REFRESH_TOKEN] No refresh token available — session is truly expired
    if (_refreshToken == null) {
      log('No refresh token available, session expired');
      handler.next(error);
      return;
    }

    // [REFRESH_TOKEN] If refresh is already in progress, queue this request to retry later
    if (_isRefreshing) {
      log('Refresh already in progress, queuing request');
      final completer = Completer<Response>();
      _pendingRequests.add(_PendingRequest(
        requestOptions: error.requestOptions,
        completer: completer,
        handler: handler,
      ));
      return;
    }

    // [REFRESH_TOKEN] Start the refresh process — block other 401s from starting parallel refreshes
    _isRefreshing = true;
    log('Starting token refresh...');

    try {
      // [REFRESH_TOKEN] Call POST /auth/refresh-token without Authorization header
      final refreshResponse = await _dio.post(
        '/auth/refresh-token',
        data: {'refreshToken': _refreshToken},
        options: Options(
          headers: {'Authorization': null},
          contentType: 'application/json',
        ),
      );

      if (refreshResponse.statusCode == 200) {
        // [REFRESH_TOKEN] Extract new tokens from response
        final newAccessToken = refreshResponse.data['accessToken'] as String;
        final newRefreshToken = refreshResponse.data['refreshToken'] as String;

        // [REFRESH_TOKEN] Update in-memory tokens
        _token = newAccessToken;
        _refreshToken = newRefreshToken;

        // [REFRESH_TOKEN] Notify UserProvider to persist new tokens to SharedPreferences
        log('Token refresh successful');
        onTokensRefreshed?.call(newAccessToken, newRefreshToken);

        // [REFRESH_TOKEN] Retry the original failed request with the new access token
        final retryResponse = await _retryRequest(error.requestOptions);
        handler.resolve(retryResponse);
      } else {
        // [REFRESH_TOKEN] Refresh failed — treat as session expired
        log('Token refresh failed with status: ${refreshResponse.statusCode}');
        _handleSessionExpired(handler, error);
      }
    } on DioException catch (e) {
      log('Token refresh failed: ${e.response?.statusCode}');
      _handleSessionExpired(handler, error);
    } catch (e) {
      log('Token refresh unexpected error: $e');
      _handleSessionExpired(handler, error);
    } finally {
      _isRefreshing = false;
      // [REFRESH_TOKEN] Process any queued requests that were waiting for this refresh
      _processPendingRequests();
    }
  }

  // [REFRESH_TOKEN] Handles session expiry: clears tokens, notifies UI, fails all queued requests
  void _handleSessionExpired(
      ErrorInterceptorHandler handler, DioException originalError) {
    _token = null;
    _refreshToken = null;
    // [REFRESH_TOKEN] Trigger callback to clear UserProvider state and redirect to login
    onSessionExpired?.call();

    handler.next(originalError);

    // [REFRESH_TOKEN] Fail all queued requests that were waiting for refresh
    while (_pendingRequests.isNotEmpty) {
      final pending = _pendingRequests.removeFirst();
      pending.handler.next(originalError);
    }
  }

  // [REFRESH_TOKEN] Retries all queued requests with the new access token
  Future<void> _processPendingRequests() async {
    while (_pendingRequests.isNotEmpty) {
      final pending = _pendingRequests.removeFirst();
      try {
        final response = await _retryRequest(pending.requestOptions);
        pending.completer.complete(response);
        pending.handler.resolve(response);
      } on DioException catch (e) {
        pending.completer.completeError(e);
        pending.handler.next(e);
      }
    }
  }

  // [REFRESH_TOKEN] Retries a failed request with the current (refreshed) access token
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        if (_token != null) 'Authorization': 'Bearer $_token',
      },
    );
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}

// [REFRESH_TOKEN] Holds a pending request that is waiting for token refresh to complete
class _PendingRequest {
  final RequestOptions requestOptions;
  final Completer<Response> completer;
  final ErrorInterceptorHandler handler;

  _PendingRequest({
    required this.requestOptions,
    required this.completer,
    required this.handler,
  });
}

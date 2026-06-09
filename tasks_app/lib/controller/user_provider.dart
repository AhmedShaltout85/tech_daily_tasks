import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../models/user_model.dart';
import '../newtork_repos/remote_repo/api_repos/api_network_user_repos_impl.dart';
// [REFRESH_TOKEN] Import DioClient to access refresh token callbacks
import '../newtork_repos/remote_repo/api_repos/dio_client.dart';
import 'local_control/cache_helper.dart';

class UserProvider with ChangeNotifier {
  final ApiNetworkUserReposImpl _api = ApiNetworkUserReposImpl();

  UserModel? _currentUser;
  List<UserModel> _users = [];
  bool _isLoading = false;
  bool _isInitializing = true;
  bool _isUsersLoading = false;
  String? _error;
  String? _token;
  // [REFRESH_TOKEN] Stores the refresh token used to obtain new access tokens
  String? _refreshToken;

  UserProvider() {
    _init();
  }

  bool get isInitializing => _isInitializing;

  Future<void> _init() async {
    // [REFRESH_TOKEN] Register DioClient callbacks before loading cached tokens
    _setupDioCallbacks();
    await _loadTokenFromCache();
    _isInitializing = false;
    log('UserProvider init complete - user: ${_currentUser?.username}, role: ${_currentUser?.role}');
    notifyListeners();
  }

  // [REFRESH_TOKEN] Registers callbacks on DioClient to handle token refresh and session expiry
  void _setupDioCallbacks() {
    final dioClient = DioClient();
    // [REFRESH_TOKEN] Called by DioClient after successful refresh — updates local state and cache
    dioClient.onTokensRefreshed = (newAccessToken, newRefreshToken) {
      _token = newAccessToken;
      _refreshToken = newRefreshToken;
      _saveTokenToCache(newAccessToken);
      _saveRefreshTokenToCache(newRefreshToken);
      notifyListeners();
    };
    // [REFRESH_TOKEN] Called by DioClient when refresh fails — clears all auth state, forces re-login
    dioClient.onSessionExpired = () {
      _token = null;
      _refreshToken = null;
      _currentUser = null;
      _users = [];
      _clearTokenFromCache();
      notifyListeners();
    };
  }

  Future<void> _loadTokenFromCache() async {
    final savedToken = CacheHelper.getData(key: 'auth_token');
    log('Checking for cached token: ${savedToken != null ? "found" : "not found"}');
    if (savedToken != null) {
      _token = savedToken as String;
      _api.setToken(_token!);
      log('Token loaded from cache');

      // [REFRESH_TOKEN] Load persisted refresh token from SharedPreferences
      final savedRefreshToken = CacheHelper.getData(key: 'refresh_token');
      if (savedRefreshToken != null) {
        _refreshToken = savedRefreshToken as String;
        DioClient().setRefreshToken(_refreshToken!);
        log('Refresh token loaded from cache');
      }

      final savedUserData = CacheHelper.getData(key: 'current_user');
      if (savedUserData != null) {
        try {
          final userMap = jsonDecode(savedUserData as String);
          _currentUser = UserModel.fromJson(userMap);
          log('User data restored from cache: ${_currentUser?.displayName}, role: ${_currentUser?.role}');
        } catch (e) {
          log('Failed to parse cached user data: $e');
          _token = null;
          // [REFRESH_TOKEN] Clear refresh token on parse failure
          _refreshToken = null;
          _api.clearToken();
          DioClient().clearRefreshToken();
          await _clearTokenFromCache();
        }
      } else {
        _token = null;
        // [REFRESH_TOKEN] Clear refresh token when no user data found
        _refreshToken = null;
        _api.clearToken();
        DioClient().clearRefreshToken();
        await _clearTokenFromCache();
        log('No cached user data found, cleared token');
      }
    } else {
      log('No cached token found');
    }
  }

  Future<void> _saveTokenToCache(String token) async {
    await CacheHelper.saveData(key: 'auth_token', value: token);
  }

  // [REFRESH_TOKEN] Persists refresh token to SharedPreferences
  Future<void> _saveRefreshTokenToCache(String refreshToken) async {
    await CacheHelper.saveData(key: 'refresh_token', value: refreshToken);
  }

  Future<void> _saveUserToCache(UserModel user) async {
    await CacheHelper.saveData(
        key: 'current_user', value: jsonEncode(user.toJson()));
  }

  Future<void> _clearTokenFromCache() async {
    await CacheHelper.removeData(key: 'auth_token');
    // [REFRESH_TOKEN] Also clear refresh token from cache
    await CacheHelper.removeData(key: 'refresh_token');
    await CacheHelper.removeData(key: 'current_user');
  }

  UserModel? get currentUser => _currentUser;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  bool get isUsersLoading => _isUsersLoading;
  bool get isAnyLoading => _isLoading || _isUsersLoading;
  String? get error => _error;
  String? get token => _token;
  // [REFRESH_TOKEN] Exposes refresh token to callers (e.g., sign-out sends it to server)
  String? get refreshToken => _refreshToken;

  // [REFRESH_TOKEN] Clears all auth state including refresh token — used for local sign-out
  void clearUserData() async {
    _token = null;
    _refreshToken = null;
    _currentUser = null;
    _users = [];
    _error = null;
    _api.clearToken();
    DioClient().clearRefreshToken();
    await _clearTokenFromCache();
    notifyListeners();
  }

  // [REFRESH_TOKEN] Updates both access and refresh tokens — called by DioClient after successful refresh
  void updateTokens(String newAccessToken, String newRefreshToken) {
    _token = newAccessToken;
    _refreshToken = newRefreshToken;
    _api.setToken(newAccessToken);
    DioClient().setRefreshToken(newRefreshToken);
    _saveTokenToCache(newAccessToken);
    _saveRefreshTokenToCache(newRefreshToken);
    notifyListeners();
  }

  Future<void> signUp({
    required String displayName,
    required String username,
    required String password,
    required String role,
    required String department,
  }) async {
    _setLoading(true);
    notifyListeners();

    try {
      final response = await _api.signUp(
        displayName: displayName,
        username: username,
        password: password,
        role: role,
        department: department,
      );
      if (response['token'] != null) {
        _token = response['token'];
        _api.setToken(_token!);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    notifyListeners();

    try {
      final response = await _api.signIn(
        username: username,
        password: password,
      );
      log('SignIn response: $response');
      _token = response['token'];
      _api.setToken(_token!);
      await _saveTokenToCache(_token!);

      // [REFRESH_TOKEN] Extract and persist refresh token from sign-in response
      if (response['refreshToken'] != null) {
        _refreshToken = response['refreshToken'];
        DioClient().setRefreshToken(_refreshToken!);
        await _saveRefreshTokenToCache(_refreshToken!);
      }

      _currentUser = UserModel.fromJson(response);
      await _saveUserToCache(_currentUser!);
      log('Current user set: ${_currentUser?.displayName}, role: ${_currentUser?.role}, department: ${_currentUser?.department}');
      _error = null;
    } on DioException catch (e) {
      log('SignIn error: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        final data = e.response?.data;
        _error = data['error'] ?? 'Invalid username or password';
      } else {
        _error = e.message ?? 'Login failed';
      }
    } catch (e) {
      log('SignIn error: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // [REFRESH_TOKEN] Signs out: sends refresh token to server for revocation, clears all local state
  Future<void> signOut() async {
    try {
      // [REFRESH_TOKEN] Pass refresh token to API so server can revoke it
      await _api.signOut(refreshToken: _refreshToken);
      _api.clearToken();
      DioClient().clearRefreshToken();
    } catch (e) {
      // Ignore signout API error
    }
    _token = null;
    _refreshToken = null;
    _currentUser = null;
    _users = [];
    _error = null;
    await _clearTokenFromCache();
    notifyListeners();
  }

  Future<void> fetchAllUsers() async {
    _setUsersLoading(true);
    notifyListeners();

    try {
      _users = await _api.getAllUsers();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setUsersLoading(false);
      notifyListeners();
    }
  }

  Future<void> fetchUserById(int id) async {
    _setUsersLoading(true);
    notifyListeners();

    try {
      _currentUser = await _api.getUserById(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setUsersLoading(false);
      notifyListeners();
    }
  }

  Future<void> fetchUsersByDepartment(String department) async {
    _setUsersLoading(true);
    notifyListeners();

    try {
      _users = await _api.getUsersByDepartment(department);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setUsersLoading(false);
      notifyListeners();
    }
  }

  Future<void> fetchUsersByRole(String role) async {
    _setUsersLoading(true);
    notifyListeners();

    try {
      _users = await _api.getUsersByRole(role);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setUsersLoading(false);
      notifyListeners();
    }
  }

  Future<void> fetchEnabledUsersByRole(String role, bool enabled) async {
    log('fetchEnabledUsersByRole called - role: $role, enabled: $enabled');

    _isUsersLoading = true;
    notifyListeners();

    try {
      _users = await _api.getEnabledUsersByRole(role, enabled);
      log('Users fetched successfully: ${_users.length}');
      _error = null;
    } catch (e) {
      log('Error fetching users: $e');
      _error = e.toString();
    } finally {
      _isUsersLoading = false;
      notifyListeners();
    }
  }

  Future<void> setUserEnabled(int id, bool enabled) async {
    log('setUserEnabled called - id: $id, enabled: $enabled');

    _isLoading = true;
    notifyListeners();

    try {
      await _api.setUserEnabled(id, enabled);

      final index = _users.indexWhere((u) => u.id == id);
      log('Index found: $index');

      if (index != -1) {
        _users[index] = _users[index].copyWith(enabled: enabled);
      }

      if (_currentUser?.id == id) {
        _currentUser = _currentUser!.copyWith(enabled: enabled);
      }

      _error = null;
    } catch (e) {
      log('Error in setUserEnabled: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(int id) async {
    _setLoading(true);
    notifyListeners();

    try {
      await _api.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    notifyListeners();

    try {
      await _api.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> forgotPassword({
    required String username,
    required String newPassword,
  }) async {
    _setLoading(true);
    notifyListeners();

    try {
      await _api.forgotPassword(
        username: username,
        newPassword: newPassword,
      );
      _error = null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 400) {
        final data = e.response?.data;
        _error = data['error'] ?? data['message'] ?? 'User not found';
      } else {
        _error = e.message ?? 'Failed to reset password';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setUsersLoading(bool value) {
    _isUsersLoading = value;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../models/user_model.dart';
import '../newtork_repos/remote_repo/api_repos/api_network_user_repos_impl.dart';
import 'local_control/cache_helper.dart';

class UserProvider with ChangeNotifier {
  final ApiNetworkUserReposImpl _api = ApiNetworkUserReposImpl();

  UserModel? _currentUser;
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;
  String? _token;

  UserProvider() {
    _loadTokenFromCache();
  }

  void _loadTokenFromCache() async {
    final savedToken = CacheHelper.getData(key: 'auth_token');
    if (savedToken != null) {
      _token = savedToken as String;
      _api.setToken(_token!);
      log('Token loaded from cache, fetching user data...');

      // Fetch current user data when token is loaded
      try {
        final users = await _api.getAllUsers();
        if (users.isNotEmpty) {
          _currentUser = users.first;
          log('User data restored: ${_currentUser?.displayName}');
          notifyListeners();
        }
      } catch (e) {
        log('Failed to restore user data: $e');
      }
    }
  }

  Future<void> _saveTokenToCache(String token) async {
    await CacheHelper.saveData(key: 'auth_token', value: token);
  }

  Future<void> _clearTokenFromCache() async {
    await CacheHelper.removeData(key: 'auth_token');
  }

  UserModel? get currentUser => _currentUser;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;

  void clearUserData() async {
    _token = null;
    _currentUser = null;
    _users = [];
    _error = null;
    _api.clearToken();
    await _clearTokenFromCache();
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
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final response = await _api.signIn(
        username: username,
        password: password,
      );
      log('SignIn response: $response');
      _token = response['token'];
      _api.setToken(_token!);
      await _saveTokenToCache(_token!);
      _currentUser = UserModel.fromJson(response);
      log('Current user set: ${_currentUser?.displayName}, role: ${_currentUser?.role}, department: ${_currentUser?.department}');
      _error = null;
      notifyListeners();
    } on DioException catch (e) {
      log('SignIn error: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        final data = e.response?.data;
        _error = data['error'] ?? 'Invalid username or password';
      } else {
        _error = e.message ?? 'Login failed';
      }
      notifyListeners();
    } catch (e) {
      log('SignIn error: $e');
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      await _api.signOut();
      _api.clearToken();
    } catch (e) {
      // Ignore signout API error
    }
    _token = null;
    _currentUser = null;
    _users = [];
    _error = null;
    notifyListeners();
  }

  Future<void> fetchAllUsers() async {
    _setLoading(true);
    try {
      _users = await _api.getAllUsers();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchUserById(int id) async {
    _setLoading(true);
    try {
      _currentUser = await _api.getUserById(id);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchUsersByDepartment(String department) async {
    _setLoading(true);
    try {
      _users = await _api.getUsersByDepartment(department);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchUsersByRole(String role) async {
    _setLoading(true);
    try {
      _users = await _api.getUsersByRole(role);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchEnabledUsersByRole(String role, bool enabled) async {
    log('fetchEnabledUsersByRole called - role: $role, enabled: $enabled, token: $_token');
    _setLoading(true);
    try {
      _users = await _api.getEnabledUsersByRole(role, enabled);
      log('Users fetched successfully: ${_users.length}');
      _error = null;
      notifyListeners();
    } catch (e) {
      log('Error fetching users: $e');
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setUserEnabled(int id, bool enabled) async {
    _setLoading(true);
    try {
      final updatedUser = await _api.setUserEnabled(id, enabled);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      if (_currentUser?.id == id) {
        _currentUser = updatedUser;
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteUser(int id) async {
    _setLoading(true);
    try {
      await _api.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      await _api.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> forgotPassword({
    required String username,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      await _api.forgotPassword(
        username: username,
        newPassword: newPassword,
      );
      _error = null;
      notifyListeners();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 400) {
        final data = e.response?.data;
        _error = data['error'] ?? data['message'] ?? 'User not found';
      } else {
        _error = e.message ?? 'Failed to reset password';
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

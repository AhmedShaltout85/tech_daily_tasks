import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../models/user_model.dart';
import '../newtork_repos/remote_repo/api_repos/api_network_user_repos_impl.dart';

class UserProvider with ChangeNotifier {
  final ApiNetworkUserReposImpl _api = ApiNetworkUserReposImpl();

  UserModel? _currentUser;
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;
  String? _token;

  UserModel? get currentUser => _currentUser;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;

  void clearUserData() {
    _token = null;
    _currentUser = null;
    _users = [];
    _error = null;
    _api.clearToken();
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
      _token = response['token'];
      _api.setToken(_token!);
      _currentUser = UserModel.fromJson(response);
      _error = null;
      notifyListeners();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final data = e.response?.data;
        _error = data['error'] ?? 'Invalid username or password';
      } else {
        _error = e.message ?? 'Login failed';
      }
      notifyListeners();
    } catch (e) {
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
    _setLoading(true);
    try {
      _users = await _api.getEnabledUsersByRole(role, enabled);
      _error = null;
      notifyListeners();
    } catch (e) {
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
      final index = _users.indexWhere((u) => u.id == id.toString());
      if (index != -1) {
        _users[index] = updatedUser;
      }
      if (_currentUser?.id == id.toString()) {
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
      _users.removeWhere((u) => u.id == id.toString());
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

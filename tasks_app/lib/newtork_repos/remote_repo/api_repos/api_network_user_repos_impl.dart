import 'dart:developer';

import '../../../models/user_model.dart';
import 'api_network_user_repos.dart';
import 'dio_client.dart';

class ApiNetworkUserReposImpl implements ApiNetworkUserRepos {
  static final ApiNetworkUserReposImpl instance = ApiNetworkUserReposImpl._();
  final DioClient _client = DioClient();

  ApiNetworkUserReposImpl._();

  factory ApiNetworkUserReposImpl() => instance;

  void setToken(String token) => _client.setToken(token);

  void clearToken() => _client.clearToken();

  @override
  Future<Map<String, dynamic>> signUp({
    required String displayName,
    required String username,
    required String password,
    required String role,
    required String department,
  }) async {
    final response = await _client.dio.post('/auth/signup', data: {
      'displayName': displayName,
      'username': username,
      'password': password,
      'role': role,
      'department': department,
    });
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> signIn({
    required String username,
    required String password,
  }) async {
    final response = await _client.dio.post('/auth/signin', data: {
      'username': username,
      'password': password,
    });
    if (response.data['token'] != null) {
      log("USER_TOKEN: ==>"+response.data['token']);
      log("USER_REFRESH_TOKEN: ==>"+response.data['refreshToken']);


      _client.setToken(response.data['token']);
    }
    // [REFRESH_TOKEN] Also extract and set the refresh token from sign-in response
    if (response.data['refreshToken'] != null) {
      _client.setRefreshToken(response.data['refreshToken']);
    }
    return response.data;
  }

  // [REFRESH_TOKEN] Sends refresh token to server for revocation, then clears local tokens
  @override
  Future<void> signOut({String? refreshToken}) async {
    await _client.dio.post('/auth/signout', data: {
      // [REFRESH_TOKEN] Include refresh token in request body so server can revoke it
      if (refreshToken != null) 'refreshToken': refreshToken,
    });
    _client.clearToken();
    _client.clearRefreshToken();
  }

  // [REFRESH_TOKEN] Calls POST /auth/refresh-token to exchange refresh token for new access token
  @override
  Future<Map<String, dynamic>> refreshToken(
      {required String refreshToken}) async {
    final response = await _client.dio.post('/auth/refresh-token', data: {
      'refreshToken': refreshToken,
    });
    return response.data;
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final response = await _client.dio.get('/users');
    return (response.data as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  @override
  Future<UserModel> getUserById(int id) async {
    final response = await _client.dio.get('/users/$id');
    return UserModel.fromJson(response.data);
  }

  @override
  Future<List<UserModel>> getUsersByDepartment(String department) async {
    final response = await _client.dio.get('/users/department/$department/all');
    return (response.data as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<UserModel>> getUsersByRole(String role) async {
    final response = await _client.dio.get('/users/role/$role');
    return (response.data as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<UserModel>> getEnabledUsersByRole(
      String role, bool enabled) async {
    final response =
        await _client.dio.get('/users/role/$role/enabled/$enabled');
    return (response.data as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> setUserEnabled(int id, bool enabled) async {
    await _client.dio.put('/users/$id/enable?enabled=$enabled');
  }

  @override
  Future<void> deleteUser(int id) async {
    await _client.dio.delete('/users/$id');
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.dio.put('/users/change-password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  @override
  Future<void> forgotPassword({
    required String username,
    required String newPassword,
  }) async {
    await _client.dio.post('/auth/forgot-password', data: {
      'username': username,
      'newPassword': newPassword,
    });
  }
}

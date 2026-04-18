// providers/user_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../newtork_repos/remote_repo/firestore_services/firestore_db/user_firestore_services.dart';

class UserProvider with ChangeNotifier {
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Add a new user
  Future<void> addUser(UserModel user) async {
    _setLoading(true);
    try {
      String id = await UserFirestoreServices.addData(user);
      _users.add(user.copyWith(id: id));
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Fetch all users
  Future<void> fetchUsers() async {
    _setLoading(true);
    try {
      _users = await UserFirestoreServices.getAllData();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Update a user
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await UserFirestoreServices.updateData(id, data);

      // Update local list
      int index = _users.indexWhere((user) => user.id == id);
      if (index != -1) {
        _users[index] = _users[index].copyWith(
          displayName: data['displayName'] ?? _users[index].displayName,
          email: data['email'] ?? _users[index].email,
          password: data['password'] ?? _users[index].password,
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : _users[index].createdAt,
        );
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

  //update user password by email
  Future<void> updateUserPasswordByEmail(
    String email,
    String newPassword,
  ) async {
    _setLoading(true);
    try {
      await UserFirestoreServices.updateUserPasswordByEmail(email, newPassword);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Delete a user
  Future<void> deleteUser(String id) async {
    _setLoading(true);
    try {
      await UserFirestoreServices.deleteData(id);
      _users.removeWhere((user) => user.id == id);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Listen to real-time updates
  void listenToUsers() {
    UserFirestoreServices.streamAllData().listen(
      (users) {
        _users = users;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
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

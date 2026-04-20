import 'package:flutter/foundation.dart';

import '../models/daily_task_model.dart';
import '../newtork_repos/remote_repo/api_repos/api_network_task_repos_impl.dart';

class TaskProvider with ChangeNotifier {
  final ApiNetworkTaskReposImpl _api = ApiNetworkTaskReposImpl();

  List<DailyTaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<DailyTaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllTasks() async {
    _setLoading(true);
    try {
      _tasks = await _api.getAllTasks();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchTasksByStatus(bool status) async {
    _setLoading(true);
    try {
      _tasks = await _api.getTasksByStatus(status);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchTasksByEmployee(String employeeName) async {
    _setLoading(true);
    try {
      _tasks = await _api.getTasksByEmployee(employeeName);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchTasksByApp(String appName) async {
    _setLoading(true);
    try {
      _tasks = await _api.getTasksByApp(appName);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchTasksByPriority(String priority) async {
    _setLoading(true);
    try {
      _tasks = await _api.getTasksByPriority(priority);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createTask(DailyTaskModel task) async {
    _setLoading(true);
    try {
      final newTask = await _api.createTask(task);
      _tasks.add(newTask);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTask(String id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final updatedTask = await _api.updateTask(id, data);
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = updatedTask;
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

  Future<void> deleteTask(String id) async {
    _setLoading(true);
    try {
      await _api.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      _error = null;
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

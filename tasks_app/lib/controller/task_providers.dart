import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../newtork_repos/remote_repo/firestore_services/firestore_db/task_firestore_services.dart';

class TaskProviders extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Fetch all tasks
  Future<void> fetchTasks() async {
    _setLoading(true);
    try {
      _tasks = await TaskFirestoreServices.getAllTasks();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Fetch all tasks
  Future<void> fetchTasksByStatus(bool status) async {
    _setLoading(true);
    try {
      _tasks = await TaskFirestoreServices.getTasksByStatus(status);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Add a task
  Future<String?> addTask(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final id = await TaskFirestoreServices.addTask(data);
      await fetchTasks(); // Refresh list
      _error = null;
      return id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update a task
  Future<void> updateTask(String id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await TaskFirestoreServices.updateTaskData(id, data);

      // Update local list
      int index = _tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          taskStatus: data['taskStatus'] as bool?,
          assignedTo: data['assignedTo'] as String?,
          updatedAt: DateTime.now(),
          notes: data['taskNote'] as String?,
        );
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    _setLoading(true);
    try {
      await TaskFirestoreServices.deleteTask(id);
      _tasks.removeWhere((task) => task.id == id);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Listen to real-time updates
  void listenToTasks() {
    TaskFirestoreServices.streamTasks().listen(
      (tasks) {
        _tasks = tasks;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Debug method
  void debuglogTaskIds() {
    log('=== Current Task IDs ===');
    for (var task in _tasks) {
      log('Task ID: ${task.id}, Title: ${task.taskTitle}');
    }
    log('=======================');
  }
}

import 'package:flutter/foundation.dart';
import 'package:tasks_app/newtork_repos/local_repos/task_repository.dart';
import '../../models/hive_model/task_model.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _repository;

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  TaskProvider(this._repository) {
    _init();
  }

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _init() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Start listening to task stream
      _repository.tasksStream.listen(
        (tasks) {
          if (!_disposed) {
            _tasks = tasks.where((task) => task.status == true).toList();
            _isLoading = false;
            _error = null;
            notifyListeners();
          }
        },
        onError: (error) {
          if (!_disposed) {
            _error = error.toString();
            _isLoading = false;
            notifyListeners();
          }
        },
      );
    } catch (e) {
      if (!_disposed) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Method to manually fetch tasks (for compatibility with your code)
  Future<void> fetchTasks() async {
    // Since we're using streams, this just triggers a refresh
    _isLoading = true;
    notifyListeners();

    // The stream will update automatically
    await Future.delayed(const Duration(milliseconds: 500));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(TaskModel task) async {
    try {
      await _repository.addTask(task);
    } catch (e) {
      if (!_disposed) {
        _error = e.toString();
        notifyListeners();
        rethrow;
      }
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _repository.updateTask(task);
    } catch (e) {
      if (!_disposed) {
        _error = e.toString();
        notifyListeners();
        rethrow;
      }
    }
  }

  // Alternative update method that takes Map (for compatibility)
  Future<void> updateTaskMap(
    String taskId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final existingTask = _tasks.firstWhere((task) => task.id == taskId);
      final updatedTask = TaskModel(
        id: existingTask.id,
        title: updates['title'] ?? existingTask.title,
        status: updates['status'] ?? existingTask.status,
        taskDescription:
            updates['taskDescription'] ?? existingTask.taskDescription,
        assignedTo: updates['assignedTo'] ?? existingTask.assignedTo,
        createdAt: existingTask.createdAt,
        updatedAt: DateTime.now(),
        notes: updates['notes'] ?? existingTask.notes,
      );
      await _repository.updateTask(updatedTask);
    } catch (e) {
      if (!_disposed) {
        _error = e.toString();
        notifyListeners();
        rethrow;
      }
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _repository.deleteTask(taskId);
    } catch (e) {
      if (!_disposed) {
        _error = e.toString();
        notifyListeners();
        rethrow;
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

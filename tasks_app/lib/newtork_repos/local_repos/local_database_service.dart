// lib/services/local_database_service.dart
import 'package:hive/hive.dart';
import '../../models/hive_model/task_model.dart';

class LocalDatabaseService {
  static const String _taskBoxName = 'tasks_box';
  static const String _pendingSyncBoxName = 'pending_sync_box';

  late Box<TaskModel> _tasksBox;
  late Box<Map<String, dynamic>> _pendingSyncBox;

  Future<void> init() async {
    await Hive.openBox<TaskModel>(_taskBoxName);
    await Hive.openBox<Map<String, dynamic>>(_pendingSyncBoxName);

    _tasksBox = Hive.box<TaskModel>(_taskBoxName);
    _pendingSyncBox = Hive.box<Map<String, dynamic>>(_pendingSyncBoxName);
  }

  // Save task locally
  Future<void> saveTask(TaskModel task) async {
    await _tasksBox.put(task.id, task);

    // If not synced, add to pending sync
    if (!task.isSynced) {
      await _pendingSyncBox.put(task.id, {
        'type': 'create',
        'data': task.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Update task locally
  Future<void> updateTask(TaskModel task) async {
    final existing = _tasksBox.get(task.id);
    if (existing != null) {
      await _tasksBox.put(task.id, task);

      if (!task.isSynced) {
        await _pendingSyncBox.put(task.id, {
          'type': 'update',
          'data': task.toJson(),
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  // Mark task as deleted locally
  Future<void> deleteTask(String taskId) async {
    final task = _tasksBox.get(taskId);
    if (task != null) {
      final deletedTask = task.copyWith(isDeleted: true);
      await _tasksBox.put(taskId, deletedTask);

      await _pendingSyncBox.put(taskId, {
        'type': 'delete',
        'data': {'id': taskId},
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Get all tasks
  List<TaskModel> getAllTasks() {
    return _tasksBox.values.where((task) => !task.isDeleted).toList();
  }

  // Get pending sync operations
  List<Map<String, dynamic>> getPendingSyncs() {
    return _pendingSyncBox.values.toList();
  }

  // Mark task as synced
  Future<void> markAsSynced(String taskId) async {
    final task = _tasksBox.get(taskId);
    if (task != null) {
      await _tasksBox.put(taskId, task.copyWith(isSynced: true));
    }
    await _pendingSyncBox.delete(taskId);
  }

  // Clear pending sync
  Future<void> clearPendingSync(String taskId) async {
    await _pendingSyncBox.delete(taskId);
  }

  // Get unsynced tasks
  List<TaskModel> getUnsyncedTasks() {
    return _tasksBox.values
        .where((task) => !task.isSynced && !task.isDeleted)
        .toList();
  }

  Future<void> clearAll() async {
    await _tasksBox.clear();
    await _pendingSyncBox.clear();
  }

  // Get box names (useful for debugging)
  String get taskBoxName => _taskBoxName;
  String get pendingSyncBoxName => _pendingSyncBoxName;
}

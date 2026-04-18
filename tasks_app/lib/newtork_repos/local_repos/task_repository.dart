// lib/repositories/task_repository.dart
import 'dart:async';
import 'dart:developer';

import 'package:tasks_app/models/hive_model/task_model.dart';
import 'package:tasks_app/newtork_repos/local_repos/firestore_service.dart';
import 'package:tasks_app/newtork_repos/local_repos/local_database_service.dart';
import 'package:tasks_app/services/connectivity_service.dart';


class TaskRepository {
  final LocalDatabaseService _localDb;
  final FirestoreService _firestore;
  final ConnectivityService _connectivity;

  bool _isOnline = false;
  StreamSubscription? _connectivitySubscription;
  final StreamController<List<TaskModel>> _tasksController =
      StreamController<List<TaskModel>>.broadcast();

  TaskRepository({
    required LocalDatabaseService localDb,
    required FirestoreService firestore,
    required ConnectivityService connectivity,
  }) : _localDb = localDb,
       _firestore = firestore,
       _connectivity = connectivity {
    _init();
  }

  Future<void> _init() async {
    await _localDb.init();

    // Start listening to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      isConnected,
    ) {
      _isOnline = isConnected;
      if (isConnected) {
        _syncPendingOperations();
      }
    });

    // Check initial connectivity
    _isOnline = await _connectivity.hasConnection();

    // Load initial data
    await _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (_isOnline) {
      try {
        // Try to get data from Firestore
        final firestoreTasks = await _firestore.getTasks();

        // Save to local database
        for (final task in firestoreTasks) {
          await _localDb.saveTask(task.copyWith(isSynced: true));
        }

        // Sync any pending operations
        await _syncPendingOperations();

        _tasksController.add(firestoreTasks);
      } catch (e) {
        // If Firestore fails, use local data
        final localTasks = _localDb.getAllTasks();
        _tasksController.add(localTasks);
      }
    } else {
      // Use local data when offline
      final localTasks = _localDb.getAllTasks();
      _tasksController.add(localTasks);
    }
  }

  Future<void> _syncPendingOperations() async {
    if (!_isOnline) return;

    final pendingSyncs = _localDb.getPendingSyncs();

    for (final syncOp in pendingSyncs) {
      try {
        final type = syncOp['type'] as String;
        final data = syncOp['data'] as Map<String, dynamic>;

        switch (type) {
          case 'create':
            final task = TaskModel.fromJson(data);
            await _firestore.saveTask(task);
            await _localDb.markAsSynced(task.id);
            break;

          case 'update':
            final task = TaskModel.fromJson(data);
            await _firestore.updateTask(task);
            await _localDb.markAsSynced(task.id);
            break;

          case 'delete':
            final taskId = data['id'] as String;
            await _firestore.deleteTask(taskId);
            await _localDb.clearPendingSync(taskId);
            break;
        }
      } catch (e) {
        log('Failed to sync operation: $e');
        // Keep in pending sync for retry
      }
    }
  }

  Stream<List<TaskModel>> get tasksStream => _tasksController.stream;

  Future<void> addTask(TaskModel task) async {
    // Always save locally first
    await _localDb.saveTask(task);

    // Update stream with local data
    final tasks = _localDb.getAllTasks();
    _tasksController.add(tasks);

    // Try to sync if online
    if (_isOnline) {
      try {
        await _firestore.saveTask(task);
        await _localDb.markAsSynced(task.id);
      } catch (e) {
        // Firestore save failed, task remains unsynced
        log('Firestore save failed: $e');
      }
    }
  }

  Future<void> updateTask(TaskModel task) async {
    // Update locally first
    await _localDb.updateTask(task);

    // Update stream
    final tasks = _localDb.getAllTasks();
    _tasksController.add(tasks);

    // Try to sync if online
    if (_isOnline) {
      try {
        await _firestore.updateTask(task);
        await _localDb.markAsSynced(task.id);
      } catch (e) {
        log('Firestore update failed: $e');
      }
    }
  }

  Future<void> deleteTask(String taskId) async {
    // Mark as deleted locally
    await _localDb.deleteTask(taskId);

    // Update stream
    final tasks = _localDb.getAllTasks();
    _tasksController.add(tasks);

    // Try to sync if online
    if (_isOnline) {
      try {
        await _firestore.deleteTask(taskId);
        await _localDb.clearPendingSync(taskId);
      } catch (e) {
        log('Firestore delete failed: $e');
      }
    }
  }

  List<TaskModel> getTasks() {
    return _localDb.getAllTasks();
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _tasksController.close();
  }
}

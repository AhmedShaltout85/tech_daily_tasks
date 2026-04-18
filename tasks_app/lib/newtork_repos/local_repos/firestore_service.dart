// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/hive_model/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'tasks';

  Future<void> saveTask(TaskModel task) async {
    await _firestore
        .collection(_collectionPath)
        .doc(task.id)
        .set(task.toJson());
  }

  Future<void> updateTask(TaskModel task) async {
    await _firestore
        .collection(_collectionPath)
        .doc(task.id)
        .update(task.toJson());
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection(_collectionPath).doc(taskId).delete();
  }

  Stream<List<TaskModel>> streamTasks() {
    return _firestore
        .collection(_collectionPath)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TaskModel.fromJson({'id': doc.id, ...doc.data()}))
              .toList(),
        );
  }

  Future<List<TaskModel>> getTasks() async {
    final snapshot = await _firestore.collection(_collectionPath).get();
    return snapshot.docs
        .map((doc) => TaskModel.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  }
}

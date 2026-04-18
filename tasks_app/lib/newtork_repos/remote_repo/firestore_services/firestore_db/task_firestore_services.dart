import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../models/task.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

class TaskFirestoreServices {
  // static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collectionName = 'tasks';

  // Fetch all tasks
  static Future<List<Task>> getAllTasks() async {
    try {
      final snapshot = await db
          .collection(_collectionName)
          // .where('taskStatus', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        return Task.fromFirestore(doc);
      }).toList();
    } catch (e) {
      throw Exception('Error retrieving all data: $e');
    }
  }

  // Fetch a list of tasks
  static Future<List<Task>> getTasksByStatus(bool status) async {
    try {
      final snapshot = await db
          .collection(_collectionName)
          .where('taskStatus', isEqualTo: status)
          .where(
            'assignedTo',
            // isEqualTo: FirebaseAuth.instance.currentUser!.email?.substring(
            //   0,
            //   FirebaseAuth.instance.currentUser!.email!.indexOf('@'),
            // ),
            isEqualTo: FirebaseAuth.instance.currentUser!.displayName,
          )
          .get();

      return snapshot.docs.map((doc) {
        return Task.fromFirestore(doc);
      }).toList();
    } catch (e) {
      throw Exception('Error retrieving tasks by status: $e');
    }
  }

  // Fetch a single task
  static Future<Task?> getTask(String id) async {
    try {
      final doc = await db.collection(_collectionName).doc(id).get();

      if (!doc.exists) {
        return null;
      }

      return Task.fromFirestore(doc);
    } catch (e) {
      throw Exception('Error retrieving task: $e');
    }
  }

  // Add a new task (Firestore generates ID)
  static Future<String> addTask(Map<String, dynamic> data) async {
    try {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await db.collection(_collectionName).add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding task: $e');
    }
  }

  // Update a task
  static Future<void> updateTaskData(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      // Check if document exists
      final docSnapshot = await db.collection(_collectionName).doc(id).get();

      if (!docSnapshot.exists) {
        throw Exception('Task with ID $id does not exist');
      }

      // Add update timestamp
      data['updatedAt'] = FieldValue.serverTimestamp();

      await db.collection(_collectionName).doc(id).update(data);
    } catch (e) {
      throw Exception('Error updating data: $e');
    }
  }

  // Update or create task (use set with merge)
  static Future<void> updateOrCreateTask(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();

      await db
          .collection(_collectionName)
          .doc(id)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error updating/creating data: $e');
    }
  }

  // Delete a task
  static Future<void> deleteTask(String id) async {
    try {
      await db.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting task: $e');
    }
  }

  // Stream tasks (real-time updates)
  static Stream<List<Task>> streamTasks() {
    return db
        .collection(_collectionName)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList(),
        );
  }
}

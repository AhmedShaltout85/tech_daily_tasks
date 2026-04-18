// services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasks_app/newtork_repos/remote_repo/firestore_services/firestore_db/task_firestore_services.dart';

import '../../../../models/user_model.dart';

class UserFirestoreServices {
  static const String _collectionName = 'users';

  // Add a new document
  static Future<String> addData(UserModel user) async {
    try {
      DocumentReference docRef = await db
          .collection(_collectionName)
          .add(user.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding data: $e');
    }
  }

  // Add a document with custom ID
  static Future<void> addDataWithId(String id, UserModel user) async {
    try {
      await db.collection(_collectionName).doc(id).set(user.toMap());
    } catch (e) {
      throw Exception('Error adding data with ID: $e');
    }
  }

  // Retrieve a single document by ID
  static Future<UserModel?> getData(String id) async {
    try {
      DocumentSnapshot doc = await db.collection(_collectionName).doc(id).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error retrieving data: $e');
    }
  }

  // Retrieve all documents
  static Future<List<UserModel>> getAllData() async {
    try {
      QuerySnapshot snapshot = await db.collection(_collectionName).get();

      return snapshot.docs
          .map(
            (doc) =>
                UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Error retrieving all data: $e');
    }
  }

  // Retrieve documents with a query
  static Future<List<UserModel>> getDataWhere({
    required String field,
    required dynamic isEqualTo,
  }) async {
    try {
      QuerySnapshot snapshot = await db
          .collection(_collectionName)
          .where(field, isEqualTo: isEqualTo)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Error querying data: $e');
    }
  }

  // Update a document
  static Future<void> updateData(String id, Map<String, dynamic> data) async {
    try {
      await db.collection(_collectionName).doc(id).update(data);
    } catch (e) {
      throw Exception('Error updating data: $e');
    }
  }

  //update user by email
  static Future<void> updateUserPasswordByEmail(
    String email,
    String password,
  ) async {
    try {
      QuerySnapshot snapshot = await db
          .collection(_collectionName)
          .where('email', isEqualTo: email)
          .get();
      if (snapshot.docs.isNotEmpty) {
        String id = snapshot.docs.first.id;
        await db.collection(_collectionName).doc(id).update({
          'password': password,
        });
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Error updating data: $e');
    }
  }

  // Delete a document
  static Future<void> deleteData(String id) async {
    try {
      await db.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting data: $e');
    }
  }

  // Stream for real-time updates (all documents)
  static Stream<List<UserModel>> streamAllData() {
    return db.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Stream for real-time updates (single document)
  static Stream<UserModel?> streamData(String id) {
    return db.collection(_collectionName).doc(id).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }
}

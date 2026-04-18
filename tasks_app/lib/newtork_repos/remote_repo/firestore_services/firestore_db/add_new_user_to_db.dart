import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasks_app/newtork_repos/remote_repo/firestore_services/firestore_db/task_firestore_services.dart';

class AddNewUserToDB {
  // static Future<void> saveUserInfo(UserCredential userCredential) async {
  //   final User? user = userCredential.user;
  //   if (user != null) {
  //     final userDoc = FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(user.uid);
  //     final docSnapshot = await userDoc.get();
  //     if (!docSnapshot.exists) {
  //       await userDoc.set({
  //         'uid': user.uid,
  //         'firstName': user.displayName?.split(' ').first ?? '',
  //         'lastName': user.displayName?.split(' ').last ?? '',
  //         'displayName': user.displayName ?? '',
  //         'email': user.email ?? '',
  //         'photoURL': user.photoURL ?? '',
  //         // 'provider': 'google',
  //         'createdAt': FieldValue.serverTimestamp(),
  //       });
  //     }
  //   }
  // }

  static final String collectionName = 'users';

  // Get collection reference
  // CollectionReference get _collection => db.collection(collectionName);

  static Future<String> saveUser(Map<String, dynamic> data) async {
    try {
      data['createdAt'] = FieldValue.serverTimestamp();

      final docRef = await db.collection(collectionName).add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding task: $e');
    }
  }
}

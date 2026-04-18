// app_name_firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasks_app/newtork_repos/remote_repo/firestore_services/firestore_db/task_firestore_services.dart';
import '../../../../models/app_name_model.dart';

class AppNameFirestoreService {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'appNames';

  // Get collection reference
  CollectionReference get _collection => db.collection(collectionName);

  // Add a new app name
  Future<String> addAppName(String appName) async {
    try {
      DocumentReference docRef = await _collection.add({'appName': appName});

      // Update the document with its own ID
      await docRef.update({'id': docRef.id});

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add app name: $e');
    }
  }

  // Get a single app name by ID
  Future<AppNameModel?> getAppName(String id) async {
    try {
      DocumentSnapshot doc = await _collection.doc(id).get();

      if (doc.exists) {
        return AppNameModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get app name: $e');
    }
  }

  // Get all app names
  Future<List<AppNameModel>> getAllAppNames() async {
    try {
      QuerySnapshot querySnapshot = await _collection.get();

      return querySnapshot.docs.map((doc) {
        return AppNameModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get all app names: $e');
    }
  }

  // Stream all app names (real-time updates)
  Stream<List<AppNameModel>> streamAppNames() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppNameModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    });
  }

  // Update an app name
  Future<void> updateAppName(String id, String newAppName) async {
    try {
      await _collection.doc(id).update({'appName': newAppName});
    } catch (e) {
      throw Exception('Failed to update app name: $e');
    }
  }

  // Delete an app name
  Future<void> deleteAppName(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete app name: $e');
    }
  }

  // Get list of app names as strings only
  Future<List<String>> getAppNamesAsStrings() async {
    try {
      QuerySnapshot querySnapshot = await _collection.get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['appName'] as String;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get app names as strings: $e');
    }
  }

  // Stream app names as strings (real-time updates)
  Stream<List<String>> streamAppNamesAsStrings() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['appName'] as String;
      }).toList();
    });
  }
}

//   WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<AppNameProvider>().fetchAppNamesAsStrings();
//     });

//     // Fetch strings once
// await context.read<AppNameProvider>().fetchAppNamesAsStrings();

// // Access the strings
// List<String> names = context.read<AppNameProvider>().appNameStrings;

// // Or use Consumer to display
// Consumer<AppNameProvider>(
//   builder: (context, provider, child) {
//     return ListView.builder(
//       itemCount: provider.appNameStrings.length,
//       itemBuilder: (context, index) {
//         return Text(provider.appNameStrings[index]);
//       },
//     );
//   },
// )

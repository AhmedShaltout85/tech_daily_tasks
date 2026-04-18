// employee_name_firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasks_app/newtork_repos/remote_repo/firestore_services/firestore_db/task_firestore_services.dart';
import '../../../../models/employee_name_model.dart';

class EmployeeNameFirestoreServices {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'employees';

  // Get collection reference
  CollectionReference get _collection => db.collection(collectionName);

  // Add a new employee name
  Future<String> addEmployeeName(String employeeName) async {
    try {
      DocumentReference docRef = await _collection.add({
        'employee_name': employeeName,
      });

      // Update the document with its own ID
      await docRef.update({'id': docRef.id});

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add employee name: $e');
    }
  }

  // Get a single employee name by ID
  Future<EmployeeNameModel?> getEmployeeName(String id) async {
    try {
      DocumentSnapshot doc = await _collection.doc(id).get();

      if (doc.exists) {
        return EmployeeNameModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get employee name: $e');
    }
  }

  // Get all employee names
  Future<List<EmployeeNameModel>> getAllEmployeeNames() async {
    try {
      QuerySnapshot querySnapshot = await _collection.get();

      return querySnapshot.docs.map((doc) {
        return EmployeeNameModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get all employee names: $e');
    }
  }

  // Stream all employee names (real-time updates)
  Stream<List<EmployeeNameModel>> streamEmployeeNames() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EmployeeNameModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    });
  }

  // Update an employee name
  Future<void> updateEmployeeName(String id, String newEmployeeName) async {
    try {
      await _collection.doc(id).update({'employee_name': newEmployeeName});
    } catch (e) {
      throw Exception('Failed to update employee name: $e');
    }
  }

  // Delete an employee name
  Future<void> deleteEmployeeName(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete employee name: $e');
    }
  }

  // Get list of employee names as strings only
  Future<List<String>> getEmployeeNamesAsStrings() async {
    try {
      QuerySnapshot querySnapshot = await _collection.get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['employee_name'] as String;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get employee names as strings: $e');
    }
  }

  // Stream employee names as strings (real-time updates)
  Stream<List<String>> streamEmployeeNamesAsStrings() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['employee_name'] as String;
      }).toList();
    });
  }
}


// // Setup in main.dart
// MultiProvider(
//   providers: [
//     ChangeNotifierProvider(create: (_) => AppNameProvider()),
//     ChangeNotifierProvider(create: (_) => EmployeeNameProvider()),
//   ],
//   child: MyApp(),
// )

// // Use in your widget
// await context.read<EmployeeNameProvider>().fetchEmployeeNamesAsStrings();
// List<String> names = context.read<EmployeeNameProvider>().employeeNameStrings;
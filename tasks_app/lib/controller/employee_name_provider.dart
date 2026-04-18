// employee_name_provider.dart
import 'package:flutter/foundation.dart';

import '../models/employee_name_model.dart';
import '../newtork_repos/remote_repo/firestore_services/firestore_db/employee_name_firebase_services.dart';

class EmployeeNameProvider extends ChangeNotifier {
  final EmployeeNameFirestoreServices _firestoreService =
      EmployeeNameFirestoreServices();

  List<EmployeeNameModel> _employeeNames = [];
  bool _isLoading = false;
  String? _error;
  List<String> _employeeNameStrings = [];

  // Getters
  List<EmployeeNameModel> get employeeNames => _employeeNames;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get employeeNameStrings => _employeeNameStrings;

  // Add employee name
  Future<void> addEmployeeName(String employeeName) async {
    try {
      _setLoading(true);
      _error = null;

      await _firestoreService.addEmployeeName(employeeName);
      await fetchAllEmployeeNames(); // Refresh the list

      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  // Get single employee name
  Future<EmployeeNameModel?> getEmployeeName(String id) async {
    try {
      _setLoading(true);
      _error = null;

      final employeeName = await _firestoreService.getEmployeeName(id);

      _setLoading(false);
      return employeeName;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  // Fetch all employee names
  Future<void> fetchAllEmployeeNames() async {
    try {
      _setLoading(true);
      _error = null;

      _employeeNames = await _firestoreService.getAllEmployeeNames();

      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  // Listen to real-time updates
  void listenToEmployeeNames() {
    _firestoreService.streamEmployeeNames().listen(
      (employeeNames) {
        _employeeNames = employeeNames;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Update employee name
  Future<void> updateEmployeeName(String id, String newEmployeeName) async {
    try {
      _setLoading(true);
      _error = null;

      await _firestoreService.updateEmployeeName(id, newEmployeeName);
      await fetchAllEmployeeNames(); // Refresh the list

      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  // Delete employee name
  Future<void> deleteEmployeeName(String id) async {
    try {
      _setLoading(true);
      _error = null;

      await _firestoreService.deleteEmployeeName(id);
      await fetchAllEmployeeNames(); // Refresh the list

      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  // Fetch employee names as strings only
  Future<void> fetchEmployeeNamesAsStrings() async {
    try {
      _setLoading(true);
      _error = null;

      _employeeNameStrings = await _firestoreService
          .getEmployeeNamesAsStrings();

      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  // Listen to real-time updates for strings only
  void listenToEmployeeNamesAsStrings() {
    _firestoreService.streamEmployeeNamesAsStrings().listen(
      (employeeNameStrings) {
        _employeeNameStrings = employeeNameStrings;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Private helper to set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

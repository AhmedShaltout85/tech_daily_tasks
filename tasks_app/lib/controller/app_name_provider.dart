import 'package:flutter/foundation.dart';
import 'package:tasks_app/newtork_repos/remote_repo/firestore_services/firestore_db/app_name_firebase_services.dart';
import '../models/app_name_model.dart';

class AppNameProvider extends ChangeNotifier {
  final AppNameFirestoreService _firestoreService = AppNameFirestoreService();

  List<AppNameModel> _appNames = [];
  bool _isLoading = false;
  String? _error;
  List<String> _appNameStrings = [];

  // Getters
  List<AppNameModel> get appNames => _appNames;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get appNameStrings => _appNameStrings;

  // Add app name
  Future<void> addAppName(String appName) async {
    try {
      _setLoading(true);
      _error = null;

      await _firestoreService.addAppName(appName);
      await fetchAllAppNames(); // Refresh the list

      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  // Get single app name
  Future<AppNameModel?> getAppName(String id) async {
    try {
      _setLoading(true);
      _error = null;

      final appName = await _firestoreService.getAppName(id);

      _setLoading(false);
      return appName;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  // Fetch all app names
  Future<void> fetchAllAppNames() async {
    try {
      _setLoading(true);
      _error = null;

      _appNames = await _firestoreService.getAllAppNames();

      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  // Listen to real-time updates
  void listenToAppNames() {
    _firestoreService.streamAppNames().listen(
      (appNames) {
        _appNames = appNames;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Update app name
  Future<void> updateAppName(String id, String newAppName) async {
    try {
      _setLoading(true);
      _error = null;

      await _firestoreService.updateAppName(id, newAppName);
      await fetchAllAppNames(); // Refresh the list

      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  // Delete app name
  Future<void> deleteAppName(String id) async {
    try {
      _setLoading(true);
      _error = null;

      await _firestoreService.deleteAppName(id);
      await fetchAllAppNames(); // Refresh the list

      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  // Fetch app names as strings only
  Future<void> fetchAppNamesAsStrings() async {
    try {
      _setLoading(true);
      _error = null;

      _appNameStrings = await _firestoreService.getAppNamesAsStrings();

      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  // Listen to real-time updates for strings only
  void listenToAppNamesAsStrings() {
    _firestoreService.streamAppNamesAsStrings().listen(
      (appNameStrings) {
        _appNameStrings = appNameStrings;
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

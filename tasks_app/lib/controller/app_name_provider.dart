import 'package:flutter/foundation.dart';

import '../models/app_name_model.dart';
import '../newtork_repos/remote_repo/api_repos/api_network_app_name_repos_impl.dart';

class AppNameProvider with ChangeNotifier {
  final ApiNetworkAppNameReposImpl _api = ApiNetworkAppNameReposImpl();

  List<AppNameModel> _appNames = [];
  bool _isLoading = false;
  String? _error;

  List<AppNameModel> get appNames => _appNames;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllAppNames() async {
    _setLoading(true);
    try {
      _appNames = await _api.getAllAppNames();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addAppName(String appName) async {
    _setLoading(true);
    try {
      final newApp = await _api.addAppName(appName);
      _appNames.add(newApp);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAppName(int id) async {
    _setLoading(true);
    try {
      await _api.deleteAppName(id);
      _appNames.removeWhere((app) => app.id == id);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import '../models/preventive_item_model.dart';
import '../models/preventive_maintenance_model.dart';
import '../newtork_repos/remote_repo/api_repos/api_network_preventive_repos_impl.dart';

class PreventiveProvider with ChangeNotifier {
  final ApiNetworkPreventiveItemReposImpl _api =
      ApiNetworkPreventiveItemReposImpl();

  // Preventive Items
  List<PreventiveItemModel> _preventiveItems = [];
  bool _isLoadingItems = false;
  String? _errorItems;

  // Preventive Maintenance
  List<PreventiveMaintenanceModel> _preventiveMaintenance = [];
  bool _isLoadingMaintenance = false;
  String? _errorMaintenance;

  // Getters - Preventive Items
  List<PreventiveItemModel> get preventiveItems => _preventiveItems;
  bool get isLoadingItems => _isLoadingItems;
  String? get errorItems => _errorItems;

  // Getters - Preventive Maintenance
  List<PreventiveMaintenanceModel> get preventiveMaintenance =>
      _preventiveMaintenance;
  bool get isLoadingMaintenance => _isLoadingMaintenance;
  String? get errorMaintenance => _errorMaintenance;

  void _setLoading(bool isLoading, {bool isItems = true}) {
    if (isItems) {
      _isLoadingItems = isLoading;
    } else {
      _isLoadingMaintenance = isLoading;
    }
    notifyListeners();
  }

  // ============================
  // PREVENTIVE ITEM METHODS
  // ============================

  Future<void> fetchAllPreventiveItems() async {
    _setLoading(true, isItems: true);
    try {
      _preventiveItems = await _api.getAllPreventiveItems();
      _errorItems = null;
    } catch (e) {
      _errorItems = e.toString();
    } finally {
      _setLoading(false, isItems: true);
    }
  }

  Future<void> fetchPreventiveItemById(int id) async {
    _setLoading(true, isItems: true);
    try {
      final item = await _api.getPreventiveItemById(id);
      final index = _preventiveItems.indexWhere((i) => i.id == id);
      if (index != -1) {
        _preventiveItems[index] = item;
      } else {
        _preventiveItems.add(item);
      }
      _errorItems = null;
    } catch (e) {
      _errorItems = e.toString();
    } finally {
      _setLoading(false, isItems: true);
    }
  }

  Future<void> fetchPreventiveItemByAppName(String appName) async {
    _setLoading(true, isItems: true);
    try {
      final item = await _api.getPreventiveItemByAppName(appName);
      final index = _preventiveItems.indexWhere((i) => i.appName == appName);
      if (index != -1) {
        _preventiveItems[index] = item;
      } else {
        _preventiveItems.add(item);
      }
      _errorItems = null;
    } catch (e) {
      _errorItems = e.toString();
    } finally {
      _setLoading(false, isItems: true);
    }
  }

  Future<List<String>> fetchActionsByAppName(String appName) async {
    try {
      return await _api.getActionsByAppName(appName);
    } catch (e) {
      return [];
    }
  }

  Future<void> addPreventiveItem(String appName, String action) async {
    _setLoading(true, isItems: true);
    try {
      final newItem = await _api.addPreventiveItem(appName, action);
      _preventiveItems.add(newItem);
      _errorItems = null;
    } catch (e) {
      _errorItems = e.toString();
    } finally {
      _setLoading(false, isItems: true);
    }
  }

  Future<void> updatePreventiveItem(
      int id, String appName, String action) async {
    _setLoading(true, isItems: true);
    try {
      final updatedItem = await _api.updatePreventiveItem(id, appName, action);
      final index = _preventiveItems.indexWhere((i) => i.id == id);
      if (index != -1) {
        _preventiveItems[index] = updatedItem;
      }
      _errorItems = null;
    } catch (e) {
      _errorItems = e.toString();
    } finally {
      _setLoading(false, isItems: true);
    }
  }

  Future<void> deletePreventiveItem(int id) async {
    _setLoading(true, isItems: true);
    try {
      await _api.deletePreventiveItem(id);
      _preventiveItems.removeWhere((i) => i.id == id);
      _errorItems = null;
    } catch (e) {
      _errorItems = e.toString();
    } finally {
      _setLoading(false, isItems: true);
    }
  }

  // ==============================
  // PREVENTIVE MAINTENANCE METHODS
  // ==============================

  Future<void> fetchAllPreventiveMaintenance() async {
    _setLoading(true, isItems: false);
    try {
      _preventiveMaintenance = await _api.getAllPreventiveMaintenance();
      _errorMaintenance = null;
    } catch (e) {
      _errorMaintenance = e.toString();
    } finally {
      _setLoading(false, isItems: false);
    }
  }

  Future<void> fetchPreventiveMaintenanceById(int id) async {
    _setLoading(true, isItems: false);
    try {
      final item = await _api.getPreventiveMaintenanceById(id);
      final index = _preventiveMaintenance.indexWhere((i) => i.id == id);
      if (index != -1) {
        _preventiveMaintenance[index] = item;
      } else {
        _preventiveMaintenance.add(item);
      }
      _errorMaintenance = null;
    } catch (e) {
      _errorMaintenance = e.toString();
    } finally {
      _setLoading(false, isItems: false);
    }
  }

  Future<void> addPreventiveMaintenance({
    required String appName,
    required String action,
    required String username,
    required String placeName,
    String? subPlace,
    bool? isRemote,
  }) async {
    _setLoading(true, isItems: false);
    try {
      final newItem = await _api.addPreventiveMaintenance(
        appName: appName,
        action: action,
        username: username,
        placeName: placeName,
        subPlace: subPlace,
        isRemote: isRemote,
      );
      _preventiveMaintenance.add(newItem);
      _errorMaintenance = null;
    } catch (e) {
      _errorMaintenance = e.toString();
    } finally {
      _setLoading(false, isItems: false);
    }
  }

  Future<void> updatePreventiveMaintenance({
    required int id,
    required String appName,
    required String action,
    required String username,
    required String placeName,
    String? subPlace,
    bool? isRemote,
  }) async {
    _setLoading(true, isItems: false);
    try {
      final updatedItem = await _api.updatePreventiveMaintenance(
        id: id,
        appName: appName,
        action: action,
        username: username,
        placeName: placeName,
        subPlace: subPlace,
        isRemote: isRemote,
      );
      final index = _preventiveMaintenance.indexWhere((i) => i.id == id);
      if (index != -1) {
        _preventiveMaintenance[index] = updatedItem;
      }
      _errorMaintenance = null;
    } catch (e) {
      _errorMaintenance = e.toString();
    } finally {
      _setLoading(false, isItems: false);
    }
  }

  Future<void> deletePreventiveMaintenance(int id) async {
    _setLoading(true, isItems: false);
    try {
      await _api.deletePreventiveMaintenance(id);
      _preventiveMaintenance.removeWhere((i) => i.id == id);
      _errorMaintenance = null;
    } catch (e) {
      _errorMaintenance = e.toString();
    } finally {
      _setLoading(false, isItems: false);
    }
  }

  // Filter methods
  Future<void> fetchMaintenanceByAppName(String appName) async {
    _setLoading(true, isItems: false);
    try {
      _preventiveMaintenance = await _api.getMaintenanceByAppName(appName);
      _errorMaintenance = null;
    } catch (e) {
      _errorMaintenance = e.toString();
    } finally {
      _setLoading(false, isItems: false);
    }
  }

  Future<void> fetchMaintenanceByUsername(String username) async {
    _setLoading(true, isItems: false);
    try {
      _preventiveMaintenance = await _api.getMaintenanceByUsername(username);
      _errorMaintenance = null;
    } catch (e) {
      _errorMaintenance = e.toString();
    } finally {
      _setLoading(false, isItems: false);
    }
  }

  Future<void> fetchMaintenanceByPlaceName(String placeName) async {
    _setLoading(true, isItems: false);
    try {
      _preventiveMaintenance = await _api.getMaintenanceByPlaceName(placeName);
      _errorMaintenance = null;
    } catch (e) {
      _errorMaintenance = e.toString();
    } finally {
      _setLoading(false, isItems: false);
    }
  }

  Future<void> fetchMaintenanceByIsRemote(bool isRemote) async {
    _setLoading(true, isItems: false);
    try {
      _preventiveMaintenance = await _api.getMaintenanceByIsRemote(isRemote);
      _errorMaintenance = null;
    } catch (e) {
      _errorMaintenance = e.toString();
    } finally {
      _setLoading(false, isItems: false);
    }
  }

  void clearItems() {
    _preventiveItems = [];
    _errorItems = null;
    notifyListeners();
  }

  void clearMaintenance() {
    _preventiveMaintenance = [];
    _errorMaintenance = null;
    notifyListeners();
  }
}

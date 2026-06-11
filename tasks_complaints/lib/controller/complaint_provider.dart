import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/complaint_model.dart';
import '../network/complaint_api_repository.dart';

class ComplaintProvider with ChangeNotifier {
  final ComplaintApiRepository _api = ComplaintApiRepository();

  List<ComplaintModel> _complaints = [];
  List<ComplaintModel> _allComplaints = [];
  bool _isLoading = false;
  String? _error;
  String? _activeFilterType;
  String? _activeFilterValue;

  List<ComplaintModel> get complaints => _complaints;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveFilter => _activeFilterType != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fetchAllComplaints() async {
    _setLoading(true);
    _setError(null);
    try {
      _allComplaints = await _api.getAllComplaints();
      _applyActiveFilter();
    } on DioException catch (e) {
      _setError(e.message ?? 'فشل في تحميل البيانات');
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createComplaint(ComplaintModel complaint) async {
    _setLoading(true);
    _setError(null);
    try {
      await _api.createComplaint(complaint);
      await fetchAllComplaints();
    } on DioException catch (e) {
      _setError(e.message ?? 'فشل في إضافة الشكوى');
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> updateComplaint(int id, ComplaintModel complaint) async {
    _setLoading(true);
    _setError(null);
    try {
      await _api.updateComplaint(id, complaint);
      await fetchAllComplaints();
    } on DioException catch (e) {
      _setError(e.message ?? 'فشل في تحديث الشكوى');
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> deleteComplaint(int id) async {
    _setLoading(true);
    _setError(null);
    try {
      await _api.deleteComplaint(id);
      await fetchAllComplaints();
    } on DioException catch (e) {
      _setError(e.message ?? 'فشل في حذف الشكوى');
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  void filterByAppName(String appName) {
    _activeFilterType = 'appName';
    _activeFilterValue = appName;
    _applyActiveFilter();
  }

  void filterByDepartment(String department) {
    _activeFilterType = 'department';
    _activeFilterValue = department;
    _applyActiveFilter();
  }

  void filterByEmpName(String empName) {
    _activeFilterType = 'empName';
    _activeFilterValue = empName;
    _applyActiveFilter();
  }

  void clearFilter() {
    _activeFilterType = null;
    _activeFilterValue = null;
    _complaints = List.from(_allComplaints);
    notifyListeners();
  }

  void _applyActiveFilter() {
    if (_activeFilterType == null || _activeFilterValue == null) {
      _complaints = List.from(_allComplaints);
    } else {
      switch (_activeFilterType) {
        case 'appName':
          _complaints = _allComplaints
              .where((c) => c.appName == _activeFilterValue)
              .toList();
          break;
        case 'department':
          _complaints = _allComplaints
              .where((c) => c.department == _activeFilterValue)
              .toList();
          break;
        case 'empName':
          _complaints = _allComplaints
              .where((c) => c.empName == _activeFilterValue)
              .toList();
          break;
        default:
          _complaints = List.from(_allComplaints);
      }
    }
    notifyListeners();
  }

  List<String> getUniqueAppNames() {
    return _allComplaints.map((c) => c.appName).toSet().toList();
  }

  List<String> getUniqueDepartments() {
    return _allComplaints.map((c) => c.department).toSet().toList();
  }

  List<String> getUniqueEmpNames() {
    return _allComplaints.map((c) => c.empName).toSet().toList();
  }
}

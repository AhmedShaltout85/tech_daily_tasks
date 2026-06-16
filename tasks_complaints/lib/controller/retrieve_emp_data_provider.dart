import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../models/retrieve_emp_data_model.dart';
import '../network/retrieve_emp_data_api_repository.dart';

class RetrieveEmpDataProvider with ChangeNotifier {
  final RetrieveEmpDataApiRepository _api = RetrieveEmpDataApiRepository();

  RetrieveEmpDataModel? _empData;
  bool _isLoading = false;
  String? _error;

  RetrieveEmpDataModel? get empData => _empData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEmpByEmpId(int empId) async {
    _isLoading = true;
    _error = null;
    _empData = null;
    notifyListeners();

    try {
      final results = await _api.getEmpByEmpId(empId);
      if (results.isNotEmpty) {
        _empData = results.first;
      } else {
        _error = 'لم يتم العثور على موظف برقم $empId';
      }
    } on DioException catch (e) {
      log('RetrieveEmpDataProvider: DioException: ${e.message}');
      _error = 'حدث خطأ في الاتصال بالخادم';
    } catch (e) {
      log('RetrieveEmpDataProvider: Error: $e');
      _error = 'حدث خطأ غير متوقع';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearEmpData() {
    _empData = null;
    _error = null;
    notifyListeners();
  }
}

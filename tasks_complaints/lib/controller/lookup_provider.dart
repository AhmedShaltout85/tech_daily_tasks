import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/about_app_model.dart';
import '../models/place_item_model.dart';
import '../network/lookup_api_repository.dart';

class LookupProvider with ChangeNotifier {
  final LookupApiRepository _api = LookupApiRepository();

  List<AboutAppModel> _aboutApps = [];
  List<PlaceItemModel> _placeItems = [];
  bool _isLoading = false;
  String? _error;

  List<AboutAppModel> get aboutApps => _aboutApps;
  List<PlaceItemModel> get placeItems => _placeItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<String> get appNames =>
      _aboutApps.map((a) => a.appName).toSet().toList();

  List<String> get placeNames =>
      _placeItems.map((p) => p.placeName).toSet().toList();

  Future<void> fetchAllLookups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.getAllAboutApps(),
        _api.getAllPlaceItems(),
      ]);

      _aboutApps = results[0] as List<AboutAppModel>;
      _placeItems = results[1] as List<PlaceItemModel>;
    } on DioException catch (e) {
      _error = e.message ?? 'فشل في تحميل البيانات';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

import '../models/about_app_model.dart';
import '../models/place_item_model.dart';
import 'dio_client.dart';

class LookupApiRepository {
  final _dio = DioClient().dio;

  Future<List<AboutAppModel>> getAllAboutApps() async {
    final response = await _dio.get('/api/about-apps');
    return (response.data as List)
        .map((json) => AboutAppModel.fromJson(json))
        .toList();
  }

  Future<List<PlaceItemModel>> getAllPlaceItems() async {
    final response = await _dio.get('/api/place-items');
    return (response.data as List)
        .map((json) => PlaceItemModel.fromJson(json))
        .toList();
  }
}

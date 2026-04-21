import '../../../models/app_name_model.dart';
import 'api_network_app_name_repos.dart';
import 'dio_client.dart';

class ApiNetworkAppNameReposImpl implements ApiNetworkAppNameRepos {
  static final ApiNetworkAppNameReposImpl instance =
      ApiNetworkAppNameReposImpl._();
  final DioClient _client = DioClient();

  ApiNetworkAppNameReposImpl._();

  factory ApiNetworkAppNameReposImpl() => instance;

  @override
  Future<List<AppNameModel>> getAllAppNames() async {
    final response = await _client.dio.get('/apps');
    return (response.data as List)
        .map((json) => AppNameModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<AppNameModel>> getAppNamesByDepartment(String department) async {
    final response = await _client.dio.get('/apps/department/$department');
    return (response.data as List)
        .map((json) => AppNameModel.fromJson(json))
        .toList();
  }

  @override
  Future<AppNameModel> addAppName(String appName, String department) async {
    final response = await _client.dio.post('/apps', data: {
      'appName': appName,
      'department': department,
    });
    return AppNameModel.fromJson(response.data);
  }

  @override
  Future<AppNameModel> updateAppName(
      int id, String appName, String department) async {
    final response = await _client.dio.put('/apps/$id', data: {
      'appName': appName,
      'department': department,
    });
    return AppNameModel.fromJson(response.data);
  }

  @override
  Future<void> deleteAppName(int id) async {
    await _client.dio.delete('/apps/$id');
  }
}

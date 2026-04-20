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
  Future<AppNameModel> addAppName(String appName) async {
    final response =
        await _client.dio.post('/apps', data: {'appName': appName});
    return AppNameModel.fromJson(response.data);
  }

  @override
  Future<void> deleteAppName(int id) async {
    await _client.dio.delete('/apps/$id');
  }
}

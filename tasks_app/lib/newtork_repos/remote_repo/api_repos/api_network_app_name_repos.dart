import '../../../models/app_name_model.dart';

abstract class ApiNetworkAppNameRepos {
  Future<List<AppNameModel>> getAllAppNames();

  Future<AppNameModel> addAppName(String appName);

  Future<void> deleteAppName(int id);
}

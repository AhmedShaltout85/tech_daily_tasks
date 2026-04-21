import '../../../models/app_name_model.dart';

abstract class ApiNetworkAppNameRepos {
  Future<List<AppNameModel>> getAllAppNames();

  Future<List<AppNameModel>> getAppNamesByDepartment(String department);

  Future<AppNameModel> addAppName(String appName, String department);

  Future<AppNameModel> updateAppName(int id, String appName, String department);

  Future<void> deleteAppName(int id);
}

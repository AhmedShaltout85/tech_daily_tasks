import '../../../models/about_app_model.dart';

abstract class ApiNetworkAboutAppRepos {
  Future<List<AboutApp>> getAllAboutApps();

  Future<List<AboutApp>> getAppsByDepartment(String department);

  Future<AboutApp> getAboutAppById(int id);

  Future<AboutApp> getAboutAppByAppName(String appName);

  Future<List<String>> getRecommendedValuesByAppName(String appName);

  Future<AboutApp> addAboutApp(
      String appName, String department, List<String> recommended);

  Future<AboutApp> updateAboutApp(
      int id, String appName, String department, List<String> recommended);

  Future<void> deleteAboutApp(int id);
}

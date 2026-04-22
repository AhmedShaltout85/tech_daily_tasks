import '../../../models/about_app_model.dart';

abstract class ApiNetworkAboutAppRepos {
  Future<List<AboutApp>> getAllAboutApps();

  Future<AboutApp> getAboutAppById(int id);

  Future<AboutApp> getAboutAppByAppName(String appName);

  Future<List<String>> getRecommendedValuesByAppName(String appName);

  Future<AboutApp> addAboutApp(String appName, String recommended);

  Future<AboutApp> updateAboutApp(int id, String appName, String recommended);

  Future<void> deleteAboutApp(int id);

  Future<AboutApp> addRecommendedValue(String appName, String recommended);

  Future<AboutApp> updateRecommendedValue(int id, String recommended);

  Future<void> deleteRecommendedValue(int id);
}

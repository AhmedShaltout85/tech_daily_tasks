import '../../../models/daily_task_model.dart';

abstract class ApiNetworkTaskRepos {
  Future<List<DailyTaskModel>> getAllTasks();

  Future<List<DailyTaskModel>> getTasksByStatus(bool status);

  Future<List<DailyTaskModel>> getTasksByEmployee(String employeeName);

  Future<List<DailyTaskModel>> getTasksByApp(String appName);

  Future<List<DailyTaskModel>> getTasksByPriority(String priority);

  Future<DailyTaskModel> createTask(DailyTaskModel task);

  Future<DailyTaskModel> updateTask(String id, Map<String, dynamic> data);

  Future<void> deleteTask(String id);
}

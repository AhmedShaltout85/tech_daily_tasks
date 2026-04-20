import '../../../models/daily_task_model.dart';
import 'api_network_task_repos.dart';
import 'dio_client.dart';

class ApiNetworkTaskReposImpl implements ApiNetworkTaskRepos {
  static final ApiNetworkTaskReposImpl instance = ApiNetworkTaskReposImpl._();
  final DioClient _client = DioClient();

  ApiNetworkTaskReposImpl._();

  factory ApiNetworkTaskReposImpl() => instance;

  @override
  Future<List<DailyTaskModel>> getAllTasks() async {
    final response = await _client.dio.get('/tasks');
    return (response.data as List)
        .map((json) => DailyTaskModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<DailyTaskModel>> getTasksByStatus(bool status) async {
    final response = await _client.dio.get('/tasks/status/$status');
    return (response.data as List)
        .map((json) => DailyTaskModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<DailyTaskModel>> getTasksByEmployee(String employeeName) async {
    final response = await _client.dio.get('/tasks/employee/$employeeName');
    return (response.data as List)
        .map((json) => DailyTaskModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<DailyTaskModel>> getTasksByApp(String appName) async {
    final response = await _client.dio.get('/tasks/app/$appName');
    return (response.data as List)
        .map((json) => DailyTaskModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<DailyTaskModel>> getTasksByPriority(String priority) async {
    final response = await _client.dio.get('/tasks/priority/$priority');
    return (response.data as List)
        .map((json) => DailyTaskModel.fromJson(json))
        .toList();
  }

  @override
  Future<DailyTaskModel> createTask(DailyTaskModel task) async {
    final response = await _client.dio.post('/tasks', data: task.toJson());
    return DailyTaskModel.fromJson(response.data);
  }

  @override
  Future<DailyTaskModel> updateTask(
      String id, Map<String, dynamic> data) async {
    final response = await _client.dio.put('/tasks/$id', data: data);
    return DailyTaskModel.fromJson(response.data);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _client.dio.delete('/tasks/$id');
  }
}

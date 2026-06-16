import '../models/retrieve_emp_data_model.dart';
import 'dio_client.dart';

class RetrieveEmpDataApiRepository {
  final _dio = DioClient().dio;

  Future<List<RetrieveEmpDataModel>> getEmpByEmpId(int empId) async {
    final response = await _dio.get('/api/retrieve-emp-data/emp-id/$empId');
    return (response.data as List)
        .map((json) => RetrieveEmpDataModel.fromJson(json))
        .toList();
  }

  Future<RetrieveEmpDataModel> getItemById(int id) async {
    final response = await _dio.get('/api/retrieve-emp-data/$id');
    return RetrieveEmpDataModel.fromJson(response.data);
  }
}

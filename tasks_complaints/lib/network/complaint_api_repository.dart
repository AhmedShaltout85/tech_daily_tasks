import 'package:dio/dio.dart';
import '../models/complaint_model.dart';
import 'dio_client.dart';

class ComplaintApiRepository {
  final Dio _dio = DioClient().dio;

  Future<List<ComplaintModel>> getAllComplaints() async {
    final response = await _dio.get('/api/emp-complaints');
    return (response.data as List)
        .map((json) => ComplaintModel.fromJson(json))
        .toList();
  }

  Future<ComplaintModel> getComplaintById(int id) async {
    final response = await _dio.get('/api/emp-complaints/$id');
    return ComplaintModel.fromJson(response.data);
  }

  Future<ComplaintModel> createComplaint(ComplaintModel complaint) async {
    final response = await _dio.post(
      '/api/emp-complaints',
      data: complaint.toJson(),
    );
    return ComplaintModel.fromJson(response.data);
  }

  Future<ComplaintModel> updateComplaint(int id, ComplaintModel complaint) async {
    final response = await _dio.put(
      '/api/emp-complaints/$id',
      data: complaint.toJson(),
    );
    return ComplaintModel.fromJson(response.data);
  }

  Future<void> deleteComplaint(int id) async {
    await _dio.delete('/api/emp-complaints/$id');
  }

  Future<List<ComplaintModel>> getByAppName(String appName) async {
    final response = await _dio.get('/api/emp-complaints/app/$appName');
    return (response.data as List)
        .map((json) => ComplaintModel.fromJson(json))
        .toList();
  }

  Future<List<ComplaintModel>> getByDepartment(String department) async {
    final response = await _dio.get('/api/emp-complaints/department/$department');
    return (response.data as List)
        .map((json) => ComplaintModel.fromJson(json))
        .toList();
  }

  Future<List<ComplaintModel>> getByEmpName(String empName) async {
    final response = await _dio.get('/api/emp-complaints/emp-name/$empName');
    return (response.data as List)
        .map((json) => ComplaintModel.fromJson(json))
        .toList();
  }
}

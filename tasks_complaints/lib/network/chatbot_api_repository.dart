import 'package:dio/dio.dart';
import '../models/chatbot_qa_model.dart';

class ChatbotDioClient {
  static final ChatbotDioClient instance = ChatbotDioClient._();
  factory ChatbotDioClient() => instance;

  late final Dio _dio;

  static const String _baseUrl = 'http://41.33.226.211:8099/tasks-chatbot-qa';

  ChatbotDioClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

  Dio get dio => _dio;
}

class ChatbotApiRepository {
  final _dio = ChatbotDioClient().dio;

  Future<List<ChatbotQAModel>> getAllActiveQuestions() async {
    final response = await _dio.get('/api/chatbot/questions');
    return (response.data as List)
        .map((json) => ChatbotQAModel.fromJson(json))
        .toList();
  }

  Future<ChatbotQAModel> getQuestionById(int id) async {
    final response = await _dio.get('/api/chatbot/questions/$id');
    return ChatbotQAModel.fromJson(response.data);
  }

  Future<List<String>> getCategories() async {
    final response = await _dio.get('/api/chatbot/categories');
    return List<String>.from(response.data);
  }

  Future<List<ChatbotQAModel>> getQuestionsByCategory(String category) async {
    final response =
        await _dio.get('/api/chatbot/questions/category/$category');
    return (response.data as List)
        .map((json) => ChatbotQAModel.fromJson(json))
        .toList();
  }
}

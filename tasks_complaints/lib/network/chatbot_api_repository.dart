import '../models/chatbot_qa_model.dart';
import 'dio_client.dart';

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

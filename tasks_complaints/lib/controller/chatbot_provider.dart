import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/chatbot_qa_model.dart';
import '../network/chatbot_api_repository.dart';

class ChatbotProvider with ChangeNotifier {
  final ChatbotApiRepository _api = ChatbotApiRepository();

  List<ChatbotQAModel> _questions = [];
  List<String> _categories = [];
  String? _selectedCategory;
  bool _isLoading = false;
  String? _error;

  List<ChatbotQAModel> get questions => _questions;
  List<String> get categories => _categories;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.getAllActiveQuestions(),
        _api.getCategories(),
      ]);

      _questions = results[0] as List<ChatbotQAModel>;
      _categories = results[1] as List<String>;
    } on DioException catch (e) {
      _error = e.message ?? 'فشل في تحميل البيانات';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchByCategory(String category) async {
    _isLoading = true;
    _error = null;
    _selectedCategory = category;
    notifyListeners();

    try {
      _questions = await _api.getQuestionsByCategory(category);
    } on DioException catch (e) {
      _error = e.message ?? 'فشل في تحميل البيانات';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCategoryFilter() {
    _selectedCategory = null;
    fetchAllData();
  }
}

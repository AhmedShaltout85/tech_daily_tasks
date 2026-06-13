package com.ao8r.tasks_chatbot_qa.service;

import com.ao8r.tasks_chatbot_qa.dto.ChatbotQARequest;
import com.ao8r.tasks_chatbot_qa.dto.ChatbotQAResponse;

import java.util.List;

public interface ChatbotQAService {

    // User endpoints
    List<ChatbotQAResponse> getAllActiveQuestions();

    ChatbotQAResponse getAnswerById(Long id);

    List<String> getActiveCategories();

    List<ChatbotQAResponse> getByCategory(String category);

    // Admin CRUD
    List<ChatbotQAResponse> getAllItems();

    ChatbotQAResponse createItem(ChatbotQARequest request);

    ChatbotQAResponse updateItem(Long id, ChatbotQARequest request);

    void deleteItem(Long id);
}

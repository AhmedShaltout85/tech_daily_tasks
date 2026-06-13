package com.ao8r.tasks_chatbot_qa.service;

import com.ao8r.tasks_chatbot_qa.dto.ChatbotQARequest;
import com.ao8r.tasks_chatbot_qa.dto.ChatbotQAResponse;
import com.ao8r.tasks_chatbot_qa.entity.ChatbotQA;
import com.ao8r.tasks_chatbot_qa.exception.ResourceNotFoundException;
import com.ao8r.tasks_chatbot_qa.repository.ChatbotQARepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChatbotQAServiceImpl implements ChatbotQAService {

    private final ChatbotQARepository chatbotQARepository;

    // User endpoints

    @Override
    public List<ChatbotQAResponse> getAllActiveQuestions() {
        log.debug("Fetching all active chatbot questions");
        return chatbotQARepository.findByIsActiveTrueOrderByDisplayOrderAsc().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public ChatbotQAResponse getAnswerById(Long id) {
        log.debug("Fetching chatbot Q&A by id: {}", id);
        ChatbotQA item = chatbotQARepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Chatbot Q&A not found with id: " + id));
        return mapToResponse(item);
    }

    @Override
    public List<String> getActiveCategories() {
        log.debug("Fetching distinct active categories");
        return chatbotQARepository.findDistinctActiveCategories();
    }

    @Override
    public List<ChatbotQAResponse> getByCategory(String category) {
        log.debug("Fetching active questions by category: {}", category);
        return chatbotQARepository.findByCategoryAndIsActiveTrueOrderByDisplayOrderAsc(category).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    // Admin CRUD

    @Override
    public List<ChatbotQAResponse> getAllItems() {
        log.debug("Fetching all chatbot Q&As (admin)");
        return chatbotQARepository.findAllByOrderByDisplayOrderAsc().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public ChatbotQAResponse createItem(ChatbotQARequest request) {
        log.debug("Creating new chatbot Q&A: {}", request.getQuestion());

        ChatbotQA item = ChatbotQA.builder()
                .question(request.getQuestion())
                .answer(request.getAnswer())
                .category(request.getCategory())
                .displayOrder(request.getDisplayOrder())
                .isActive(request.getIsActive() != null ? request.getIsActive() : true)
                .build();

        ChatbotQA savedItem = chatbotQARepository.save(item);
        log.info("Chatbot Q&A created successfully with id: {}", savedItem.getId());

        return mapToResponse(savedItem);
    }

    @Override
    @Transactional
    public ChatbotQAResponse updateItem(Long id, ChatbotQARequest request) {
        log.debug("Updating chatbot Q&A with id: {}", id);

        ChatbotQA item = chatbotQARepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Chatbot Q&A not found with id: " + id));

        item.setQuestion(request.getQuestion());
        item.setAnswer(request.getAnswer());
        item.setCategory(request.getCategory());
        item.setDisplayOrder(request.getDisplayOrder());
        item.setIsActive(request.getIsActive() != null ? request.getIsActive() : true);

        ChatbotQA updatedItem = chatbotQARepository.save(item);
        log.info("Chatbot Q&A updated successfully with id: {}", updatedItem.getId());

        return mapToResponse(updatedItem);
    }

    @Override
    @Transactional
    public void deleteItem(Long id) {
        log.debug("Deleting chatbot Q&A with id: {}", id);

        if (!chatbotQARepository.existsById(id)) {
            throw new ResourceNotFoundException("Chatbot Q&A not found with id: " + id);
        }

        chatbotQARepository.deleteById(id);
        log.info("Chatbot Q&A deleted successfully with id: {}", id);
    }

    private ChatbotQAResponse mapToResponse(ChatbotQA item) {
        return ChatbotQAResponse.builder()
                .id(item.getId())
                .question(item.getQuestion())
                .answer(item.getAnswer())
                .category(item.getCategory())
                .displayOrder(item.getDisplayOrder())
                .isActive(item.getIsActive())
                .build();
    }
}

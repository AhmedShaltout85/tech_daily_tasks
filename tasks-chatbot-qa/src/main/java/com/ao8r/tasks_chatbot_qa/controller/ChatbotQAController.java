package com.ao8r.tasks_chatbot_qa.controller;

import com.ao8r.tasks_chatbot_qa.dto.ChatbotQARequest;
import com.ao8r.tasks_chatbot_qa.dto.ChatbotQAResponse;
import com.ao8r.tasks_chatbot_qa.dto.MessageResponse;
import com.ao8r.tasks_chatbot_qa.service.ChatbotQAService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chatbot")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
@Slf4j
public class ChatbotQAController {

    private final ChatbotQAService chatbotQAService;

    // User endpoints

    @GetMapping("/questions")
    public ResponseEntity<List<ChatbotQAResponse>> getAllActiveQuestions() {
        log.debug("Fetching all active chatbot questions");
        List<ChatbotQAResponse> items = chatbotQAService.getAllActiveQuestions();
        return ResponseEntity.ok(items);
    }

    @GetMapping("/questions/{id}")
    public ResponseEntity<ChatbotQAResponse> getAnswerById(@PathVariable Long id) {
        log.debug("Fetching chatbot Q&A by id: {}", id);
        ChatbotQAResponse response = chatbotQAService.getAnswerById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/categories")
    public ResponseEntity<List<String>> getActiveCategories() {
        log.debug("Fetching distinct active categories");
        List<String> categories = chatbotQAService.getActiveCategories();
        return ResponseEntity.ok(categories);
    }

    @GetMapping("/questions/category/{category}")
    public ResponseEntity<List<ChatbotQAResponse>> getByCategory(@PathVariable String category) {
        log.debug("Fetching active questions by category: {}", category);
        List<ChatbotQAResponse> items = chatbotQAService.getByCategory(category);
        return ResponseEntity.ok(items);
    }

    // Admin endpoints

    @GetMapping("/admin/all")
    public ResponseEntity<List<ChatbotQAResponse>> getAllItems() {
        log.debug("Fetching all chatbot Q&As (admin)");
        List<ChatbotQAResponse> items = chatbotQAService.getAllItems();
        return ResponseEntity.ok(items);
    }

    @PostMapping("/admin")
    public ResponseEntity<ChatbotQAResponse> createItem(@Valid @RequestBody ChatbotQARequest request) {
        log.info("Creating new chatbot Q&A: {}", request.getQuestion());
        ChatbotQAResponse response = chatbotQAService.createItem(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/admin/{id}")
    public ResponseEntity<ChatbotQAResponse> updateItem(@PathVariable Long id,
                                           @Valid @RequestBody ChatbotQARequest request) {
        log.info("Updating chatbot Q&A with id: {}", id);
        ChatbotQAResponse response = chatbotQAService.updateItem(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/admin/{id}")
    public ResponseEntity<MessageResponse> deleteItem(@PathVariable Long id) {
        log.info("Deleting chatbot Q&A with id: {}", id);
        chatbotQAService.deleteItem(id);
        return ResponseEntity.ok(new MessageResponse("Chatbot Q&A deleted successfully!"));
    }
}

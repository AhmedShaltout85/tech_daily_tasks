package com.ao8r.tasks_chatbot_qa;

import com.ao8r.tasks_chatbot_qa.dto.ChatbotQARequest;
import com.ao8r.tasks_chatbot_qa.dto.ChatbotQAResponse;
import com.ao8r.tasks_chatbot_qa.dto.MessageResponse;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.*;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class ChatbotQAIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    private static final String BASE_URL = "/api/chatbot";
    private static Long createdId;

    @Test
    @Order(1)
    void test01_createQA() {
        ChatbotQARequest request = ChatbotQARequest.builder()
                .question("ما هي منظومة المعامل الإلكترونية؟")
                .answer("منظومة المعامل الإلكترونية هي نظام إلكتروني لإدارة المعامل الإدارية")
                .category("منظومة المعامل")
                .displayOrder(1)
                .isActive(true)
                .build();

        ResponseEntity<ChatbotQAResponse> response = restTemplate.postForEntity(
                BASE_URL + "/admin", request, ChatbotQAResponse.class);

        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        assertNotNull(response.getBody());
        assertNotNull(response.getBody().getId());
        assertEquals("ما هي منظومة المعامل الإلكترونية؟", response.getBody().getQuestion());
        assertEquals("منظومة المعامل", response.getBody().getCategory());

        createdId = response.getBody().getId();
    }

    @Test
    @Order(2)
    void test02_getAllActiveQuestions() {
        ResponseEntity<ChatbotQAResponse[]> response = restTemplate.getForEntity(
                BASE_URL + "/questions", ChatbotQAResponse[].class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().length >= 1);
    }

    @Test
    @Order(3)
    void test03_getAnswerById() {
        ResponseEntity<ChatbotQAResponse> response = restTemplate.getForEntity(
                BASE_URL + "/questions/" + createdId, ChatbotQAResponse.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(createdId, response.getBody().getId());
        assertEquals("ما هي منظومة المعامل الإلكترونية؟", response.getBody().getQuestion());
    }

    @Test
    @Order(4)
    void test04_updateQA() {
        ChatbotQARequest request = ChatbotQARequest.builder()
                .question("ما هي منظومة المعامل الإلكترونية؟ (محدث)")
                .answer("منظومة المعامل الإلكترونية هي نظام إلكتروني لإدارة المعامل الإدارية - محدث")
                .category("منظومة المعامل")
                .displayOrder(1)
                .isActive(true)
                .build();

        HttpEntity<ChatbotQARequest> entity = new HttpEntity<>(request);

        ResponseEntity<ChatbotQAResponse> response = restTemplate.exchange(
                BASE_URL + "/admin/" + createdId, HttpMethod.PUT, entity, ChatbotQAResponse.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("ما هي منظومة المعامل الإلكترونية؟ (محدث)", response.getBody().getQuestion());
    }

    @Test
    @Order(5)
    void test05_getCategories() {
        ResponseEntity<String[]> response = restTemplate.getForEntity(
                BASE_URL + "/categories", String[].class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().length >= 1);
    }

    @Test
    @Order(6)
    void test06_getByCategory() {
        ResponseEntity<ChatbotQAResponse[]> response = restTemplate.getForEntity(
                BASE_URL + "/questions/category/منظومة المعامل", ChatbotQAResponse[].class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().length >= 1);
    }

    @Test
    @Order(7)
    void test07_getAllItemsAdmin() {
        ResponseEntity<ChatbotQAResponse[]> response = restTemplate.getForEntity(
                BASE_URL + "/admin/all", ChatbotQAResponse[].class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().length >= 1);
    }

    @Test
    @Order(8)
    void test08_deleteQA() {
        ResponseEntity<MessageResponse> response = restTemplate.exchange(
                BASE_URL + "/admin/" + createdId, HttpMethod.DELETE, null, MessageResponse.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("Chatbot Q&A deleted successfully!", response.getBody().getMessage());
    }
}

package com.a08r.tasks_emp_complaint;

import com.a08r.tasks_emp_complaint.dto.PlaceItemRequest;
import com.a08r.tasks_emp_complaint.dto.PlaceItemResponse;
import com.a08r.tasks_emp_complaint.dto.MessageResponse;
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
class PlaceItemIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    private static final String BASE_URL = "/api/place-items";
    private static Long createdId;

    @Test
    @Order(1)
    void test01_createPlaceItem() {
        PlaceItemRequest request = PlaceItemRequest.builder()
                .placeName("Main Office")
                .build();

        ResponseEntity<PlaceItemResponse> response = restTemplate.postForEntity(
                BASE_URL, request, PlaceItemResponse.class);

        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        assertNotNull(response.getBody());
        assertNotNull(response.getBody().getId());
        assertEquals("Main Office", response.getBody().getPlaceName());

        createdId = response.getBody().getId();
    }

    @Test
    @Order(2)
    void test02_getAllPlaceItems() {
        ResponseEntity<PlaceItemResponse[]> response = restTemplate.getForEntity(
                BASE_URL, PlaceItemResponse[].class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().length >= 1);
    }

    @Test
    @Order(3)
    void test03_getPlaceItemById() {
        ResponseEntity<PlaceItemResponse> response = restTemplate.getForEntity(
                BASE_URL + "/" + createdId, PlaceItemResponse.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(createdId, response.getBody().getId());
        assertEquals("Main Office", response.getBody().getPlaceName());
    }

    @Test
    @Order(4)
    void test04_updatePlaceItem() {
        PlaceItemRequest request = PlaceItemRequest.builder()
                .placeName("Branch Office")
                .build();

        HttpEntity<PlaceItemRequest> entity = new HttpEntity<>(request);
        ResponseEntity<PlaceItemResponse> response = restTemplate.exchange(
                BASE_URL + "/" + createdId, HttpMethod.PUT, entity, PlaceItemResponse.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("Branch Office", response.getBody().getPlaceName());
    }

    @Test
    @Order(5)
    void test05_getByPlaceName() {
        ResponseEntity<PlaceItemResponse[]> response = restTemplate.getForEntity(
                BASE_URL + "/place/Branch Office", PlaceItemResponse[].class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().length >= 1);
        assertEquals("Branch Office", response.getBody()[0].getPlaceName());
    }

    @Test
    @Order(6)
    void test06_deletePlaceItem() {
        ResponseEntity<MessageResponse> response = restTemplate.exchange(
                BASE_URL + "/" + createdId, HttpMethod.DELETE, null, MessageResponse.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("Place item deleted successfully!", response.getBody().getMessage());
    }

    @Test
    @Order(7)
    void test07_getDeletedPlaceItemReturnsNotFound() {
        ResponseEntity<Object> response = restTemplate.getForEntity(
                BASE_URL + "/" + createdId, Object.class);

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
    }
}

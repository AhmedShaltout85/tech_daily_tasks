package com.a08r.tasks_emp_complaint;

import com.a08r.tasks_emp_complaint.dto.AboutAppRequest;
import com.a08r.tasks_emp_complaint.dto.AboutAppResponse;
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
class AboutAppIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    private static final String BASE_URL = "/api/about-apps";
    private static Long createdId;

    @Test
    @Order(1)
    void test01_createAboutApp() {
        AboutAppRequest request = AboutAppRequest.builder()
                .appName("SAP")
                .recommended("Yes")
                .department("IT Department")
                .build();

        ResponseEntity<AboutAppResponse> response = restTemplate.postForEntity(
                BASE_URL, request, AboutAppResponse.class);

        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        assertNotNull(response.getBody());
        assertNotNull(response.getBody().getId());
        assertEquals("SAP", response.getBody().getAppName());
        assertEquals("Yes", response.getBody().getRecommended());
        assertEquals("IT Department", response.getBody().getDepartment());

        createdId = response.getBody().getId();
    }

    @Test
    @Order(2)
    void test02_getAllAboutApps() {
        ResponseEntity<AboutAppResponse[]> response = restTemplate.getForEntity(
                BASE_URL, AboutAppResponse[].class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().length >= 1);
    }

    @Test
    @Order(3)
    void test03_getAboutAppById() {
        ResponseEntity<AboutAppResponse> response = restTemplate.getForEntity(
                BASE_URL + "/" + createdId, AboutAppResponse.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(createdId, response.getBody().getId());
        assertEquals("SAP", response.getBody().getAppName());
    }

    @Test
    @Order(4)
    void test04_updateAboutApp() {
        AboutAppRequest request = AboutAppRequest.builder()
                .appName("Oracle")
                .recommended("No")
                .department("Finance Department")
                .build();

        HttpEntity<AboutAppRequest> entity = new HttpEntity<>(request);
        ResponseEntity<AboutAppResponse> response = restTemplate.exchange(
                BASE_URL + "/" + createdId, HttpMethod.PUT, entity, AboutAppResponse.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("Oracle", response.getBody().getAppName());
        assertEquals("No", response.getBody().getRecommended());
        assertEquals("Finance Department", response.getBody().getDepartment());
    }

    @Test
    @Order(5)
    void test05_getByAppName() {
        ResponseEntity<AboutAppResponse[]> response = restTemplate.getForEntity(
                BASE_URL + "/app/Oracle", AboutAppResponse[].class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().length >= 1);
        assertEquals("Oracle", response.getBody()[0].getAppName());
    }

    @Test
    @Order(6)
    void test06_getByDepartment() {
        ResponseEntity<AboutAppResponse[]> response = restTemplate.getForEntity(
                BASE_URL + "/department/Finance Department", AboutAppResponse[].class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().length >= 1);
        assertEquals("Finance Department", response.getBody()[0].getDepartment());
    }

    @Test
    @Order(7)
    void test07_deleteAboutApp() {
        ResponseEntity<MessageResponse> response = restTemplate.exchange(
                BASE_URL + "/" + createdId, HttpMethod.DELETE, null, MessageResponse.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("About app deleted successfully!", response.getBody().getMessage());
    }

    @Test
    @Order(8)
    void test08_getDeletedAboutAppReturnsNotFound() {
        ResponseEntity<Object> response = restTemplate.getForEntity(
                BASE_URL + "/" + createdId, Object.class);

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
    }
}

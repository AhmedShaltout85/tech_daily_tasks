package com.a08r.tasks_emp_complaint;

import com.a08r.tasks_emp_complaint.dto.MessageResponse;
import com.a08r.tasks_emp_complaint.dto.TaskEmpComplaintRequest;
import com.a08r.tasks_emp_complaint.dto.TaskEmpComplaintResponse;
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
class TaskEmpComplaintIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    private static final String BASE_URL = "/api/emp-complaints";
    private static Long createdId;

    @Test
    @Order(1)
    void test01_createComplaint() {
        TaskEmpComplaintRequest request = TaskEmpComplaintRequest.builder()
                .appName("TestApp")
                .complaintName("Test Complaint")
                .placeName("Test Place")
                .department("Test Department")
                .subPlace("Test Sub Place")
                .empName("John Doe")
                .empNumber("12345")
                .empMobile("987654321")
                .isEnable(true)
                .build();

        ResponseEntity<TaskEmpComplaintResponse> response = restTemplate.postForEntity(
                BASE_URL, request, TaskEmpComplaintResponse.class);

        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        assertNotNull(response.getBody());
        assertNotNull(response.getBody().getId());
        assertEquals("TestApp", response.getBody().getAppName());
        assertEquals("Test Complaint", response.getBody().getComplaintName());
        assertEquals("John Doe", response.getBody().getEmpName());
        assertEquals("12345", response.getBody().getEmpNumber());

        createdId = response.getBody().getId();
    }

    @Test
    @Order(2)
    void test02_getAllComplaints() {
        ResponseEntity<TaskEmpComplaintResponse[]> response = restTemplate.getForEntity(
                BASE_URL, TaskEmpComplaintResponse[].class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().length >= 1);
    }

    @Test
    @Order(3)
    void test03_getComplaintById() {
        ResponseEntity<TaskEmpComplaintResponse> response = restTemplate.getForEntity(
                BASE_URL + "/" + createdId, TaskEmpComplaintResponse.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(createdId, response.getBody().getId());
        assertEquals("TestApp", response.getBody().getAppName());
    }

    @Test
    @Order(4)
    void test04_updateComplaint() {
        TaskEmpComplaintRequest request = TaskEmpComplaintRequest.builder()
                .appName("UpdatedApp")
                .complaintName("Updated Complaint")
                .placeName("Updated Place")
                .department("Updated Department")
                .subPlace("Updated Sub Place")
                .empName("Jane Doe")
                .empNumber("67890")
                .empMobile("123456789")
                .isEnable(false)
                .build();

        HttpEntity<TaskEmpComplaintRequest> entity = new HttpEntity<>(request);
        ResponseEntity<TaskEmpComplaintResponse> response = restTemplate.exchange(
                BASE_URL + "/" + createdId, HttpMethod.PUT, entity, TaskEmpComplaintResponse.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("UpdatedApp", response.getBody().getAppName());
        assertEquals("Updated Complaint", response.getBody().getComplaintName());
        assertEquals("Jane Doe", response.getBody().getEmpName());
        assertEquals("67890", response.getBody().getEmpNumber());
        assertFalse(response.getBody().getIsEnable());
    }

    @Test
    @Order(5)
    void test05_getByAppName() {
        ResponseEntity<TaskEmpComplaintResponse[]> response = restTemplate.getForEntity(
                BASE_URL + "/app/UpdatedApp", TaskEmpComplaintResponse[].class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().length >= 1);
        assertEquals("UpdatedApp", response.getBody()[0].getAppName());
    }

    @Test
    @Order(6)
    void test06_getByDepartment() {
        ResponseEntity<TaskEmpComplaintResponse[]> response = restTemplate.getForEntity(
                BASE_URL + "/department/Updated Department", TaskEmpComplaintResponse[].class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().length >= 1);
        assertEquals("Updated Department", response.getBody()[0].getDepartment());
    }

    @Test
    @Order(7)
    void test07_deleteComplaint() {
        ResponseEntity<MessageResponse> response = restTemplate.exchange(
                BASE_URL + "/" + createdId, HttpMethod.DELETE, null, MessageResponse.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("Employee complaint deleted successfully!", response.getBody().getMessage());
    }

    @Test
    @Order(8)
    void test08_getDeletedComplaintReturnsNotFound() {
        ResponseEntity<Object> response = restTemplate.getForEntity(
                BASE_URL + "/" + createdId, Object.class);

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
    }
}

package com.a08r.tasks_emp_complaint;

import com.a08r.tasks_emp_complaint.dto.RetrieveEmpDataRequest;
import com.a08r.tasks_emp_complaint.dto.RetrieveEmpDataResponse;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class RetrieveEmpDataIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    private static final String BASE_URL = "/api/retrieve-emp-data";
    private static Integer createdId;

    @Test
    @Order(1)
    void test01_createItem() {
        RetrieveEmpDataRequest request = RetrieveEmpDataRequest.builder()
                .empId(1001)
                .empName("أحمد محمد")
                .empType("permanent")
                .empJob("Engineer")
                .empDegree("Senior")
                .empLocation("Cairo")
                .empDept("IT")
                .empAdmin("Admin1")
                .empSector("Sector1")
                .build();

        ResponseEntity<RetrieveEmpDataResponse> response = restTemplate.postForEntity(
                BASE_URL, request, RetrieveEmpDataResponse.class);

        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        assertNotNull(response.getBody());
        assertNotNull(response.getBody().getId());
        assertEquals(1001, response.getBody().getEmpId());
        assertEquals("أحمد محمد", response.getBody().getEmpName());
        createdId = response.getBody().getId();
    }

    @Test
    @Order(2)
    void test02_getAllItems() {
        ResponseEntity<RetrieveEmpDataResponse[]> response = restTemplate.getForEntity(
                BASE_URL, RetrieveEmpDataResponse[].class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().length > 0);
    }

    @Test
    @Order(3)
    void test03_getItemById() {
        ResponseEntity<RetrieveEmpDataResponse> response = restTemplate.getForEntity(
                BASE_URL + "/" + createdId, RetrieveEmpDataResponse.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(createdId, response.getBody().getId());
        assertEquals(1001, response.getBody().getEmpId());
    }

    @Test
    @Order(4)
    void test04_updateItem() {
        RetrieveEmpDataRequest request = RetrieveEmpDataRequest.builder()
                .empId(1001)
                .empName("أحمد محمد (محدث)")
                .empType("permanent")
                .empJob("Senior Engineer")
                .empDegree("Lead")
                .empLocation("Alexandria")
                .empDept("IT")
                .empAdmin("Admin2")
                .empSector("Sector2")
                .build();

        restTemplate.put(BASE_URL + "/" + createdId, request);

        ResponseEntity<RetrieveEmpDataResponse> response = restTemplate.getForEntity(
                BASE_URL + "/" + createdId, RetrieveEmpDataResponse.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("أحمد محمد (محدث)", response.getBody().getEmpName());
        assertEquals("Alexandria", response.getBody().getEmpLocation());
    }

    @Test
    @Order(5)
    void test05_getByEmpId() {
        ResponseEntity<RetrieveEmpDataResponse[]> response = restTemplate.getForEntity(
                BASE_URL + "/emp-id/1001", RetrieveEmpDataResponse[].class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().length > 0);
        assertEquals(1001, response.getBody()[0].getEmpId());
    }

    @Test
    @Order(6)
    void test06_getByEmpDept() {
        ResponseEntity<RetrieveEmpDataResponse[]> response = restTemplate.getForEntity(
                BASE_URL + "/emp-dept/IT", RetrieveEmpDataResponse[].class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().length > 0);
    }

    @Test
    @Order(7)
    void test07_getByEmpLocation() {
        ResponseEntity<RetrieveEmpDataResponse[]> response = restTemplate.getForEntity(
                BASE_URL + "/emp-location/Alexandria", RetrieveEmpDataResponse[].class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().length > 0);
    }

    @Test
    @Order(8)
    void test08_getByEmpIdAndEmpDept() {
        ResponseEntity<RetrieveEmpDataResponse[]> response = restTemplate.getForEntity(
                BASE_URL + "/emp-id/1001/emp-dept/IT", RetrieveEmpDataResponse[].class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().length > 0);
    }

    @Test
    @Order(9)
    void test09_getByEmpDeptAndEmpLocation() {
        ResponseEntity<RetrieveEmpDataResponse[]> response = restTemplate.getForEntity(
                BASE_URL + "/emp-dept/IT/emp-location/Alexandria", RetrieveEmpDataResponse[].class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().length > 0);
    }

    @Test
    @Order(10)
    void test10_deleteItem() {
        ResponseEntity<Void> response = restTemplate.exchange(
                BASE_URL + "/" + createdId,
                org.springframework.http.HttpMethod.DELETE,
                null,
                Void.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
    }

    @Test
    @Order(11)
    void test11_getDeletedItemReturnsNotFound() {
        ResponseEntity<RetrieveEmpDataResponse> response = restTemplate.getForEntity(
                BASE_URL + "/" + createdId, RetrieveEmpDataResponse.class);

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
    }
}

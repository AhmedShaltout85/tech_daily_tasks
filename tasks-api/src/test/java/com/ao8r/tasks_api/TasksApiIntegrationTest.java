package com.ao8r.tasks_api;

import com.ao8r.tasks_api.dto.JwtResponse;
import com.ao8r.tasks_api.dto.MessageResponse;
import com.ao8r.tasks_api.dto.RefreshTokenRequest;
import com.ao8r.tasks_api.dto.SigninRequest;
import com.ao8r.tasks_api.dto.SignupRequest;
import com.ao8r.tasks_api.dto.TokenRefreshResponse;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.*;
import org.springframework.test.context.ActiveProfiles;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@ActiveProfiles("test")
class TasksApiIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    private static String adminToken;
    private static String adminRefreshToken;
    private static String userToken;
    private static String userRefreshToken;

    private HttpHeaders getHeaders(String token) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        if (token != null) {
            headers.set("Authorization", "Bearer " + token);
        }
        return headers;
    }

    @Test
    @Order(1)
    void test01_signup_new_user() {
        SignupRequest signupRequest = new SignupRequest();
        signupRequest.setDisplayName("New Test User");
        signupRequest.setUsername("newuser");
        signupRequest.setPassword("password123");
        signupRequest.setRole("USER");
        signupRequest.setDepartment("IT");

        HttpEntity<SignupRequest> request = new HttpEntity<>(signupRequest, getHeaders(null));
        ResponseEntity<MessageResponse> response = restTemplate.postForEntity(
                "/api/auth/signup", request, MessageResponse.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("User registered successfully!", response.getBody().getMessage());
    }

    @Test
    @Order(2)
    void test02_signup_duplicate_username() {
        SignupRequest signupRequest = new SignupRequest();
        signupRequest.setDisplayName("Duplicate User");
        signupRequest.setUsername("newuser");
        signupRequest.setPassword("password123");
        signupRequest.setRole("USER");
        signupRequest.setDepartment("IT");

        HttpEntity<SignupRequest> request = new HttpEntity<>(signupRequest, getHeaders(null));
        ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/auth/signup", request, Map.class);

        System.out.println("Response status: " + response.getStatusCode());
        System.out.println("Response body: " + response.getBody());

        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().containsKey("error"));
    }

    @Test
    @Order(3)
    void test03_signin_admin() {
        SigninRequest signinRequest = new SigninRequest();
        signinRequest.setUsername("admin");
        signinRequest.setPassword("test123");

        HttpEntity<SigninRequest> request = new HttpEntity<>(signinRequest, getHeaders(null));
        ResponseEntity<JwtResponse> response = restTemplate.postForEntity(
                "/api/auth/signin", request, JwtResponse.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertNotNull(response.getBody().getToken());
        assertNotNull(response.getBody().getRefreshToken());
        assertEquals("Bearer", response.getBody().getType());
        assertEquals("admin", response.getBody().getUsername());
        assertEquals("ADMIN", response.getBody().getRole());

        adminToken = response.getBody().getToken();
        adminRefreshToken = response.getBody().getRefreshToken();
    }

    @Test
    @Order(4)
    void test04_signin_regular_user() {
        SigninRequest signinRequest = new SigninRequest();
        signinRequest.setUsername("user");
        signinRequest.setPassword("test123");

        HttpEntity<SigninRequest> request = new HttpEntity<>(signinRequest, getHeaders(null));
        ResponseEntity<JwtResponse> response = restTemplate.postForEntity(
                "/api/auth/signin", request, JwtResponse.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertNotNull(response.getBody().getToken());
        assertNotNull(response.getBody().getRefreshToken());
        assertEquals("user", response.getBody().getUsername());
        assertEquals("USER", response.getBody().getRole());

        userToken = response.getBody().getToken();
        userRefreshToken = response.getBody().getRefreshToken();
    }

    @Test
    @Order(5)
    void test05_signin_invalid_credentials() {
        SigninRequest signinRequest = new SigninRequest();
        signinRequest.setUsername("admin");
        signinRequest.setPassword("wrongpassword");

        HttpEntity<SigninRequest> request = new HttpEntity<>(signinRequest, getHeaders(null));
        try {
            restTemplate.exchange("/api/auth/signin", HttpMethod.POST, request, Map.class);
        } catch (Exception e) {
            assertTrue(true);
            return;
        }
        fail("Expected exception for invalid credentials");
    }

    @Test
    @Order(6)
    void test06_public_endpoint_no_auth() {
        HttpEntity<?> request = new HttpEntity<>(getHeaders(null));
        ResponseEntity<Map> response = restTemplate.exchange(
                "/api/test/public", HttpMethod.GET, request, Map.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("Public content", response.getBody().get("message"));
    }

    @Test
    @Order(7)
    void test07_user_endpoint_with_user_token() {
        HttpEntity<?> request = new HttpEntity<>(getHeaders(userToken));
        ResponseEntity<Map> response = restTemplate.exchange(
                "/api/test/user", HttpMethod.GET, request, Map.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("User content", response.getBody().get("message"));
    }

    @Test
    @Order(8)
    void test09_admin_endpoint_with_user_token() {
        HttpEntity<?> request = new HttpEntity<>(getHeaders(userToken));
        ResponseEntity<Map> response = restTemplate.exchange(
                "/api/test/admin", HttpMethod.GET, request, Map.class);

        assertEquals(HttpStatus.UNAUTHORIZED, response.getStatusCode()); // [2026-06-07] Updated: SecurityConfig now returns 401 instead of 403
    }

    @Test
    @Order(9)
    void test10_admin_endpoint_with_admin_token() {
        HttpEntity<?> request = new HttpEntity<>(getHeaders(adminToken));
        ResponseEntity<Map> response = restTemplate.exchange(
                "/api/test/admin", HttpMethod.GET, request, Map.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("Admin content", response.getBody().get("message"));
    }

    @Test
    @Order(10)
    void test11_validation_error_empty_username() {
        SignupRequest signupRequest = new SignupRequest();
        signupRequest.setDisplayName("Test");
        signupRequest.setUsername("");
        signupRequest.setPassword("password123");

        HttpEntity<SignupRequest> request = new HttpEntity<>(signupRequest, getHeaders(null));
        ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/auth/signup", request, Map.class);

        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().containsKey("validationErrors"));
    }

    @Test
    @Order(11)
    void test12_validation_error_short_password() {
        SignupRequest signupRequest = new SignupRequest();
        signupRequest.setDisplayName("Test");
        signupRequest.setUsername("testuser2");
        signupRequest.setPassword("123");

        HttpEntity<SignupRequest> request = new HttpEntity<>(signupRequest, getHeaders(null));
        ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/auth/signup", request, Map.class);

        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().containsKey("validationErrors"));
    }

    @Test
    @Order(12)
    void test13_refresh_token_valid() {
        RefreshTokenRequest refreshRequest = new RefreshTokenRequest();
        refreshRequest.setRefreshToken(adminRefreshToken);

        HttpEntity<RefreshTokenRequest> request = new HttpEntity<>(refreshRequest, getHeaders(null));
        ResponseEntity<TokenRefreshResponse> response = restTemplate.postForEntity(
                "/api/auth/refresh-token", request, TokenRefreshResponse.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertNotNull(response.getBody().getAccessToken());
        assertEquals("Bearer", response.getBody().getTokenType());
        assertEquals(adminRefreshToken, response.getBody().getRefreshToken());

        String newAccessToken = response.getBody().getAccessToken();
        HttpEntity<?> protectedRequest = new HttpEntity<>(getHeaders(newAccessToken));
        ResponseEntity<Map> protectedResponse = restTemplate.exchange(
                "/api/test/admin", HttpMethod.GET, protectedRequest, Map.class);

        assertEquals(HttpStatus.OK, protectedResponse.getStatusCode());
    }

    @Test
    @Order(13)
    void test14_refresh_token_invalid() {
        RefreshTokenRequest refreshRequest = new RefreshTokenRequest();
        refreshRequest.setRefreshToken("invalid-refresh-token-uuid");

        HttpEntity<RefreshTokenRequest> request = new HttpEntity<>(refreshRequest, getHeaders(null));
        ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/auth/refresh-token", request, Map.class);

        assertEquals(HttpStatus.UNAUTHORIZED, response.getStatusCode());
    }

    @Test
    @Order(14)
    void test15_signout_with_refresh_token() {
        SigninRequest signinRequest = new SigninRequest();
        signinRequest.setUsername("user");
        signinRequest.setPassword("test123");

        HttpEntity<SigninRequest> signinHttpEntity = new HttpEntity<>(signinRequest, getHeaders(null));
        ResponseEntity<JwtResponse> signinResponse = restTemplate.postForEntity(
                "/api/auth/signin", signinHttpEntity, JwtResponse.class);

        String freshRefreshToken = signinResponse.getBody().getRefreshToken();

        RefreshTokenRequest signoutRequest = new RefreshTokenRequest();
        signoutRequest.setRefreshToken(freshRefreshToken);

        HttpEntity<RefreshTokenRequest> request = new HttpEntity<>(signoutRequest, getHeaders(null));
        ResponseEntity<MessageResponse> response = restTemplate.postForEntity(
                "/api/auth/signout", request, MessageResponse.class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("User signed out successfully!", response.getBody().getMessage());

        RefreshTokenRequest refreshRequest = new RefreshTokenRequest();
        refreshRequest.setRefreshToken(freshRefreshToken);

        HttpEntity<RefreshTokenRequest> refreshHttpEntity = new HttpEntity<>(refreshRequest, getHeaders(null));
        ResponseEntity<Map> refreshResponse = restTemplate.postForEntity(
                "/api/auth/refresh-token", refreshHttpEntity, Map.class);

        assertEquals(HttpStatus.UNAUTHORIZED, refreshResponse.getStatusCode());
    }
}

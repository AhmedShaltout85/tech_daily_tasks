# Plan: Add Refresh Token to tasks-api

## Overview

Add refresh token support to the tasks-api project. Currently, a single JWT access token (30-day expiry) is issued on sign-in. The new flow will issue a short-lived access token (24 hours) plus a long-lived refresh token (7 days). The refresh token enables the client to obtain a new access token without re-authenticating.

### Decisions
- **Access token expiry**: 24 hours (86,400,000 ms) — shortened from 30 days
- **Refresh token expiry**: 7 days (604,800,000 ms)
- **Storage**: In-memory (`ConcurrentHashMap`) — no database changes
- **Token rotation**: No — same refresh token reused until expiry
- **Refresh token format**: UUID v4 string (not a JWT)

---

## New API Endpoint

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/auth/refresh-token` | Exchange valid refresh token for new access token | No |

**Request body:**
```json
{
  "refreshToken": "uuid-string"
}
```

**Response (200 OK):**
```json
{
  "accessToken": "new-jwt-token",
  "tokenType": "Bearer",
  "refreshToken": "same-uuid-string"
}
```

**Error Response (401 Unauthorized):**
```json
{
  "error": "Refresh token is invalid or expired"
}
```

### Updated Sign-In Response

The `/api/auth/signin` response (`JwtResponse`) will now include a `refreshToken` field:
```json
{
  "token": "jwt-access-token",
  "type": "Bearer",
  "refreshToken": "uuid-string",
  "id": 1,
  "username": "admin",
  "displayName": "Admin User",
  "role": "ADMIN",
  "department": "IT"
}
```

### Updated Sign-Out

`/api/auth/signout` will also invalidate the user's refresh tokens (passed in request body or via authenticated user).

---

## Files to Create (4 new files)

### 1. `RefreshTokenRequest.java` (DTO)
**Path**: `src/main/java/com/ao8r/tasks_api/dto/RefreshTokenRequest.java`

Simple DTO with a single `@NotBlank` field `refreshToken`.

```java
package com.ao8r.tasks_api.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class RefreshTokenRequest {

    @NotBlank(message = "Refresh token is required")
    private String refreshToken;
}
```

### 2. `TokenRefreshResponse.java` (DTO)
**Path**: `src/main/java/com/ao8r/tasks_api/dto/TokenRefreshResponse.java`

Response DTO with fields: `accessToken`, `tokenType`, `refreshToken`. Uses `@Data`, `@Builder`, `@NoArgsConstructor`, `@AllArgsConstructor`.

```java
package com.ao8r.tasks_api.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TokenRefreshResponse {

    private String accessToken;
    private String tokenType = "Bearer";
    private String refreshToken;
}
```

### 3. `RefreshTokenService.java` (Service)
**Path**: `src/main/java/com/ao8r/tasks_api/service/RefreshTokenService.java`

In-memory service using `ConcurrentHashMap` to store and validate refresh tokens.

**Internal data structure:**
- `ConcurrentHashMap<String, RefreshTokenEntry>` — key: UUID token string, value: inner record with `username` and `expiresAt`
- `ConcurrentHashMap<String, Set<String>>` — reverse index: username → set of token strings (for signout cleanup)

**Methods:**
- `createRefreshToken(String username) → String` — generates UUID, stores with 7-day expiry, returns UUID string
- `validateRefreshToken(String token) → boolean` — checks existence and expiry
- `getUsernameFromRefreshToken(String token) → String` — returns username if valid
- `revokeRefreshToken(String token)` — removes single token from both maps
- `revokeAllRefreshTokensForUser(String username)` — removes all tokens for a user (used on signout)

### 4. `RefreshTokenException.java` (Exception)
**Path**: `src/main/java/com/ao8r/tasks_api/exception/RefreshTokenException.java`

Simple custom exception extending `RuntimeException` with a message constructor.

```java
package com.ao8r.tasks_api.exception;

public class RefreshTokenException extends RuntimeException {

    public RefreshTokenException(String message) {
        super(message);
    }
}
```

---

## Files to Modify (6 existing files)

### 5. `JwtResponse.java` (DTO)
**Path**: `src/main/java/com/ao8r/tasks_api/dto/JwtResponse.java`

**Changes:**
- Add field: `private String refreshToken;`
- `@Builder` and `@Data` already handle new fields automatically

### 6. `AuthController.java`
**Path**: `src/main/java/com/ao8r/tasks_api/controller/auth/AuthController.java`

**Changes:**
- Inject `RefreshTokenService`
- **`authenticateUser` (POST /signin)**: After generating JWT, also call `refreshTokenService.createRefreshToken(username)` and include it in `JwtResponse`
- **`refreshToken` (POST /refresh-token)**: New endpoint — validate refresh token via service, look up username, load `UserDetails` from `UserDetailsService`, generate new JWT via `jwtUtils.generateTokenFromUsername(userDetails)`, return `TokenRefreshResponse` with same refresh token
- **`signoutUser` (POST /signout)**: Get authenticated username from `SecurityContextHolder`, call `refreshTokenService.revokeAllRefreshTokensForUser(username)`, then clear context

### 7. `SecurityConfig.java`
**Path**: `src/main/java/com/ao8r/tasks_api/config/security/SecurityConfig.java`

**Changes:** None — `/api/auth/refresh-token` is already covered by the `/api/auth/**` permitAll matcher. Verify only.

### 8. `GlobalExceptionHandler.java`
**Path**: `src/main/java/com/ao8r/tasks_api/exception/GlobalExceptionHandler.java`

**Changes:**
- Add handler for `RefreshTokenException` — returns `401 Unauthorized` with body `{"error": "Refresh token is invalid or expired"}`

### 9. `application.properties`
**Path**: `src/main/resources/application.properties`

**Changes:**
- Update: `jwt.expiration.ms=86400000` (24 hours instead of 30 days / 2592000000)
- Add: `jwt.refresh-token.expiration.ms=604800000` (7 days)

### 10. `TasksApiIntegrationTest.java`
**Path**: `src/test/java/com/ao8r/tasks_api/TasksApiIntegrationTest.java`

**Changes:**
- Update `test03_signin_admin` and `test04_signin_regular_user` to verify `refreshToken` field is present in response
- Add new test: `test_refresh_token_valid` — sign in → get refresh token → POST `/api/auth/refresh-token` → verify new access token returned with same refresh token
- Add new test: `test_refresh_token_invalid` — POST `/api/auth/refresh-token` with invalid UUID string → expect 401

---

## Implementation Order

| Step | Action | File |
|------|--------|------|
| 1 | Create `RefreshTokenException` | `exception/RefreshTokenException.java` |
| 2 | Create `RefreshTokenRequest` DTO | `dto/RefreshTokenRequest.java` |
| 3 | Create `TokenRefreshResponse` DTO | `dto/TokenRefreshResponse.java` |
| 4 | Add `refreshToken` field to `JwtResponse` | `dto/JwtResponse.java` |
| 5 | Create `RefreshTokenService` | `service/RefreshTokenService.java` |
| 6 | Update `application.properties` | `resources/application.properties` |
| 7 | Update `JwtUtils` (verify property is used) | `security/jwt/JwtUtils.java` |
| 8 | Update `AuthController` (signin, new endpoint, signout) | `controller/auth/AuthController.java` |
| 9 | Add `RefreshTokenException` handler to `GlobalExceptionHandler` | `exception/GlobalExceptionHandler.java` |
| 10 | Update tests | `TasksApiIntegrationTest.java` |
| 11 | Build: `mvn clean install -DskipTests` | — |
| 12 | Test: `mvn test` | — |

---

## Security Considerations

- Refresh tokens are stored in-memory only — they are lost on server restart (all users must re-login)
- Refresh tokens are UUIDs, not JWTs — no secret signing needed, just random uniqueness
- Sign-out revokes refresh tokens to prevent post-logout use
- The `/api/auth/refresh-token` endpoint requires no auth (the refresh token itself is the credential)
- Access token shortened to 24 hours improves security over the current 30-day token
- No refresh token rotation — same token reused until 7-day expiry (simpler implementation)

---

## Risk Assessment

- **Breaking change**: Access token shortened from 30 days to 24 hours. Clients that don't implement refresh flow will need to re-login daily. Android app must be updated to handle refresh token flow.
- **Server restart**: All in-memory refresh tokens are lost. Users will need to re-login after server restart. This is acceptable for a development/small deployment scenario.
- **No database migration**: All changes are code-only, no schema changes needed.

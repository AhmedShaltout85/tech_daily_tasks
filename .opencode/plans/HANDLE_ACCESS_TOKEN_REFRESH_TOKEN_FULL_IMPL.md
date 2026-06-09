# Full Implementation: Access Token + Refresh Token Flow

## Overview

Complete implementation of JWT access token (24h) + refresh token (7d) flow across the **Spring Boot backend** and **Flutter mobile app**. Includes the 403→401 fix for expired token handling.

---

## Architecture

```
Login
  → Server returns { accessToken, refreshToken, user }
  → Both tokens stored in SharedPreferences

API Request
  → DioClient attaches Bearer <accessToken> to header
  → If 401/403 received (token expired):
      → DioClient interceptor catches it
      → Calls POST /auth/refresh-token with refreshToken
      → On success: updates tokens, retries original request
      → On failure: clears tokens, redirects to login

Logout
  → Sends refreshToken to POST /auth/signout for server-side revocation
  → Clears all local state
```

---

## Backend (Spring Boot - tasks-api)

### Files Created

| File | Purpose |
|------|---------|
| `RefreshTokenException.java` | Custom exception for refresh token errors |
| `RefreshTokenRequest.java` | DTO with `refreshToken` field |
| `TokenRefreshResponse.java` | DTO with `accessToken`, `tokenType`, `refreshToken` |
| `RefreshTokenService.java` | In-memory ConcurrentHashMap store, UUID v4 tokens, 7-day expiry |

### Files Modified

| File | Changes |
|------|---------|
| `JwtResponse.java` | Added `refreshToken` field |
| `AuthController.java` | Updated `signin` to return refresh token; added `POST /auth/refresh-token`; updated `signout` to revoke tokens |
| `GlobalExceptionHandler.java` | Added `RefreshTokenException` handler (401) |
| `SecurityConfig.java` | Added custom `AuthenticationEntryPoint` returning 401 instead of default 403 |
| `application.properties` | `jwt.expiration.ms=86400000` (24h), `jwt.refresh-token.expiration.ms=604800000` (7d) |
| `TasksApiIntegrationTest.java` | Updated test to expect 401 instead of 403 |

### SecurityConfig Key Change

```java
.exceptionHandling(ex -> ex
    .authenticationEntryPoint((request, response, authException) -> {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json");
        response.getWriter().write("{\"error\": \"Unauthorized\"}");
    })
)
```

### API Endpoints

| Method | Endpoint | Auth | Body | Response |
|--------|----------|------|------|----------|
| POST | `/api/auth/signin` | No | `{username, password}` | `{token, refreshToken, id, username, ...}` |
| POST | `/api/auth/refresh-token` | No | `{refreshToken}` | `{accessToken, tokenType, refreshToken}` |
| POST | `/api/auth/signout` | Yes | `{refreshToken}` | `{message}` |

---

## Flutter (tasks_app)

### Files Modified (5 files)

#### 1. `lib/models/user_model.dart`
- Added `refreshToken` field
- Updated `fromJson`, `toJson`, `copyWith`

#### 2. `lib/newtork_repos/remote_repo/api_repos/api_network_user_repos.dart`
- Added `Future<Map<String, dynamic>> refreshToken({required String refreshToken})`
- Updated `signOut({String? refreshToken})`

#### 3. `lib/newtork_repos/remote_repo/api_repos/api_network_user_repos_impl.dart`
- Implemented `refreshToken()`: POST `/auth/refresh-token`
- Updated `signOut()`: sends refresh token for revocation

#### 4. `lib/newtork_repos/remote_repo/api_repos/dio_client.dart`
- Added `_refreshToken` field + getter/setter
- Added `_isRefreshing` flag + `Queue<_PendingRequest>` for concurrency
- Added `onTokensRefreshed` and `onSessionExpired` callbacks
- `onRequest`: Skips Bearer token for auth endpoints
- `onError`: Catches **401 or 403** → calls `_handleTokenRefresh()`
- `_handleTokenRefresh()`: POST `/auth/refresh-token`, retry on success, session expired on failure

#### 5. `lib/controller/user_provider.dart`
- Added `_refreshToken` field
- Loads/saves/clears `refresh_token` in SharedPreferences
- Registers DioClient callbacks (`onTokensRefreshed`, `onSessionExpired`)
- Updated `signIn()`: extracts both tokens from response
- Updated `signOut()`: sends refresh token to server, clears local state
- Added `updateTokens()`: called by DioClient after successful refresh

#### 6. `lib/screens/settings/settings_screen.dart`
- Changed logout to use `signOut()` instead of `clearUserData()`

---

## Cache Keys (SharedPreferences)

| Key | Value | Type |
|-----|-------|------|
| `auth_token` | Access token (24h) | String |
| `refresh_token` | Refresh token (7d) | String |
| `current_user` | User JSON | String |

---

## DioClient Interceptor Flow

```
onRequest:
  +-- Is auth endpoint? -> Skip Bearer token
  +-- Otherwise -> Add Bearer <accessToken>

onError (401 or 403):
  +-- Is path /auth/signin or /auth/refresh-token? -> Pass through
  +-- Is _isRefreshing? -> Queue request, wait
  +-- Otherwise:
       +-- Set _isRefreshing = true
       +-- POST /auth/refresh-token with refreshToken
       |   +-- Success (200):
       |   |   +-- Update _token, _refreshToken
       |   |   +-- Call onTokensRefreshed callback
       |   |   +-- Retry original request
       |   |   +-- Process queued requests
       |   +-- Failure:
       |       +-- Clear tokens
       |       +-- Call onSessionExpired callback
       |       +-- Fail all queued requests
       +-- Set _isRefreshing = false
```

---

## Token Lifecycle

| Token | Lifetime | Storage | Revocation |
|-------|----------|---------|------------|
| Access token | 24 hours | SharedPreferences + DioClient memory | Expires naturally |
| Refresh token | 7 days | SharedPreferences + DioClient memory | Server-side on signout |

---

## Implementation Status

| Component | Status |
|-----------|--------|
| Backend RefreshTokenService | ✅ Complete |
| Backend AuthController endpoints | ✅ Complete |
| Backend SecurityConfig (401 fix) | ✅ Complete |
| Backend tests | ✅ 14/14 passing |
| Flutter UserModel | ✅ Complete |
| Flutter ApiNetworkUserRepos | ✅ Complete |
| Flutter ApiNetworkUserReposImpl | ✅ Complete |
| Flutter DioClient interceptor | ✅ Complete |
| Flutter UserProvider | ✅ Complete |
| Flutter Settings screen logout | ✅ Complete |
| Flutter dart analyze | ✅ No issues |

---

## Verification

1. **Backend**: `mvn test` → 14/14 tests pass
2. **Flutter**: `dart analyze` → No issues
3. **Manual test**: Login → wait 24h+ → API call should auto-refresh → Logout should revoke server-side

---

## Risk Notes

- **Server restart**: Refresh tokens are in-memory (ConcurrentHashMap). All clients must re-login after restart.
- **Concurrent requests**: Queue mechanism prevents multiple simultaneous refresh calls.
- **Infinite loop prevention**: `/auth/refresh-token` and `/auth/signin` paths excluded from 401 handling.
- **No UI changes**: All screens work as-is. Token refresh is transparent to the user.

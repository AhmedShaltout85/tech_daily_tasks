# Refresh Token Implementation — Session Compaction

## Goal

Add refresh token support to a full-stack application consisting of:
1. A **Spring Boot 3 API** (`tasks-api`) — backend
2. A **Flutter app** (`tasks_app`) — mobile frontend

## Instructions

- Save plans to files before implementing (`ADD_REFRESH_TOKEN.md`, `ADD_REFRESH_TOKEN_FLUTTER_APP.md`)
- Ask the user clarifying questions before finalizing plans
- Add `// [REFRESH_TOKEN]` comments to every updated part in Flutter files
- Backend decisions: access token = 24 hours, refresh token = 7 days, in-memory storage (ConcurrentHashMap), no token rotation, UUID v4 format for refresh token
- Flutter decisions: auto-refresh on 401 (Dio interceptor), persist refresh token in SharedPreferences, send refresh token to server on sign-out for revocation

## Discoveries

- Backend uses Spring Boot 3.3.4, jjwt 0.11.5, HS512, MSSQL database, Maven build
- Flutter uses Dio for HTTP, Provider for state management, SharedPreferences for local cache
- Flutter app has a `DioClient` singleton with interceptor pattern that was extended with 401 auto-refresh + request queue
- `flutter_native_splash` package has a pre-existing dependency conflict preventing `flutter pub get`, but `dart analyze` works fine
- All 85 pre-existing warnings/infos in the Flutter codebase are unrelated to the changes

## Accomplished

### Backend (tasks-api) — COMPLETE

**4 new files created:**
- `RefreshTokenException.java` — custom exception
- `RefreshTokenRequest.java` — DTO with `refreshToken` field
- `TokenRefreshResponse.java` — DTO with `accessToken`, `tokenType`, `refreshToken`
- `RefreshTokenService.java` — in-memory `ConcurrentHashMap` store with dual maps (token→entry, username→tokens)

**6 existing files modified:**
- `JwtResponse.java` — added `refreshToken` field
- `AuthController.java` — injected `RefreshTokenService` + `UserDetailsServiceImpl`; updated `signin` to return refresh token; added `POST /api/auth/refresh-token` endpoint; updated `signout` to revoke refresh tokens
- `GlobalExceptionHandler.java` — added `RefreshTokenException` handler (401)
- `application.properties` — changed `jwt.expiration.ms` to `86400000` (24h), added `jwt.refresh-token.expiration.ms=604800000` (7d)
- `AGENTS.md` — documented new endpoint, updated JWT guidelines, updated DTOs
- `TasksApiIntegrationTest.java` — updated existing tests to verify `refreshToken`, added 4 new tests (valid refresh, invalid refresh, signout with revocation)

**Build verified:** `mvn clean compile` and `mvn test-compile` both succeed.

### Flutter (tasks_app) — COMPLETE

**5 files modified (0 new files):**
1. `lib/models/user_model.dart` — added `refreshToken` field, updated `fromJson`/`toJson`/`copyWith`
2. `lib/newtork_repos/remote_repo/api_repos/api_network_user_repos.dart` — added `refreshToken()` abstract method, updated `signOut` signature to accept optional `refreshToken`
3. `lib/newtork_repos/remote_repo/api_repos/api_network_user_repos_impl.dart` — implemented `refreshToken()`, updated `signOut()` to send refresh token, updated `signIn()` to extract refresh token
4. `lib/newtork_repos/remote_repo/api_repos/dio_client.dart` — added `_refreshToken` field, `setRefreshToken`/`clearRefreshToken`, 401 interceptor with auto-refresh, request queue (`Queue<_PendingRequest>`), `onTokensRefreshed`/`onSessionExpired` callbacks, `_PendingRequest` helper class
5. `lib/controller/user_provider.dart` — added `_refreshToken` field, DioClient callback registration, refresh token persistence in SharedPreferences (`refresh_token` key), updated `signIn()`/`signOut()`/`clearUserData()`, added `updateTokens()` method

**Analyzed:** `dart analyze` on all 5 files — zero issues.

**All `// [REFRESH_TOKEN]` comments added** to every updated part across all 5 Flutter files.

## What's left

- The plan files were saved to `.opencode/plans/` directory (not root) due to file write permissions. The user originally asked for them at root `ADD_REFRESH_TOKEN.md` and `ADD_REFRESH_TOKEN_FLUTTER_APP.md`
- Backend `mvn test` was not run (requires MSSQL database connection)
- Flutter app was not fully built/run (pre-existing `flutter_native_splash` dependency conflict)

## Relevant files / directories

### Backend (`tasks-api/`)
```
tasks-api/
├── src/main/java/com/ao8r/tasks_api/
│   ├── controller/auth/AuthController.java          (modified)
│   ├── dto/JwtResponse.java                         (modified)
│   ├── dto/RefreshTokenRequest.java                  (created)
│   ├── dto/TokenRefreshResponse.java                 (created)
│   ├── entity/User.java                              (read-only)
│   ├── entity/Role.java                              (read-only)
│   ├── exception/GlobalExceptionHandler.java         (modified)
│   ├── exception/RefreshTokenException.java           (created)
│   ├── repository/UserRepository.java                (read-only)
│   ├── security/jwt/JwtUtils.java                    (read-only)
│   ├── security/jwt/AuthTokenFilter.java             (read-only)
│   ├── security/services/UserDetailsImpl.java        (read-only)
│   ├── security/services/UserDetailsServiceImpl.java (read-only)
│   ├── config/security/SecurityConfig.java           (read-only)
│   ├── service/UserService.java                      (read-only)
│   ├── service/UserServiceImpl.java                  (read-only)
│   └── service/RefreshTokenService.java               (created)
├── src/main/resources/application.properties          (modified)
├── src/test/java/.../TasksApiIntegrationTest.java     (modified)
├── AGENTS.md                                          (modified)
└── .opencode/plans/ADD_REFRESH_TOKEN.md               (plan saved here)
```

### Flutter (`tasks_app/`)
```
tasks_app/lib/
├── models/user_model.dart                                       (modified)
├── newtork_repos/remote_repo/api_repos/
│   ├── api_network_user_repos.dart                               (modified)
│   ├── api_network_user_repos_impl.dart                          (modified)
│   └── dio_client.dart                                           (modified)
├── controller/
│   ├── user_provider.dart                                        (modified)
│   └── local_control/cache_helper.dart                           (read-only)
├── screens/auth/auth_wrapper.dart                                (read-only)
├── screens/login/login_screen.dart                               (read-only)
└── .opencode/plans/ADD_REFRESH_TOKEN_FLUTTER_APP.md              (plan saved here)
```

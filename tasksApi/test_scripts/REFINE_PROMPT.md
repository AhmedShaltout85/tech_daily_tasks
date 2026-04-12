# Spring Boot 3 Tasks API with JWT Authentication & MSSQL Server

## Project Overview

Create a **production-grade Spring Boot 3** application using **Java 17** and **MSSQL Server** for a task management API (`tasks_api`) with **JWT authentication**. Follow modern best practices, clean architecture, and security standards.

---

## Project Metadata

| Property          | Value                        |
|-------------------|------------------------------|
| Project Name      | `tasks_api`                  |
| Group             | `com.ao8r`                   |
| Artifact          | `tasks_api`                  |
| Base Package      | `com.ao8r.tasks_api`         |
| Packaging         | `jar`                        |
| Java Version      | `17`                         |

---

## Required Dependencies (with versions)

| Dependency              | Purpose                          | Version (if applicable) |
|-------------------------|----------------------------------|-------------------------|
| Spring Boot Starter Web | REST APIs                        | 3.1.x                   |
| Spring Boot DevTools    | Development hot-reload           | 3.1.x                   |
| Lombok                  | Boilerplate reduction            | Latest                  |
| Spring Security         | Authentication & Authorization   | 3.1.x                   |
| Spring Data JPA         | Database access                  | 3.1.x                   |
| MSSQL JDBC Driver       | MSSQL connectivity               | 12.4.x                  |
| JJWT                    | JWT token handling               | 0.11.5                  |
| Validation API          | Request validation               | 3.0.x                   |

> **Important**: Use JJWT 0.11.5 which is compatible with Java 17. Include these three JJWT dependencies: `jjwt-api`, `jjwt-impl`, `jjwt-jackson`.

---

## Database Configuration

**File:** `src/main/resources/application.properties`

- Database name: `tech_daily_tasks`
- Use placeholders for `username` and `password` (e.g., `${DB_USERNAME}`, `${DB_PASSWORD}`)
- Enable Hibernate SQL logging for development
- Set DDL strategy to `update` (or `validate` for production reference)
- Use `UTC` timezone
- Configure HikariCP connection pool

---

## Entity: User

**Package:** `com.ao8r.tasks_api.entity`

### Fields

| Field          | Type            | Constraints                                        |
|----------------|-----------------|----------------------------------------------------|
| `id`           | `Long`          | `@Id`, `@GeneratedValue(strategy = IDENTITY)`     |
| `displayName`  | `String`        | `@NotNull`, `@Column(nullable = false)`           |
| `role`         | `Enum`          | `@NotNull`, store as `String` in DB               |
| `username`     | `String`        | `@NotNull`, `@Column(unique = true, nullable = false)` |
| `password`     | `String`        | `@NotNull`, encoded with BCrypt                   |
| `isEnabled`    | `boolean`       | `@NotNull`, default value `true`                  |
| `createdAt`    | `LocalDateTime` | `@NotNull`, automatically set to current time     |

### Role Enum Values
`ADMIN`, `USER`, `MANAGER`, `GENERAL_MANAGER`, `SECTOR_MANAGER`

### Lombok Annotations
- `@Data`
- `@NoArgsConstructor`
- `@AllArgsConstructor`
- `@Builder`

### JPA Annotations
- Use `@Enumerated(EnumType.STRING)` for the role field
- Use `@CreationTimestamp` for `createdAt`

---

## JWT Implementation

### 1. Security Configuration
**Package:** `com.ao8r.tasks_api.config.security`

**Class:** `SecurityConfig`
- Annotate with `@Configuration`, `@EnableWebSecurity`, `@EnableMethodSecurity`
- Define `SecurityFilterChain` bean
- Disable CSRF (stateless REST API)
- Set session management to `STATELESS`
- Whitelist public endpoints: `/api/auth/**`, `/api/test/public`
- Add custom `AuthTokenFilter` before `UsernamePasswordAuthenticationFilter`
- Define `PasswordEncoder` bean → `BCryptPasswordEncoder` (strength 10)
- Define `AuthenticationManager` bean

### 2. JWT Utility Service
**Package:** `com.ao8r.tasks_api.security.jwt`

**Class:** `JwtUtils`
- `generateJwtToken(UserDetails userDetails)` - creates JWT token
- `getUserNameFromJwtToken(String token)` - extracts username
- `validateJwtToken(String token)` - validates token signature and expiration
- Token expiration: **24 hours** (86400000 milliseconds)
- Secret key stored in `application.properties` as `jwt.secret`
- Include in claims: `username` and `roles`

### 3. JWT Authentication Filter
**Package:** `com.ao8r.tasks_api.security.jwt`

**Class:** `AuthTokenFilter` extends `OncePerRequestFilter`
- Parse JWT from `Authorization: Bearer <token>` header
- Validate token format and content
- Load user details via `UserDetailsService`
- Set `Authentication` object in `SecurityContextHolder`
- Handle exceptions gracefully

### 4. User Details Service
**Package:** `com.ao8r.tasks_api.security.services`

**Class:** `UserDetailsServiceImpl` implements `UserDetailsService`
- Override `loadUserByUsername(String username)` to fetch user from database
- Throw `UsernameNotFoundException` if user not found

**Class:** `UserDetailsImpl` implements `UserDetails`
- Map user entity fields to Spring Security UserDetails
- `getAuthorities()` → return `SimpleGrantedAuthority` with role (prefix "ROLE_")
- Override `isEnabled()` using the `isEnabled` flag from entity

---

## Authentication Controllers

**Package:** `com.ao8r.tasks_api.controller.auth`

**Class:** `AuthController`

### Endpoints

| Endpoint                  | Method | Description                        |
|---------------------------|--------|------------------------------------|
| `/api/auth/signup`        | POST   | Register new user                  |
| `/api/auth/signin`        | POST   | Authenticate user and return JWT   |

### Request/Response DTOs

**Package:** `com.ao8r.tasks_api.dto`

1. **SignupRequest**
   - `displayName` (String, @NotBlank, @Size max 50)
   - `username` (String, @NotBlank, @Size min 3, max 20)
   - `password` (String, @NotBlank, @Size min 6, max 40)
   - `role` (String, optional, default = "USER")

2. **SigninRequest**
   - `username` (String, @NotBlank)
   - `password` (String, @NotBlank)

3. **JwtResponse**
   - `token` (String)
   - `type` (String = "Bearer")
   - `id` (Long)
   - `username` (String)
   - `displayName` (String)
   - `role` (String)

4. **MessageResponse**
   - `message` (String)

> Add `@Valid` annotation to request parameters in controller methods.

---

## Repository Layer

**Package:** `com.ao8r.tasks_api.repository`

**Interface:** `UserRepository` extends `JpaRepository<User, Long>`

### Methods
- `Optional<User> findByUsername(String username)`
- `Boolean existsByUsername(String username)`

---

## Service Layer

**Package:** `com.ao8r.tasks_api.service`

### Interface: `UserService`
- `User registerUser(SignupRequest request)` - registers new user
- `Optional<User> findByUsername(String username)` - finds user by username
- `Boolean existsByUsername(String username)` - checks username existence

### Implementation: `UserServiceImpl`
- Inject `UserRepository` and `PasswordEncoder`
- Encode password using `BCryptPasswordEncoder` before saving
- Validate role input and default to "USER" if not provided
- Set `isEnabled` to `true` by default
- Set `createdAt` to current timestamp
- Throw appropriate exceptions for duplicate username or invalid role

---

## Test Controller (Role-Based Access)

**Package:** `com.ao8r.tasks_api.controller.test`

**Class:** `TestController`

### Endpoints

| Endpoint                  | Access                   | Method |
|---------------------------|--------------------------|--------|
| `GET /api/test/public`    | All users (no auth)      | GET    |
| `GET /api/test/user`      | USER role and above      | GET    |
| `GET /api/test/admin`     | ADMIN only               | GET    |

### Annotations
- Use `@PreAuthorize("hasRole('USER')")` for user endpoint
- Use `@PreAuthorize("hasRole('ADMIN')")` for admin endpoint
- No annotation for public endpoint

---

## Exception Handling

**Package:** `com.ao8r.tasks_api.exception`

**Class:** `GlobalExceptionHandler` with `@RestControllerAdvice`

### Handle exceptions:
- `MethodArgumentNotValidException` → return validation errors
- `UsernameNotFoundException` → return 404 with message
- `BadCredentialsException` → return 401 with message
- `JwtException` (and subclasses) → return 401 with message
- `Exception` (fallback) → return 500 with generic message

Use `ResponseEntity` with appropriate HTTP status codes.

---

## CORS Configuration

**In SecurityConfig or separate CorsConfig class:**
- Allow origin: `http://localhost:4200` (Angular default) or configurable
- Allow methods: GET, POST, PUT, DELETE, OPTIONS
- Allow headers: `Authorization`, `Content-Type`
- Allow credentials: true

---

## Logging Configuration

**File:** `src/main/resources/application.properties`

Configure logging levels:
- Root level: `INFO`
- `com.ao8r.tasks_api`: `DEBUG`
- `org.springframework.security`: `DEBUG`
- `org.hibernate.SQL`: `DEBUG`
- `org.hibernate.type.descriptor.sql.BasicBinder`: `TRACE` (for parameter binding)

Use SLF4J with `@Slf4j` annotation in classes.

---

## Database Schema Generation

- For development: `spring.jpa.hibernate.ddl-auto=update`
- For production reference: mention `validate` option
- Provide optional `data.sql` in `src/main/resources/` to insert default admin user

### Default Admin User (optional)
- Username: `admin`
- Password: `admin123` (must be BCrypt encoded)
- Role: `ADMIN`
- Display Name: `System Administrator`
- isEnabled: `true`

---

## Application Properties Template

```properties
# Server Configuration
server.port=8080

# Database Configuration
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=tech_daily_tasks;encrypt=true;trustServerCertificate=true
spring.datasource.username=awco
spring.datasource.password=awco
spring.datasource.driver-class-name=com.microsoft.sqlserver.jdbc.SQLServerDriver

# JPA Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.SQLServerDialect

# JWT Configuration
jwt.secret=${JWT_SECRET:mySecretKey123456789012345678901234567890}
jwt.expiration.ms=86400000

# Logging
logging.level.com.ao8r.tasks_api=DEBUG
logging.level.org.springframework.security=DEBUG
logging.level.org.hibernate.SQL=DEBUG

# Timezone
spring.jpa.properties.hibernate.jdbc.time_zone=UTC

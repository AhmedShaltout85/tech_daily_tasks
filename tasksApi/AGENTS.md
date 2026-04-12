# Code Guidelines for tasks_api (Spring Boot 3 + JWT + MSSQL)

## Project Overview
- **Project Name**: tasks_api
- **Base Package**: com.ao8r.tasks_api
- **Java Version**: 17
- **Database**: MSSQL Server (tech_daily_tasks)

---

## Build & Test Commands

```bash
# Build the project (skip tests)
mvn clean install -DskipTests

# Build with tests
mvn clean install

# Run the application
mvn spring-boot:run

# Run all tests
mvn test

# Run a single test class
mvn test -Dtest=TasksApiIntegrationTest

# Run a single test method
mvn test -Dtest=TasksApiIntegrationTest#test01_signup_new_user

# Run tests with verbose output
mvn test -X

# Package as JAR
mvn package -DskipTests
```

---

## API Endpoints

### Auth Controller (`/api/auth`)
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/auth/signup` | Register new user | No |
| POST | `/api/auth/signin` | Login, get JWT | No |

### Test Controller (`/api/test`)
| Method | Endpoint | Description | Required Role |
|--------|----------|-------------|---------------|
| GET | `/api/test/public` | Public endpoint | No |
| GET | `/api/test/user` | User endpoint | USER |
| GET | `/api/test/admin` | Admin endpoint | ADMIN |

### User Controller (`/api/users`)
| Method | Endpoint | Description | Required Role |
|--------|----------|-------------|---------------|
| GET | `/api/users/role/{role}` | Get usernames by role | ADMIN/MANAGER |

---

## Code Style Guidelines

### Import Order (IntelliJ IDEA default)
1. javax/java packages
2. org.springframework
3. com.ao8r (project packages)
4. other third-party libraries

### Formatting
- 4 spaces indentation (no tabs)
- Maximum line length: 120 characters
- Opening brace on same line
- One blank line between class members
- No trailing whitespace

### Naming Conventions
- **Classes**: PascalCase (e.g., `UserServiceImpl`, `AuthController`)
- **Methods/variables**: camelCase (e.g., `findByUsername`, `jwtSecret`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `JWT_SECRET`, `DEFAULT_ROLE`)
- **Packages**: lowercase, no underscores (e.g., `com.ao8r.tasks_api.entity`)
- **Enums**: PascalCase with UPPER_SNAKE values (e.g., `ADMIN`, `GENERAL_MANAGER`)

### Types & Annotations
- Use `Optional` for nullable return types
- Use `List` over `Collection` for method returns
- Use `@NonNull` Lombok annotation on required parameters
- Use `@Builder` pattern for complex object construction
- Use `LocalDateTime` for timestamps (not `Date`)
- Use `EnumType.STRING` for JPA enum storage

### Lombok Usage
- Use `@Data` sparingly (prefer `@Getter`/`@Setter` for entities)
- Always use `@NoArgsConstructor` and `@AllArgsConstructor` on entities
- Use `@Builder` for DTOs and complex constructors
- Use `@Slf4j` for logging in service/controller classes

### Entity Guidelines
- Use `@Id` with `@GeneratedValue(strategy = IDENTITY)` for auto-increment
- Use `@Enumerated(EnumType.STRING)` for role enums
- Use `@CreationTimestamp` for `createdAt` fields
- Use `@Column(unique = true)` for unique fields
- Always implement `Serializable` for entities

---

## JWT Implementation Guidelines

### Security Configuration
- Disable CSRF (`csrf.disable()`)
- Use `STATELESS` session management
- Whitelist public endpoints: `/api/auth/**`, `/api/test/public`
- Place `AuthTokenFilter` before `UsernamePasswordAuthenticationFilter`
- Use `BCryptPasswordEncoder` with strength 10

### JWT Token
- Secret key: minimum 512 bits (for HS512), stored in `application.properties`
- Token expiration: 24 hours (86400000 ms)
- Include claims: `username` and `roles`
- Use "Bearer " prefix in Authorization header
- Prefix roles with "ROLE_" in authorities (e.g., "ROLE_ADMIN")

---

## Controller Guidelines

### REST API Best Practices
- Use `@RestController` (not `@Controller`)
- Add `@RequestMapping` at class level
- Use `@Valid` on request body parameters
- Return `ResponseEntity<T>` for flexibility
- Use proper HTTP status codes

### Endpoint Conventions
- Use plural nouns for collections: `/api/users` not `/api/user`
- Use proper HTTP verbs
- Add `@PreAuthorize` for role-based access control

---

## Error Handling

### Global Exception Handler
- Use `@RestControllerAdvice` for centralized exception handling
- Handle validation, authentication, JWT errors
- Return user-friendly messages
- Never expose internal stack traces

---

## Database & JPA

### Application Properties
- Use environment variables for sensitive data
- Set `spring.jpa.hibernate.ddl-auto=none` (manual schema)
- Use UTC timezone

### Repository Layer
- Extend `JpaRepository<Entity, ID>`
- Use `Optional<Entity>` for single entity lookups
- Use `Boolean` for existence checks

---

## Testing Guidelines

### Test Structure
- Place tests in `src/test/java` matching `src/main/java` structure
- Use `@SpringBootTest` for integration tests
- Use H2 in-memory database for testing

### Test Scripts
- Location: `test_scripts/RESTful_client.http` (IntelliJ HTTP Client)
- Location: `test-api.sh` (Shell script)
- Location: `test-data.sql` (Database test data)

---

## Project Files

### Entity Fields
| Field | Type | Description |
|-------|------|-------------|
| id | Long | Primary key |
| displayName | String | User display name |
| username | String | Unique username |
| password | String | BCrypt encoded password |
| role | Enum | ADMIN, USER, MANAGER, GENERAL_MANAGER, SECTOR_MANAGER |
| department | String | User department |
| isEnabled | boolean | Account enabled status |
| createdAt | LocalDateTime | Creation timestamp |

### DTOs
- `SignupRequest`: displayName, username, password, role, department
- `SigninRequest`: username, password
- `JwtResponse`: token, type, id, username, displayName, role, department
- `MessageResponse`: message

---

## Database Schema

```sql
CREATE TABLE task_users (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    display_name NVARCHAR(200) NOT NULL,
    username NVARCHAR(255) NOT NULL UNIQUE,
    password NVARCHAR(255) NOT NULL,
    is_enable BIT NOT NULL DEFAULT 1,
    role NVARCHAR(50) NOT NULL,
    department NVARCHAR(255) NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);
```

---

*This file should be updated whenever project requirements or guidelines change.*

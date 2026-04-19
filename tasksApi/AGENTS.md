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
| POST | `/api/auth/signout` | Logout, clear security context | AUTHENTICATED |

### Test Controller (`/api/test`)
| Method | Endpoint | Description | Required Role |
|--------|----------|-------------|---------------|
| GET | `/api/test/public` | Public endpoint | No |
| GET | `/api/test/user` | User endpoint | USER |
| GET | `/api/test/admin` | Admin endpoint | ADMIN |

### User Controller (`/api/users`)
| Method | Endpoint | Description | Required Role |
|--------|----------|-------------|---------------|
| GET | `/api/users` | Get all users | ADMIN/MANAGER |
| GET | `/api/users/{id}` | Get user by ID | ADMIN/MANAGER |
| GET | `/api/users/role/{role}` | Get usernames by role | ADMIN/MANAGER |
| GET | `/api/users/role/{role}/enabled/{enabled}` | Get usernames by role and enabled status | ADMIN/MANAGER |
| PUT | `/api/users/{id}/enable?enabled=true` | Enable/disable user | ADMIN |
| PUT | `/api/users/change-password` | Change password (requires old password) | AUTHENTICATED |
| DELETE | `/api/users/{id}` | Delete user by ID | ADMIN |
| GET | `/api/users/roles` | Get all roles as list of strings | ADMIN/MANAGER |

### Apps Controller (`/api/apps`)
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/apps` | Create new app | AUTHENTICATED |
| GET | `/api/apps` | Get all apps | AUTHENTICATED |
| GET | `/api/apps/{id}` | Get app by ID | AUTHENTICATED |
| PUT | `/api/apps/{id}` | Update app by ID | AUTHENTICATED |
| DELETE | `/api/apps/{id}` | Delete app by ID | AUTHENTICATED |

### DailyTask Controller (`/api/daily-tasks`)
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/daily-tasks` | Create new daily task | AUTHENTICATED |
| GET | `/api/daily-tasks` | Get all daily tasks | AUTHENTICATED |
| GET | `/api/daily-tasks/{id}` | Get daily task by ID | AUTHENTICATED |
| PUT | `/api/daily-tasks/{id}` | Update daily task by ID | AUTHENTICATED |
| DELETE | `/api/daily-tasks/{id}` | Delete daily task by ID | AUTHENTICATED |
| GET | `/api/daily-tasks/assigned-to/{username}` | Get tasks assigned to user | AUTHENTICATED |
| GET | `/api/daily-tasks/assigned-by/{username}` | Get tasks assigned by user | AUTHENTICATED |
| GET | `/api/daily-tasks/app/{appName}` | Get tasks by app name | AUTHENTICATED |
| GET | `/api/daily-tasks/status/{taskStatus}` | Get tasks by status | AUTHENTICATED |
| GET | `/api/daily-tasks/priority/{taskPriority}` | Get tasks by priority | AUTHENTICATED |

### AboutApp Controller (`/api/about-apps`)
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/about-apps` | Create new about app | AUTHENTICATED |
| GET | `/api/about-apps` | Get all about apps | AUTHENTICATED |
| GET | `/api/about-apps/{id}` | Get about app by ID | AUTHENTICATED |
| GET | `/api/about-apps/name/{appName}` | Get about app by app name | AUTHENTICATED |
| GET | `/api/about-apps/name/{appName}/recommended` | Get recommended values by app name | AUTHENTICATED |
| PUT | `/api/about-apps/{id}` | Update about app by ID | AUTHENTICATED |
| DELETE | `/api/about-apps/{id}` | Delete about app by ID | AUTHENTICATED |

### PreventiveItem Controller (`/api/preventive-items`)
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/preventive-items` | Create new preventive item | AUTHENTICATED |
| GET | `/api/preventive-items` | Get all preventive items | AUTHENTICATED |
| GET | `/api/preventive-items/{id}` | Get preventive item by ID | AUTHENTICATED |
| GET | `/api/preventive-items/app/{appName}` | Get preventive item by app name | AUTHENTICATED |
| GET | `/api/preventive-items/app/{appName}/actions` | Get actions by app name | AUTHENTICATED |
| PUT | `/api/preventive-items/{id}` | Update preventive item by ID | AUTHENTICATED |
| DELETE | `/api/preventive-items/{id}` | Delete preventive item by ID | AUTHENTICATED |

### PlaceItem Controller (`/api/place-items`)
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/place-items` | Create new place item | AUTHENTICATED |
| GET | `/api/place-items` | Get all place items | AUTHENTICATED |
| GET | `/api/place-items/{id}` | Get place item by ID | AUTHENTICATED |
| GET | `/api/place-items/names` | Get all place names | AUTHENTICATED |
| PUT | `/api/place-items/{id}` | Update place item by ID | AUTHENTICATED |
| DELETE | `/api/place-items/{id}` | Delete place item by ID | AUTHENTICATED |

### PreventiveMaintenance Controller (`/api/preventive-maintenance`)
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/preventive-maintenance` | Create new preventive maintenance | AUTHENTICATED |
| GET | `/api/preventive-maintenance` | Get all preventive maintenance | AUTHENTICATED |
| GET | `/api/preventive-maintenance/{id}` | Get by ID | AUTHENTICATED |
| PUT | `/api/preventive-maintenance/{id}` | Update by ID | AUTHENTICATED |
| DELETE | `/api/preventive-maintenance/{id}` | Delete by ID | AUTHENTICATED |
| GET | `/api/preventive-maintenance/app/{appName}` | Filter by app name | AUTHENTICATED |
| GET | `/api/preventive-maintenance/user/{username}` | Filter by username | AUTHENTICATED |
| GET | `/api/preventive-maintenance/place/{placeName}` | Filter by place name | AUTHENTICATED |
| GET | `/api/preventive-maintenance/sub-place/{subPlace}` | Filter by sub place | AUTHENTICATED |
| GET | `/api/preventive-maintenance/remote/{isRemote}` | Filter by isRemote | AUTHENTICATED |
| GET | `/api/preventive-maintenance/app/{appName}/user/{username}` | Filter by app and user | AUTHENTICATED |
| GET | `/api/preventive-maintenance/app/{appName}/place/{placeName}` | Filter by app and place | AUTHENTICATED |
| GET | `/api/preventive-maintenance/user/{username}/place/{placeName}` | Filter by user and place | AUTHENTICATED |
| GET | `/api/preventive-maintenance/app/{appName}/remote/{isRemote}` | Filter by app and remote | AUTHENTICATED |
| GET | `/api/preventive-maintenance/user/{username}/remote/{isRemote}` | Filter by user and remote | AUTHENTICATED |
| GET | `/api/preventive-maintenance/place/{placeName}/remote/{isRemote}` | Filter by place and remote | AUTHENTICATED |

---

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
- Handle custom exceptions (e.g., `UserNotFoundException`)
- Return user-friendly messages with proper HTTP status codes:
  - 400 Bad Request for validation errors
  - 401 Unauthorized for auth failures
  - 404 Not Found for missing resources
  - 500 Internal Server Error for unexpected exceptions
- Never expose internal stack traces to clients

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

### Apps Entity Fields
| Field | Type | Description |
|-------|------|-------------|
| id | Long | Primary key |
| appName | String | Application name |

### AboutApp Entity Fields
| Field | Type | Description |
|-------|------|-------------|
| id | Long | Primary key |
| appName | String | Application name |
| recommended | String | Recommended value |

### PreventiveItem Entity Fields
| Field | Type | Description |
|-------|------|-------------|
| id | Long | Primary key |
| appName | String | Application name |
| action | String | Action |

### PlaceItem Entity Fields
| Field | Type | Description |
|-------|------|-------------|
| id | Long | Primary key |
| placeName | String | Place name |

### PreventiveMaintenance Entity Fields
| Field | Type | Description |
|-------|------|-------------|
| id | Long | Primary key |
| appName | String | Application name |
| action | String | Action |
| username | String | Username |
| placeName | String | Place name |
| subPlace | String | Sub place |
| isRemote | Boolean | Is remote flag |
| createdAt | LocalDateTime | Creation timestamp |

### DailyTask Entity Fields
| Field | Type | Description |
|-------|------|-------------|
| id | Long | Primary key |
| taskTitle | String | Task title |
| taskStatus | boolean | Task status (true=completed, false=pending) |
| appName | String | Application name |
| visitPlace | String | Visit place |
| subPlace | String | Sub place (optional) |
| assignedTo | String | Assigned to username |
| assignedBy | String | Assigned by username |
| coOperator | List<String> | Co-operator usernames |
| createdAt | LocalDateTime | Creation timestamp |
| updatedAt | LocalDateTime | Update timestamp |
| expectedCompletionDate | LocalDateTime | Expected completion date |
| taskPriority | String | Task priority |
| taskNote | String | Task note (optional) |
| isRemote | Boolean | Is remote flag |

### DTOs
- `SignupRequest`: displayName, username, password, role, department
- `SigninRequest`: username, password
- `JwtResponse`: token, type, id, username, displayName, role, department
- `MessageResponse`: message
- `AppsNameRequest`: appName
- `AppsNameResponse`: id, appName
- `AboutAppRequest`: appName, recommended
- `AboutAppResponse`: id, appName, recommended
- `PreventiveItemRequest`: appName, action
- `PreventiveItemResponse`: id, appName, action
- `PlaceItemRequest`: placeName
- `PlaceItemResponse`: id, placeName
- `PreventiveMaintenanceRequest`: appName, action, username, placeName, subPlace, isRemote
- `PreventiveMaintenanceResponse`: id, appName, action, username, placeName, subPlace, isRemote, createdAt
- `DailyTaskRequest`: taskTitle, taskStatus, appName, visitPlace, subPlace, assignedTo, assignedBy, coOperator (List), expectedCompletionDate, taskPriority, taskNote, isRemote
- `DailyTaskResponse`: id, taskTitle, taskStatus, appName, visitPlace, subPlace, assignedTo, assignedBy, coOperator (List), createdAt, updatedAt, expectedCompletionDate, taskPriority, taskNote, isRemote

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

CREATE TABLE apps_name (
    id BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    app_name NVARCHAR(255) NOT NULL
);

CREATE TABLE about_app (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    app_name NVARCHAR(255) NOT NULL,
    recommended NVARCHAR(255) NOT NULL
);

CREATE TABLE preventive_item (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    app_name NVARCHAR(255) NOT NULL,
    action NVARCHAR(255) NOT NULL
);

CREATE TABLE place_item (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    place_name VARCHAR(255) NOT NULL
);

CREATE TABLE preventive_maintenance (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    app_name VARCHAR(255) NOT NULL,
    action VARCHAR(255) NOT NULL,
    username VARCHAR(255) NOT NULL,
    place_name VARCHAR(255) NOT NULL,
    sub_place VARCHAR(255) NOT NULL DEFAULT 'none',
    is_remote BIT NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE()
);

CREATE TABLE daily_task (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    task_title NVARCHAR(255) NOT NULL,
    task_status BIT NOT NULL,
    app_name NVARCHAR(255) NOT NULL,
    visit_place NVARCHAR(255) NOT NULL,
    assigned_to NVARCHAR(255) NOT NULL,
    assigned_by NVARCHAR(255) NOT NULL,
    co_operator NVARCHAR(255)  NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NULL,
    expected_completion_date DATETIME2 NOT NULL,
    task_priority NVARCHAR(50) NOT NULL,
    task_note NVARCHAR(MAX) NULL DEFAULT 'none',
    is_remote BIT NOT NULL DEFAULT 0
);
CREATE TABLE daily_task_co_operator (
    daily_task_id BIGINT NOT NULL,
    co_operator NVARCHAR(255) NOT NULL,
    CONSTRAINT fk_daily_task FOREIGN KEY (daily_task_id) REFERENCES daily_task(id)
);

```

---

*This file should be updated whenever project requirements or guidelines change.*

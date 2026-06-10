# Tasks Employee Complaint API

A Spring Boot REST API for managing employee complaints. Part of the **tech_daily_tasks** system, this service handles complaint tracking with employee details, departments, and application information.

## Tech Stack

| Technology | Version |
|------------|---------|
| Java | 17 |
| Spring Boot | 3.3.4 |
| Spring Data JPA | 3.3.4 |
| Hibernate | 6.5.3 |
| MSSQL Server | JDBC Driver |
| Lombok | Latest |
| H2 Database | Test only |
| JUnit 5 | Test only |

## Project Structure

```
tasks-complaint-emp/
├── src/
│   ├── main/
│   │   ├── java/com/a08r/tasks_emp_complaint/
│   │   │   ├── TasksComplaintEmpApplication.java
│   │   │   ├── ServletInitializer.java
│   │   │   ├── controller/
│   │   │   │   └── TaskEmpComplaintController.java
│   │   │   ├── dto/
│   │   │   │   ├── MessageResponse.java
│   │   │   │   ├── TaskEmpComplaintRequest.java
│   │   │   │   └── TaskEmpComplaintResponse.java
│   │   │   ├── entity/
│   │   │   │   └── TaskEmpComplaint.java
│   │   │   ├── exception/
│   │   │   │   ├── GlobalExceptionHandler.java
│   │   │   │   └── ResourceNotFoundException.java
│   │   │   ├── repository/
│   │   │   │   └── TaskEmpComplaintRepository.java
│   │   │   └── service/
│   │   │       ├── TaskEmpComplaintService.java
│   │   │       └── TaskEmpComplaintServiceImpl.java
│   │   └── resources/
│   │       └── application.properties
│   └── test/
│       ├── java/com/a08r/tasks_emp_complaint/
│       │   ├── TaskEmpComplaintIntegrationTest.java
│       │   └── TasksComplaintEmpApplicationTests.java
│       └── resources/
│           └── application-test.properties
├── pom.xml
├── REST_CLIENT.http
└── README.md
```

## Database Schema

```sql
CREATE TABLE [dbo].[task_emp_complaint](
    [id] BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    [app_name] NVARCHAR(255) NOT NULL,
    [complaint_name] NVARCHAR(255) NOT NULL,
    [place_name] NVARCHAR(255) NOT NULL,
    [department] NVARCHAR(255) NOT NULL,
    [sub_place] NVARCHAR(255) NOT NULL DEFAULT 'none',
    [emp_name] NVARCHAR(255) NOT NULL,
    [emp_number] INTEGER NOT NULL,
    [emp_mobile] INTEGER NOT NULL,
    [is_enable] BIT NOT NULL DEFAULT 1,
    [created_at] DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);
```

## Configuration

### Application Properties

| Property | Value |
|----------|-------|
| Server Port | 9999 |
| Context Path | `/tasks-complaint-emp` |
| Database | `tech_daily_tasks` (MSSQL) |
| Hibernate DDL | `none` (manual schema) |
| Show SQL | `true` |
| Timezone | `GMT+2` |

### Build & Run

```bash
# Build the project
mvn clean install -DskipTests

# Run the application
mvn spring-boot:run

# Build with tests
mvn clean install

# Run tests only
mvn test

# Run specific test class
mvn test -Dtest=TaskEmpComplaintIntegrationTest

# Package as WAR
mvn package -DskipTests
```

## API Endpoints

**Base URL:** `http://localhost:9999/tasks-complaint-emp/api/emp-complaints`

### CRUD Operations

| Method | Endpoint | Description | Status |
|--------|----------|-------------|--------|
| POST | `/api/emp-complaints` | Create new complaint | 201 |
| GET | `/api/emp-complaints` | Get all complaints | 200 |
| GET | `/api/emp-complaints/{id}` | Get complaint by ID | 200 |
| PUT | `/api/emp-complaints/{id}` | Update complaint | 200 |
| DELETE | `/api/emp-complaints/{id}` | Delete complaint | 200 |

### Single Field Filters

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/emp-complaints/app/{appName}` | Filter by application name |
| GET | `/api/emp-complaints/complaint/{complaintName}` | Filter by complaint name |
| GET | `/api/emp-complaints/place/{placeName}` | Filter by place name |
| GET | `/api/emp-complaints/department/{department}` | Filter by department |
| GET | `/api/emp-complaints/sub-place/{subPlace}` | Filter by sub place |
| GET | `/api/emp-complaints/emp-name/{empName}` | Filter by employee name |
| GET | `/api/emp-complaints/emp-number/{empNumber}` | Filter by employee number |
| GET | `/api/emp-complaints/emp-mobile/{empMobile}` | Filter by employee mobile |
| GET | `/api/emp-complaints/enable/{isEnable}` | Filter by enabled status |

### Combined Filters

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/emp-complaints/app/{appName}/department/{department}` | Filter by app + department |
| GET | `/api/emp-complaints/app/{appName}/place/{placeName}` | Filter by app + place |
| GET | `/api/emp-complaints/department/{department}/place/{placeName}` | Filter by dept + place |
| GET | `/api/emp-complaints/emp-name/{empName}/app/{appName}` | Filter by employee + app |

## Request/Response Examples

### Create Complaint

**Request:**
```json
POST /api/emp-complaints
{
  "appName": "SAP",
  "complaintName": "Login timeout error",
  "placeName": "Main Office",
  "department": "IT",
  "subPlace": "Server Room",
  "empName": "Ahmed Ali",
  "empNumber": 10234,
  "empMobile": 551234567,
  "isEnable": true
}
```

**Response (201):**
```json
{
  "id": 1,
  "appName": "SAP",
  "complaintName": "Login timeout error",
  "placeName": "Main Office",
  "department": "IT",
  "subPlace": "Server Room",
  "empName": "Ahmed Ali",
  "empNumber": 10234,
  "empMobile": 551234567,
  "isEnable": true,
  "createdAt": "2026-06-10T09:26:53.173"
}
```

### Error Responses

**404 Not Found:**
```json
{
  "message": "Employee complaint not found with id: 999"
}
```

**400 Bad Request (Validation Error):**
```json
{
  "appName": "App name is required",
  "complaintName": "Complaint name is required"
}
```

## Entity Fields

| Field | Type | DB Column | Required | Default | Description |
|-------|------|-----------|----------|---------|-------------|
| id | Long | id | Auto | — | Primary key (auto-increment) |
| appName | String | app_name | Yes | — | Application name |
| complaintName | String | complaint_name | Yes | — | Complaint title/description |
| placeName | String | place_name | Yes | — | Location/place |
| department | String | department | Yes | — | Department name |
| subPlace | String | sub_place | No | "none" | Sub-location |
| empName | String | emp_name | Yes | — | Employee full name |
| empNumber | Integer | emp_number | Yes | — | Employee ID number |
| empMobile | Integer | emp_mobile | Yes | — | Employee mobile number |
| isEnable | Boolean | is_enable | No | true | Active status |
| createdAt | LocalDateTime | created_at | Auto | UTC | Creation timestamp |

## Validation Rules

| Field | Rule |
|-------|------|
| appName | @NotBlank, @Size(max=255) |
| complaintName | @NotBlank, @Size(max=255) |
| placeName | @NotBlank, @Size(max=255) |
| department | @NotBlank, @Size(max=255) |
| subPlace | @Size(max=255) |
| empName | @NotBlank, @Size(max=255) |
| empNumber | @NotNull |
| empMobile | @NotNull |

## Testing

### Integration Tests

Run all tests:
```bash
mvn test
```

Run specific test class:
```bash
mvn test -Dtest=TaskEmpComplaintIntegrationTest
```

**Test Coverage:**
- Create complaint (POST)
- Get all complaints (GET)
- Get complaint by ID (GET)
- Update complaint (PUT)
- Filter by app name (GET)
- Filter by department (GET)
- Delete complaint (DELETE)
- Get deleted complaint returns 404 (GET)

### REST Client Tests

Use `REST_CLIENT.http` file with IntelliJ HTTP Client or import into Postman. Contains 36 test requests covering all endpoints.

## Project Dependencies

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
        <scope>runtime</scope>
    </dependency>
    <dependency>
        <groupId>com.microsoft.sqlserver</groupId>
        <artifactId>mssql-jdbc</artifactId>
        <scope>runtime</scope>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Controller Layer                      │
│              TaskEmpComplaintController                  │
│         (REST endpoints, validation, CORS)               │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│                     Service Layer                        │
│          TaskEmpComplaintService (Interface)             │
│          TaskEmpComplaintServiceImpl (Impl)              │
│        (Business logic, transaction management)          │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│                   Repository Layer                       │
│           TaskEmpComplaintRepository                     │
│          (JPA queries, data access)                      │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│                     Entity Layer                         │
│             TaskEmpComplaint                             │
│            (JPA entity mapping)                          │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│                  Database Layer                          │
│            task_emp_complaint                            │
│            (MSSQL Server)                                │
└─────────────────────────────────────────────────────────┘
```

## CORS Configuration

CORS is enabled for all origins (`@CrossOrigin(origins = "*")`) to support Flutter Web frontend integration.

## Error Handling

Global exception handling via `GlobalExceptionHandler`:

| Exception | HTTP Status | Description |
|-----------|-------------|-------------|
| ResourceNotFoundException | 404 | Entity not found |
| MethodArgumentNotValidException | 400 | Validation failure |
| Exception | 500 | Unexpected error |

## Related Projects

| Project | Description |
|---------|-------------|
| `tasks-api` | Main API with authentication, users, tasks |
| `tasks_app` | Flutter Web frontend |

## License

Internal use only.

# Implementation Plan: task_emp_complaint (tasks-complaint-emp)

## Overview

Implement Entity, Repository, DTOs, Service, Controller, Exception handling, and Tests for the `task_emp_complaint` table in the `tasks-complaint-emp` Spring Boot project.

**Database Table:**
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

**Target Project:** `tasks-complaint-emp`
- Base package: `com.a08r.tasks_emp_complaint`
- Context path: `/tasks-complaint-emp`
- Port: 9999
- No Spring Security (no JWT/auth required)

---

## Files to Create

All files under: `tasks-complaint-emp/src/main/java/com/a08r/tasks_emp_complaint/`

### 1. Entity — `entity/TaskEmpComplaint.java`

```java
@Entity
@Table(name = "task_emp_complaint")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
```

| Field | Java Type | Column | Notes |
|-------|-----------|--------|-------|
| id | Long | id | @Id @GeneratedValue(IDENTITY) |
| appName | String | app_name | @Column(nullable = false) |
| complaintName | String | complaint_name | @Column(nullable = false) |
| placeName | String | place_name | @Column(nullable = false) |
| department | String | department | @Column(nullable = false) |
| subPlace | String | sub_place | @Column(nullable = false) |
| empName | String | emp_name | @Column(nullable = false) |
| empNumber | Integer | emp_number | @Column(nullable = false) |
| empMobile | Integer | emp_mobile | @Column(nullable = false) |
| isEnable | Boolean | is_enable | @Column(nullable = false) |
| createdAt | LocalDateTime | created_at | @CreationTimestamp @Column(nullable = false, updatable = false) |

Implements `java.io.Serializable`.

---

### 2. Repository — `repository/TaskEmpComplaintRepository.java`

Extends `JpaRepository<TaskEmpComplaint, Long>` with `@Repository`.

**Query methods:**
| Method | Return Type |
|--------|-------------|
| `findByAppName(String appName)` | `List<TaskEmpComplaint>` |
| `findByComplaintName(String complaintName)` | `List<TaskEmpComplaint>` |
| `findByPlaceName(String placeName)` | `List<TaskEmpComplaint>` |
| `findByDepartment(String department)` | `List<TaskEmpComplaint>` |
| `findBySubPlace(String subPlace)` | `List<TaskEmpComplaint>` |
| `findByEmpName(String empName)` | `List<TaskEmpComplaint>` |
| `findByEmpNumber(Integer empNumber)` | `List<TaskEmpComplaint>` |
| `findByEmpMobile(Integer empMobile)` | `List<TaskEmpComplaint>` |
| `findByIsEnable(Boolean isEnable)` | `List<TaskEmpComplaint>` |
| `findByAppNameAndDepartment(String appName, String department)` | `List<TaskEmpComplaint>` |
| `findByAppNameAndPlaceName(String appName, String placeName)` | `List<TaskEmpComplaint>` |
| `findByDepartmentAndPlaceName(String department, String placeName)` | `List<TaskEmpComplaint>` |
| `findByEmpNameAndAppName(String empName, String appName)` | `List<TaskEmpComplaint>` |

---

### 3. DTOs — `dto/`

#### `dto/TaskEmpComplaintRequest.java`

```java
@Data @NoArgsConstructor @AllArgsConstructor @Builder
```

| Field | Validation | Notes |
|-------|-----------|-------|
| appName | @NotBlank @Size(max=255) | |
| complaintName | @NotBlank @Size(max=255) | |
| placeName | @NotBlank @Size(max=255) | |
| department | @NotBlank @Size(max=255) | |
| subPlace | @Size(max=255) | Default: "none" |
| empName | @NotBlank @Size(max=255) | |
| empNumber | @NotNull | Integer |
| empMobile | @NotNull | Integer |
| isEnable | — | Default: true |

#### `dto/TaskEmpComplaintResponse.java`

```java
@Data @NoArgsConstructor @AllArgsConstructor @Builder
```

| Field | Type |
|-------|------|
| id | Long |
| appName | String |
| complaintName | String |
| placeName | String |
| department | String |
| subPlace | String |
| empName | String |
| empNumber | Integer |
| empMobile | Integer |
| isEnable | Boolean |
| createdAt | LocalDateTime |

---

### 4. Service Interface — `service/TaskEmpComplaintService.java`

```java
public interface TaskEmpComplaintService {
    TaskEmpComplaintResponse createItem(TaskEmpComplaintRequest request);
    List<TaskEmpComplaintResponse> getAllItems();
    TaskEmpComplaintResponse getItemById(Long id);
    TaskEmpComplaintResponse updateItem(Long id, TaskEmpComplaintRequest request);
    void deleteItem(Long id);

    // Filters
    List<TaskEmpComplaintResponse> getByAppName(String appName);
    List<TaskEmpComplaintResponse> getByComplaintName(String complaintName);
    List<TaskEmpComplaintResponse> getByPlaceName(String placeName);
    List<TaskEmpComplaintResponse> getByDepartment(String department);
    List<TaskEmpComplaintResponse> getBySubPlace(String subPlace);
    List<TaskEmpComplaintResponse> getByEmpName(String empName);
    List<TaskEmpComplaintResponse> getByEmpNumber(Integer empNumber);
    List<TaskEmpComplaintResponse> getByEmpMobile(Integer empMobile);
    List<TaskEmpComplaintResponse> getByIsEnable(Boolean isEnable);
    List<TaskEmpComplaintResponse> getByAppNameAndDepartment(String appName, String department);
    List<TaskEmpComplaintResponse> getByAppNameAndPlaceName(String appName, String placeName);
    List<TaskEmpComplaintResponse> getByDepartmentAndPlaceName(String department, String placeName);
    List<TaskEmpComplaintResponse> getByEmpNameAndAppName(String empName, String appName);
}
```

---

### 5. Service Implementation — `service/TaskEmpComplaintServiceImpl.java`

```java
@Service @RequiredArgsConstructor @Slf4j
```

- Uses `TaskEmpComplaintRepository` via constructor injection
- `@Transactional` on create, update, delete
- Private `mapToResponse(TaskEmpComplaint)` helper method
- Throws `ResourceNotFoundException` when entity not found
- Defaults: `subPlace = "none"`, `isEnable = true` if null

---

### 6. Controller — `controller/TaskEmpComplaintController.java`

```java
@RestController
@RequestMapping("/api/emp-complaints")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
@Slf4j
```

**Endpoints:**

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/emp-complaints` | Create complaint |
| GET | `/api/emp-complaints` | Get all |
| GET | `/api/emp-complaints/{id}` | Get by ID |
| PUT | `/api/emp-complaints/{id}` | Update |
| DELETE | `/api/emp-complaints/{id}` | Delete |
| GET | `/api/emp-complaints/app/{appName}` | Filter by app |
| GET | `/api/emp-complaints/complaint/{complaintName}` | Filter by complaint name |
| GET | `/api/emp-complaints/place/{placeName}` | Filter by place |
| GET | `/api/emp-complaints/department/{department}` | Filter by department |
| GET | `/api/emp-complaints/sub-place/{subPlace}` | Filter by sub place |
| GET | `/api/emp-complaints/emp-name/{empName}` | Filter by employee name |
| GET | `/api/emp-complaints/emp-number/{empNumber}` | Filter by employee number |
| GET | `/api/emp-complaints/emp-mobile/{empMobile}` | Filter by employee mobile |
| GET | `/api/emp-complaints/enable/{isEnable}` | Filter by enabled status |
| GET | `/api/emp-complaints/app/{appName}/department/{department}` | Filter by app + department |
| GET | `/api/emp-complaints/app/{appName}/place/{placeName}` | Filter by app + place |
| GET | `/api/emp-complaints/department/{department}/place/{placeName}` | Filter by dept + place |
| GET | `/api/emp-complaints/emp-name/{empName}/app/{appName}` | Filter by emp name + app |

---

### 7. Exception Handling — `exception/`

#### `exception/ResourceNotFoundException.java`
```java
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
```

#### `exception/GlobalExceptionHandler.java`
```java
@RestControllerAdvice
@Slf4j
```

Handles:
- `ResourceNotFoundException` → 404
- `MethodArgumentNotValidException` → 400
- `Exception` → 500

---

### 8. Message DTO — `dto/MessageResponse.java`

```java
@Data @AllArgsConstructor
public class MessageResponse {
    private String message;
}
```

---

## Testing

### Integration Test — `src/test/java/com/a08r/tasks_emp_complaint/TaskEmpComplaintIntegrationTest.java`

Uses `@SpringBootTest(webEnvironment = RANDOM_PORT)` with `TestRestTemplate`.

**Test H2 schema** — `src/test/resources/application-test.properties`:
- Uses H2 in-memory database
- Hibernate DDL auto: `create-drop`

**Test cases (ordered):**
1. Create complaint — POST `/api/emp-complaints` → 201
2. Get all complaints — GET `/api/emp-complaints` → 200, list size ≥ 1
3. Get complaint by ID — GET `/api/emp-complaints/{id}` → 200
4. Update complaint — PUT `/api/emp-complaints/{id}` → 200
5. Filter by app name — GET `/api/emp-complaints/app/{appName}` → 200
6. Filter by department — GET `/api/emp-complaints/department/{department}` → 200
7. Delete complaint — DELETE `/api/emp-complaints/{id}` → 200
8. Get deleted complaint — GET `/api/emp-complaints/{id}` → 404

---

## Build & Test Commands

```bash
# From tasks-complaint-emp directory
mvn clean install -DskipTests     # Build
mvn spring-boot:run               # Run
mvn test                          # Run tests
mvn test -Dtest=TaskEmpComplaintIntegrationTest  # Run specific test
```

---

## Implementation Order

1. `exception/ResourceNotFoundException.java`
2. `exception/GlobalExceptionHandler.java`
3. `dto/MessageResponse.java`
4. `entity/TaskEmpComplaint.java`
5. `repository/TaskEmpComplaintRepository.java`
6. `dto/TaskEmpComplaintRequest.java`
7. `dto/TaskEmpComplaintResponse.java`
8. `service/TaskEmpComplaintService.java`
9. `service/TaskEmpComplaintServiceImpl.java`
10. `controller/TaskEmpComplaintController.java`
11. `src/test/resources/application-test.properties`
12. `TaskEmpComplaintIntegrationTest.java`

---

## Notes

- Follows same conventions as `tasks-api` (Lombok, Service pattern, mapToResponse helper)
- `emp_number` and `emp_mobile` are `Integer` (matching SQL `INTEGER` type)
- No security/JWT in this project (tasks-complaint-emp has no Spring Security dependency)
- CORS enabled (`@CrossOrigin(origins = "*")`) for Flutter Web
- All endpoints use `ResponseEntity<T>` with proper HTTP status codes
- Validation via `@Valid` + Jakarta Validation annotations

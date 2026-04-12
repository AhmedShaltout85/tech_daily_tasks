Create a complete Spring Boot 3 project with Java 17 and MSSQL Server for a tasks_api application with JWT authentication. Use the following specifications:

PROJECT STRUCTURE:
- Project Name: tasks_api
- Group: com.ao8r
- Artifact: tasks_api
- Package: com.ao8r.tasks_api
- Packaging: Jar
- Java Version: 17

DEPENDENCIES REQUIRED:
- Spring Web
- Spring Boot DevTools
- Lombok
- Spring Security
- Spring Data JPA
- MSSQL Server Driver
- JJWT (Java JWT) for JWT implementation

DATABASE CONFIGURATION:
- Create application.properties with MSSQL configuration
- Database name: tech_daily_tasks
- Include proper connection parameters (URL, username, password placeholders)
- Enable JPA SQL logging for development

USER TABLE ENTITY:
Create User entity with the following fields in com.ao8r.tasks_api.entity package:
- id: Long (Primary key, auto-generated)
- display_name: String (not null)
- role: String (not null) - use Enum for roles (ADMIN, USER, MANAGER, GENERAL_MANAGER, SECTOR_MANAGER)
- username: String (unique, not null)
- password: String (not null, encoded)
- is_enable: bit (not null)
- created_at: datetime (not null)
- Include proper JPA annotations (@Entity, @Table, @Id, @GeneratedValue, etc.)
- Add Lombok annotations (@Data, @NoArgsConstructor, @AllArgsConstructor)

JWT IMPLEMENTATION:
Create JWT authentication with the following components in appropriate packages:

1. Security Configuration (com.ao8r.tasks_api.config.security):
   - SecurityConfig class with SecurityFilterChain
   - Configure HTTP security to permit public endpoints and secure others
   - Disable CSRF for stateless JWT
   - Set session management to STATELESS
   - Add JWT authentication filter

2. JWT Service (com.ao8r.tasks_api.security.jwt):
   - JwtUtils class for generating, validating, and parsing JWT tokens
   - Include token expiration (recommend 24 hours)
   - Use secret key for signing tokens
   - Include username and roles in token claims

3. JWT Authentication Filter (com.ao8r.tasks_api.security.jwt):
   - Create AuthTokenFilter that extends OncePerRequestFilter
   - Extract JWT from Authorization header
   - Validate token and set authentication in SecurityContext

4. User Details Service (com.ao8r.tasks_api.security.services):
   - Implement UserDetailsService to load user by username from database
   - Create UserDetailsImpl implementing UserDetails with proper authorities from roles

AUTHENTICATION CONTROLLERS (com.ao8r.tasks_api.controller.auth):
1. AuthController with endpoints:
   - POST /api/auth/signup - Register new user (accept name, username, password, role)
   - POST /api/auth/signin - Authenticate user and return JWT token
   - Use proper request/response DTOs

2. Create DTOs in com.ao8r.tasks_api.dto:
   - SignupRequest (displayName, username, password, role)
   - SigninRequest (username, password)
   - JwtResponse (token, id, username, displayName, role)
   - MessageResponse for API messages

REPOSITORY LAYER (com.ao8r.tasks_api.repository):
- Create UserRepository interface extending JpaRepository
- Add method to find by username
- Add method to check existence by username

SERVICE LAYER (com.ao8r.tasks_api.service):
- Create UserService interface and implementation
- Include methods for user operations
- Handle password encoding using BCryptPasswordEncoder

SAMPLE CONTROLLER FOR TESTING:
Create a test controller (com.ao8r.tasks_api.controller.test):
- GET /api/test/all - Public endpoint
- GET /api/test/user - User role accessible
- GET /api/test/admin - Admin role accessible
- Use proper annotations for role-based access

ADDITIONAL REQUIREMENTS:
- Include proper exception handling
- Add validation annotations on DTOs
- Create database schema generation strategy (update or validate)
- Include CORS configuration
- Add proper logging configuration
- Include README with setup instructions
- Add sample SQL script for initial data if needed

Please provide the complete implementation with all necessary files, including:
- All Java classes with proper imports
- application.properties configuration
- pom.xml with all dependencies including JJWT versions
- Proper package structure as specified
- Clean code with comments where necessary
- Best practices for Spring Boot 3 and JWT implementation

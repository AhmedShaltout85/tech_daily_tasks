# Tech Daily Tasks (تطبيق المهام اليومية)

A full-stack task management application consisting of a Flutter web frontend and Spring Boot backend API.

## Project Structure

```
tech_daily_tasks/
├── tasks_app/          # Flutter web application
├── tasks-api/           # Spring Boot backend API
├── COMPACTED_PROMPT.md # Session summary document
└── README.md
```

---

## Flutter App (tasks_app)

### Tech Stack
- **Framework**: Flutter Web
- **State Management**: Provider
- **HTTP Client**: Dio
- **Local Storage**: Hive, SharedPreferences
- **PDF Generation**: pdf, printing packages
- **Authentication**: Firebase Auth, Cloud Firestore

### Key Dependencies
```yaml
- provider: ^6.1.5+1
- dio: ^5.4.0
- firebase_auth: ^6.1.2
- cloud_firestore: ^6.1.0
- hive: ^2.2.3
- pdf: ^3.11.3
- printing: ^5.14.2
- connectivity_plus: ^7.0.0
- intl: ^0.20.2
- multiselect_dropdown_flutter: ^0.0.7
```

### App Architecture

#### Directory Structure
```
tasks_app/lib/
├── main.dart                           # App entry point with MultiProvider setup
├── controller/                         # State management (Providers)
│   ├── user_provider.dart
│   ├── daily_task_provider.dart
│   ├── place_name_provider.dart
│   ├── about_app_provider.dart
│   ├── preventive_provider.dart
│   └── theme_provider.dart
├── models/                             # Data models
│   ├── user_model.dart
│   ├── daily_task_model.dart
│   ├── place_name_model.dart
│   ├── about_app_model.dart
│   ├── preventive_maintenance_model.dart
│   └── preventive_item_model.dart
├── screens/                           # UI screens
│   ├── auth/                          # Authentication screens
│   ├── login/login_screen.dart
│   ├── signup/signup_screen.dart
│   ├── splash/splash_screen.dart
│   ├── task/                          # Task management
│   │   ├── task_screen.dart
│   │   └── user_task_screen.dart
│   ├── user/                          # User management
│   │   ├── manage_user_screen.dart
│   │   └── manage_users.dart
│   ├── places/                        # Place management
│   │   └── manage_place_screen.dart
│   ├── about_app/                     # About apps management
│   │   ├── manage_about_app_screen.dart
│   │   └── app_recommended_details_screen.dart
│   ├── preventive/                    # Preventive maintenance
│   │   ├── preventive_item_screen.dart
│   │   └── manage_preventive_maintenance_screen.dart
│   ├── report/                        # Reports
│   │   ├── report_screen.dart
│   │   └── widgets/generate_pdf.dart
│   └── settings/settings_screen.dart
├── common_widgets/                    # Reusable UI components
│   ├── custom_widgets/
│   │   ├── custom_drawer.dart         # Navigation drawer
│   │   ├── custom_bottom_sheet.dart
│   │   ├── task_item_card.dart
│   │   └── custom_text_field.dart
│   └── resuable_widgets/
│       └── resuable_widgets.dart
├── newtork_repos/                     # Network layer
│   └── remote_repo/api_repos/          # API repositories
│       ├── api_network_user_repos.dart
│       ├── api_network_daily_task_repos.dart
│       ├── api_network_place_name_repos.dart
│       ├── api_network_about_app_repos.dart
│       └── api_network_preventive_repos.dart
├── services/                           # Services
│   └── connectivity_service.dart
└── utils/                              # Utilities
    ├── app_theme.dart
    ├── app_route.dart
    ├── app_colors.dart
    └── app_assets.dart
```

#### Providers (State Management)
1. **UserProvider** - User authentication and management
2. **DailyTaskProvider** - Daily task CRUD operations
3. **PlaceNameProvider** - Location/place management
4. **AboutAppProvider** - Application metadata management
5. **PreventiveProvider** - Preventive maintenance tasks
6. **ThemeProvider** - Dark/Light theme switching

#### Features
- User authentication with Firebase
- Task creation, assignment, and tracking
- Co-operator filtering (dynamic exclusion)
- Remote/Onsite work type filtering
- PDF report generation and export
- Multi-language support (RTL layout)
- Dark/Light theme toggle
- Internet connectivity checking

---

## Spring Boot API (tasks-api)

### Tech Stack
- **Framework**: Spring Boot 3.3.4
- **Java Version**: 17
- **Security**: Spring Security with JWT (jjwt 0.11.5)
- **Database**: MSSQL Server
- **Build Tool**: Maven
- **Packaging**: WAR

### Key Dependencies
```xml
- spring-boot-starter-web
- spring-boot-starter-security
- spring-boot-starter-data-jpa
- spring-boot-starter-validation
- mssql-jdbc
- jjwt-api, jjwt-impl, jjwt-jackson (0.11.5)
- lombok
```

### Backend Architecture

#### Directory Structure
```
tasks-api/src/main/java/com/ao8r/tasks_api/
├── TasksApiApplication.java           # Main application class
├── controller/                        # REST controllers
│   ├── auth/AuthController.java
│   ├── UserController.java
│   ├── AppsController.java
│   ├── DailyTaskController.java
│   ├── AboutAppController.java
│   ├── PlaceItemController.java
│   ├── PreventiveItemController.java
│   ├── PreventiveMaintenanceController.java
│   └── PasswordController.java
├── service/                           # Business logic
│   ├── UserService.java / UserServiceImpl.java
│   ├── DailyTaskService.java / DailyTaskServiceImpl.java
│   ├── AppsNameService.java / AppsNameServiceImpl.java
│   ├── AboutAppService.java / AboutAppServiceImpl.java
│   ├── PlaceItemService.java / PlaceItemServiceImpl.java
│   ├── PreventiveItemService.java / PreventiveItemServiceImpl.java
│   └── PreventiveMaintenanceService.java / PreventiveMaintenanceServiceImpl.java
├── repository/                        # Data access layer
│   ├── UserRepository.java
│   ├── DailyTaskRepository.java
│   ├── AppsNameRepository.java
│   ├── AboutAppRepository.java
│   ├── AboutAppRecommendedRepository.java
│   ├── PlaceItemRepository.java
│   ├── PreventiveItemRepository.java
│   └── PreventiveMaintenanceRepository.java
├── entity/                            # JPA entities
│   ├── User.java
│   ├── DailyTask.java
│   ├── AppsName.java
│   ├── AboutApp.java
│   ├── AboutAppRecommended.java
│   ├── PlaceItem.java
│   ├── PreventiveItem.java
│   ├── PreventiveMaintenance.java
│   └── Role.java
├── dto/                               # Data transfer objects
│   ├── SignupRequest.java
│   ├── SigninRequest.java
│   ├── JwtResponse.java
│   ├── DailyTaskRequest.java
│   ├── DailyTaskResponse.java
│   └── ... (other DTOs)
├── security/                          # Security configuration
│   ├── jwt/AuthTokenFilter.java
│   ├── jwt/JwtUtils.java
│   └── services/UserDetailsServiceImpl.java
├── config/
│   └── security/SecurityConfig.java
└── exception/                          # Exception handling
    ├── GlobalExceptionHandler.java
    ├── ResourceNotFoundException.java
    └── UserNotFoundException.java
```

#### API Endpoints

##### Auth (`/api/auth`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/signup` | Register new user |
| POST | `/api/auth/signin` | Login, get JWT |
| POST | `/api/auth/signout` | Logout |

##### Users (`/api/users`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/users` | Get all users |
| GET | `/api/users/{id}` | Get user by ID |
| GET | `/api/users/department/{department}` | Get users by department |
| GET | `/api/users/role/{role}` | Get users by role |
| PUT | `/api/users/{id}/enable` | Enable/disable user |
| DELETE | `/api/users/{id}` | Delete user |
| GET | `/api/users/roles` | Get all roles |

##### Daily Tasks (`/api/daily-tasks`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/daily-tasks` | Create task |
| GET | `/api/daily-tasks` | Get all tasks |
| GET | `/api/daily-tasks/{id}` | Get task by ID |
| PUT | `/api/daily-tasks/{id}` | Update task |
| DELETE | `/api/daily-tasks/{id}` | Delete task |
| GET | `/api/daily-tasks/assigned-to/{username}` | Tasks by assignee |
| GET | `/api/daily-tasks/assigned-by/{username}` | Tasks by assigner |
| GET | `/api/daily-tasks/app/{appName}` | Tasks by app |
| GET | `/api/daily-tasks/status/{status}` | Tasks by status |

##### Other Endpoints
- **Apps** (`/api/apps`): CRUD for applications
- **About Apps** (`/api/about-apps`): App metadata management
- **Places** (`/api/place-items`): Location management
- **Preventive Items** (`/api/preventive-items`): Preventive action items
- **Preventive Maintenance** (`/api/preventive-maintenance`): Maintenance records

#### Security
- JWT-based authentication
- BCrypt password encoding
- Role-based access control (ADMIN, USER, MANAGER, GENERAL_MANAGER, SECTOR_MANAGER)
- Stateless session management

---

## Database Schema

### Tables
- `task_users` - User accounts with roles and departments
- `apps_name` - Application names
- `about_app` - Application metadata with recommended values
- `place_item` - Location/place names
- `daily_task` - Daily task records
- `daily_task_co_operator` - Co-operator relationships
- `preventive_item` - Preventive maintenance items
- `preventive_maintenance` - Maintenance records

---

## Getting Started

### Prerequisites
- Flutter SDK 3.5.3+
- Java 17+
- Maven 3.6+
- MSSQL Server

### Backend Setup
```bash
cd tasks-api
mvn clean install -DskipTests
mvn spring-boot:run
```

### Frontend Setup
```bash
cd tasks_app
flutter pub get
flutter run -d chrome
```

### Build Commands

#### Backend
```bash
# Build
mvn clean install -DskipTests

# Run tests
mvn test

# Package
mvn package -DskipTests
```

#### Frontend
```bash
# Get dependencies
flutter pub get

# Run
flutter run

# Build web
flutter build web

# Build with base href
flutter build web --base-href /your-path/
```

---

## Features Summary

| Feature | Frontend | Backend |
|---------|----------|---------|
| User Auth | Firebase + JWT | Spring Security + JWT |
| Task Management | Provider + Dio | REST API + JPA |
| Role-based Access | UI filtering | @PreAuthorize |
| Reports | PDF export | Data endpoints |
| Remote Work | Filter support | isRemote field |
| Multi-language | RTL support | N/A |
| Theme | Dark/Light toggle | N/A |
| Offline | Hive cache | N/A |

---

## Requirements

- **Flutter**: ^3.5.3
- **Java**: 17+
- **Maven**: 3.6+
- **MSSQL Server**: 2019+
- **Node.js**: (for Firebase tools, optional)
# Employee Complaints Management System - Flutter Client

A comprehensive employee complaint management application built with Flutter for Alexandria Water Company. The app provides a fully Arabic (RTL) interface for managing employee complaints, with responsive design supporting both Android mobile and Flutter Web platforms.

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Screens](#screens)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Technologies & Dependencies](#technologies--dependencies)
- [API Integration](#api-integration)
- [Connectivity Handling](#connectivity-handling)
- [State Management](#state-management)
- [Design System](#design-system)
- [Setup & Installation](#setup--installation)
- [Configuration](#configuration)
- [Build & Deployment](#build--deployment)
- [Development Notes](#development-notes)

---

## Overview

This Flutter application serves as the frontend client for the Employee Complaints Management System. It connects to a Spring Boot REST API backend (`tasks-complaint-emp`) to perform CRUD operations on employee complaints. The application is designed specifically for Arabic-speaking users with full RTL support, using the Cairo font family throughout.

### Core Capabilities

- **Complaint Management**: Create, view, and filter employee complaints
- **Dynamic Dropdowns**: App names and place names fetched from backend lookup tables
- **Real-time Validation**: Client-side form validation with Arabic error messages
- **Connectivity Awareness**: Automatic detection of internet connectivity with retry dialogs
- **Responsive Design**: Adaptive layouts for mobile devices and web browsers

---

## Key Features

| Feature | Description |
|---------|-------------|
| **Arabic RTL Interface** | Complete right-to-left layout with Cairo font throughout the application |
| **Responsive Design** | Fluid layouts adapting to different screen sizes (mobile + web) |
| **Connectivity Check** | Real-time internet detection using `connectivity_plus` with SnackBar alerts |
| **No-Internet Dialog** | Beautiful retry dialog shown when API calls fail due to connectivity issues |
| **Input Validation** | Employee number (exactly 5 digits), mobile (exactly 11 digits) with live feedback |
| **Dynamic Dropdowns** | App names and place names loaded from database via REST API |
| **Pull-to-Refresh** | Swipe down to refresh complaint list on home screen |
| **Animated Splash Screen** | Gradient splash with scale/fade animations and company branding |
| **Sectioned Form Layout** | Complaint and employee data grouped in visually distinct card sections |
| **Error Handling** | Comprehensive error interception with Arabic toast notifications |
| **Light Theme Only** | Clean, professional light theme (no dark mode) |

---

## Screens

### 1. Splash Screen (`SplashScreen`)
- **Path**: `lib/screens/splash/splash_screen.dart`
- **Description**: Animated launch screen with gradient background
- **Features**:
  - Scale + fade animation for logo (elastic bounce effect)
  - Slide-in animation for title text
  - Staggered fade for bottom info text
  - Displays developer info and copyright notice
  - Auto-navigates to Home Screen after 4 seconds

### 2. Home Screen (`HomeScreen`)
- **Path**: `lib/screens/home/home_screen.dart`
- **Description**: Main screen displaying all complaints with filtering capabilities
- **Features**:
  - Grid/list view of all complaints (responsive: 1-3 columns)
  - Pull-to-refresh functionality
  - Filter bottom sheet with dropdowns for:
    - App Name (المنظومة)
    - Department (الادارة)
    - Employee Name (اسم الموظف)
  - Active filter chips with clear option
  - Empty state with icon when no complaints exist
  - Loading spinner during data fetch
  - Connectivity check before API calls
  - FAB button to navigate to Add Complaint screen

### 3. Add Complaint Screen (`AddComplaintScreen`)
- **Path**: `lib/screens/add_complaint/add_complaint_screen.dart`
- **Description**: Form screen for creating new complaints
- **Features**:
  - Gradient header with animated fade-in
  - Two card sections: Complaint Data + Employee Data
  - 8 form fields with validation:

| Field | Type | Validation | Icon |
|-------|------|------------|------|
| App Name (المنظومة) | Dropdown | Required | `phone_android` |
| Complaint Name (اسم الشكوى) | Text | Required | `edit_note` |
| Place Name (المكان الرئيسي) | Dropdown | Required | `location_on` |
| Department (الادارة) | Dropdown | Required | `business` |
| Sub Place (المكان الفرعي) | Text | Optional | `place` |
| Employee Name (اسم الموظف) | Text | Required | `person` |
| Employee Number (رقم الموظف) | Number | 5 digits exactly | `badge` |
| Employee Mobile (موبايل الموظف) | Number | 11 digits exactly | `phone` |

  - Connectivity check before submission
  - Success dialog on successful creation
  - Error toast on failure
  - Loading state on submit button

---

## Architecture

The application follows a clean architecture pattern with clear separation of concerns:

```
Presentation Layer  →  State Management  →  Data Layer  →  Network Layer
     (Screens)          (Providers)       (Models)         (API Repos)
```

### Design Patterns Used

1. **Provider Pattern**: State management via `ChangeNotifier` classes
2. **Repository Pattern**: API calls abstracted in repository classes
3. **Singleton Pattern**: `DioClient` and `ConnectivityService` are singletons
4. **Service Pattern**: Connectivity and dialog services as reusable utilities

---

## Project Structure

```
lib/
├── main.dart                              # App entry point with MultiProvider setup
│
├── common_widgets/
│   └── custom_widgets/
│       ├── custom_button.dart             # Reusable gradient button with loading state
│       ├── custom_complaint_card.dart     # Complaint card widget for grid display
│       ├── custom_dropdown.dart           # DropdownButtonFormField wrapper
│       ├── custom_loading.dart            # CircularProgressIndicator wrapper
│       ├── custom_text.dart               # Styled Text widget
│       └── custom_text_field.dart         # TextFormField with label/hint/icon
│
├── controller/
│   ├── complaint_provider.dart            # Complaint state: CRUD, filtering, loading/error
│   └── lookup_provider.dart               # Lookup data: aboutApps, placeItems, appNames, placeNames
│
├── models/
│   ├── complaint_model.dart               # ComplaintModel: 11 fields, fromJson/toJson/copyWith
│   ├── about_app_model.dart               # AboutAppModel: id, appName, recommended, department
│   └── place_item_model.dart              # PlaceItemModel: id, placeName
│
├── network/
│   ├── dio_client.dart                    # Singleton Dio with base URL, interceptors, error handling
│   ├── complaint_api_repository.dart      # Complaint CRUD + filter API calls
│   └── lookup_api_repository.dart         # AboutApp + PlaceItem API calls
│
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart             # Animated splash with company info
│   ├── home/
│   │   └── home_screen.dart               # Complaint list with filter bottom sheet
│   └── add_complaint/
│       └── add_complaint_screen.dart      # 8-field form with validation
│
├── services/
│   ├── connectivity_service.dart          # Internet connectivity check (web + mobile)
│   └── connection_dialog_service.dart     # No-internet dialog with retry callback
│
└── utils/
    ├── app_assets.dart                    # Asset path constants
    ├── app_colors.dart                    # Color palette (primary, accent, error, etc.)
    ├── app_route.dart                     # Route name constants
    └── app_theme.dart                     # Material3 light theme configuration
```

---

## Technologies & Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter` | SDK | Framework |
| `dio` | ^5.4.0 | HTTP client for REST API calls |
| `provider` | ^6.1.5+1 | State management via ChangeNotifier |
| `fluttertoast` | ^8.2.8 | Toast notifications (Arabic messages) |
| `intl` | ^0.20.2 | Date formatting with Arabic locale (`ar_SA`) |
| `connectivity_plus` | ^7.0.0 | Network connectivity detection (web + mobile) |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

### Development Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Unit and widget testing |
| `flutter_lints` | ^4.0.0 | Lint rules for code quality |

---

## API Integration

The app communicates with the Spring Boot backend at `http://localhost:9999/tasks-complaint-emp`.

### Complaint Endpoints

| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| `GET` | `/api/emp-complaints` | Get all complaints | - | `List<ComplaintModel>` |
| `POST` | `/api/emp-complaints` | Create complaint | `ComplaintModel` | `ComplaintModel` |
| `PUT` | `/api/emp-complaints/{id}` | Update complaint | `ComplaintModel` | `ComplaintModel` |
| `DELETE` | `/api/emp-complaints/{id}` | Delete complaint | - | `MessageResponse` |
| `GET` | `/api/emp-complaints/app/{appName}` | Filter by app | - | `List<ComplaintModel>` |
| `GET` | `/api/emp-complaints/department/{dept}` | Filter by dept | - | `List<ComplaintModel>` |
| `GET` | `/api/emp-complaints/emp-name/{name}` | Filter by name | - | `List<ComplaintModel>` |

### Lookup Endpoints

| Method | Endpoint | Description | Response |
|--------|----------|-------------|----------|
| `GET` | `/api/about-apps` | Get all app records | `List<AboutAppModel>` |
| `GET` | `/api/place-items` | Get all place records | `List<PlaceItemModel>` |

### Error Handling

The `DioClient` interceptor handles all HTTP errors with Arabic messages:

| Status Code | Arabic Message | English Meaning |
|-------------|----------------|-----------------|
| 400 | First validation error message | Bad Request |
| 404 | "السجل غير موجود" | Record Not Found |
| 500 | "خطأ في الخادم" | Internal Server Error |
| Timeout | "انتهت مهلة الاتصال" | Connection Timeout |
| No Internet | "لا يوجد اتصال بالإنترنت" | No Internet Connection |

---

## Connectivity Handling

The app uses a multi-layered connectivity checking approach:

### ConnectivityService (`services/connectivity_service.dart`)
- **Singleton pattern** for app-wide access
- Uses `connectivity_plus` to detect network type (wifi, mobile, ethernet)
- **Web**: Trusts `connectivity_plus` result (browser security prevents DNS checks)
- **Mobile**: Performs DNS lookup to `google.com` to verify actual internet access
- Exposes `hasConnection()` future and `onConnectivityChanged` stream

### ConnectionDialogService (`services/connection_dialog_service.dart`)
- Static utility class for showing no-internet dialogs
- `checkAndHandleConnection(context, onConnected)` — checks connection, shows dialog if offline
- `showNoInternetDialog(context, onRetry)` — displays retry dialog with:
  - Wifi-off icon
  - "لا يوجد اتصال بالإنترنت" title
  - Retry button that re-checks connection
  - Recursive dialog if still offline

### Where Connectivity is Checked

| Location | Trigger | Action |
|----------|---------|--------|
| `main.dart` | Stream listener | Shows SnackBar on connection loss |
| `home_screen.dart` | `_loadComplaints()` | Shows dialog if offline, blocks API call |
| `home_screen.dart` | Pull-to-refresh | Shows dialog if offline, blocks refresh |
| `add_complaint_screen.dart` | `_submitForm()` | Shows dialog if offline, blocks submission |

---

## State Management

### ComplaintProvider (`controller/complaint_provider.dart`)

Manages all complaint-related state:

```dart
class ComplaintProvider with ChangeNotifier {
  List<ComplaintModel> _complaints;      // Filtered list (displayed)
  List<ComplaintModel> _allComplaints;   // Full list (for filtering)
  bool _isLoading;
  String? _error;
  String? _activeFilterType;             // 'appName', 'department', 'empName'
  String? _activeFilterValue;
}
```

**Methods:**
- `fetchAllComplaints()` — GET all, stores in `_allComplaints`, applies active filter
- `createComplaint(complaint)` — POST, then re-fetches all
- `updateComplaint(id, complaint)` — PUT, then re-fetches all
- `deleteComplaint(id)` — DELETE, then re-fetches all
- `filterByAppName(name)` / `filterByDepartment(dept)` / `filterByEmpName(name)` — Client-side filtering
- `clearFilter()` — Reset to show all complaints
- `getUniqueAppNames()` / `getUniqueDepartments()` / `getUniqueEmpNames()` — Extract distinct values

### LookupProvider (`controller/lookup_provider.dart`)

Manages lookup/reference data for dropdowns:

```dart
class LookupProvider with ChangeNotifier {
  List<AboutAppModel> _aboutApps;
  List<PlaceItemModel> _placeItems;
  bool _isLoading;
  String? _error;
}
```

**Methods:**
- `fetchAllLookups()` — Fetches both lists in parallel using `Future.wait`
- `appNames` getter — Returns distinct app name strings
- `placeNames` getter — Returns distinct place name strings

### Provider Registration (`main.dart`)

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ComplaintProvider()),
    ChangeNotifierProvider(create: (_) => LookupProvider()),
  ],
  child: const MyApp(),
)
```

---

## Design System

### Color Palette (`utils/app_colors.dart`)

| Name | Hex | Usage |
|------|-----|-------|
| `primary` | `#769DAD` | Primary actions, app bar, buttons |
| `primaryDark` | `#5A7A8A` | Gradient end, emphasis |
| `primaryLight` | `#A8C8D8` | Gradient start, subtle backgrounds |
| `accent` | `#8CD6F7` | Secondary accent |
| `success` | `#4CAF50` | Success states, icons |
| `error` | `#F44336` | Errors, validation, toasts |
| `warning` | `#FF9800` | Warning states |
| `info` | `#2196F3` | Informational elements |
| `background` | `#F5F7FA` | Screen background |
| `card` | `#FFFFFF` | Card backgrounds |
| `textPrimary` | `#2C3E50` | Primary text |
| `textSecondary` | `#7F8C8D` | Secondary text |
| `border` | `#E0E0E0` | Input borders, dividers |

### Typography

- **Font Family**: Cairo (all text throughout the app)
- **App Title**: 20px, Bold, White
- **Section Headers**: 16px, Bold, `textPrimary`
- **Input Labels**: 14px, Regular, `textSecondary`
- **Input Text**: 14px, Regular, Black
- **Button Text**: 16-17px, Bold, White
- **Card Title**: 14px, SemiBold, `textPrimary`

### Theme Configuration (`utils/app_theme.dart`)

- Material 3 enabled
- Light brightness only (no dark mode)
- Rounded input borders (10px radius)
- Elevated buttons with primary color
- Floating action buttons with circle shape
- Bottom sheets with 20px top radius
- Floating snackbars with 10px radius

---

## Setup & Installation

### Prerequisites

- Flutter SDK >= 3.5.3
- Dart SDK >= 3.5.3
- Android Studio / VS Code with Flutter plugin
- Backend server running (see `tasks-complaint-emp/README.md`)

### Installation Steps

```bash
# 1. Navigate to the project directory
cd tasks_complaints

# 2. Install dependencies
flutter pub get

# 3. Run the application
flutter run -d chrome          # Web
flutter run -d <device_id>     # Android device/emulator
```

### Verify Installation

1. Ensure the backend is running at `http://localhost:9999/tasks-complaint-emp`
2. Launch the app — splash screen should animate for 4 seconds
3. Home screen should load complaints from the API
4. Tap FAB to open Add Complaint form
5. Verify dropdowns load data from `/api/about-apps` and `/api/place-items`

---

## Configuration

### Base URL

To change the backend server URL, edit `lib/network/dio_client.dart`:

```dart
static const String _baseUrl = 'http://localhost:9999/tasks-complaint-emp';
```

### Timeout Settings

In `dio_client.dart`:

```dart
connectTimeout: const Duration(seconds: 30),
receiveTimeout: const Duration(seconds: 30),
```

### Hardcoded Departments

The department dropdown is currently hardcoded in `add_complaint_screen.dart`:

```dart
static const List<String> _departments = [
  'ادارة البرامج وصيانتها'
];
```

To add more departments, edit this list or create a new lookup table in the backend.

---

## Build & Deployment

### Android APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Web

```bash
# Build for web
flutter build web

# Output: build/web/
# Serve with any static file server
```

### Build with Specific Flavor

```bash
flutter build apk --flavor production --target lib/main.dart
```

---

## Development Notes

### Code Conventions

- **Language**: Dart with strict analysis options
- **Naming**: camelCase for variables/functions, PascalCase for classes
- **Files**: snake_case for file names
- **Imports**: Relative imports within `lib/`
- **Comments**: Minimal — code is self-documenting
- **Arabic Text**: All user-facing strings are hardcoded in Arabic (no ARB localization files)

### Key Implementation Decisions

1. **No Authentication**: The API has no JWT/auth — CORS is enabled for Flutter Web
2. **Client-Side Filtering**: Complaints are fetched all at once, filtered locally via Provider
3. **Parallel Lookup Fetch**: `LookupProvider.fetchAllLookups()` uses `Future.wait` for both API calls
4. **Connectivity on Web**: Browser restrictions prevent DNS checks — trusts `connectivity_plus` result
5. **String Types for Numbers**: `empNumber` and `empMobile` are `String` to preserve leading zeros
6. **Singleton Services**: `DioClient` and `ConnectivityService` use factory constructor pattern

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

---

## Copyright

© 2026 Alexandria Water Company. All rights reserved.

Developed by the Technology and Digital Services Sector - Programs and Maintenance Department.

---

*This README was last updated on June 2026.*

# Implementation Plan: tasks_complaints Flutter App

## Overview

Build a Flutter app (`tasks_complaints`) to consume the `tasks-complaint-emp` REST API. The primary feature is **adding a new employee complaint** with a beautiful, responsive UI supporting Arabic language (RTL) for both Android and Web.

**API Base URL:** `http://localhost:9999/tasks-complaint-emp/api/emp-complaints`
**Theme:** Light-only (no dark mode)
**Filters:** Bottom sheet UI

---

## Project Structure (Following tasks_app Patterns)

```
tasks_complaints/lib/
├── main.dart
├── common_widgets/
│   ├── custom_widgets/
│   │   ├── custom_text.dart                  # Cairo-font text widget
│   │   ├── custom_text_field.dart            # Styled text field
│   │   ├── custom_button.dart                # Primary/secondary buttons
│   │   ├── custom_dropdown.dart              # Dropdown with Arabic labels
│   │   ├── custom_loading.dart               # Loading indicator
│   │   └── custom_complaint_card.dart        # Complaint display card
│   └── reusable_widgets.dart                 # Navigation helpers, gap(), showCustomBottomSheet()
├── controller/
│   └── complaint_provider.dart               # Complaint state management (ChangeNotifier)
├── models/
│   └── complaint_model.dart                  # Complaint data model
├── network/
│   ├── dio_client.dart                       # Singleton Dio HTTP client
│   └── complaint_api_repository.dart         # API calls for complaints
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart                # Splash with logo (3s delay)
│   ├── home/
│   │   └── home_screen.dart                  # Main screen - complaint list + add button
│   └── add_complaint/
│       └── add_complaint_screen.dart         # Add new complaint form
└── utils/
    ├── app_colors.dart                       # Color constants (light only)
    ├── app_theme.dart                        # Light Material3 theme only
    ├── app_route.dart                        # Route name constants
    └── app_assets.dart                       # Asset paths
```

---

## Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  dio: ^5.4.0                    # HTTP client
  provider: ^6.1.5+1             # State management
  connectivity_plus: ^7.0.0      # Network detection
  fluttertoast: ^8.2.8           # Toast notifications
  awesome_dialog: ^3.3.0         # Rich dialogs
  intl: ^0.20.2                  # Date formatting

flutter:
  fonts:
    - family: Cairo
      fonts:
        - asset: assets/fonts/Cairo-Regular.ttf
        - asset: assets/fonts/Cairo-Light.ttf
          weight: 300
        - asset: assets/fonts/Cairo-Medium.ttf
          weight: 500
        - asset: assets/fonts/Cairo-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Cairo-Bold.ttf
          weight: 700
```

Note: `shared_preferences` removed since no dark mode toggle needed. `CacheHelper` from tasks_app not required.

---

## Files to Create (Implementation Order)

### Phase 1: Foundation

#### 1. `utils/app_colors.dart`
Light-only color constants:
| Role | Color | Usage |
|------|-------|-------|
| Primary | `#769DAD` | AppBar, buttons, FAB |
| Primary Dark | `#5A7A8A` | Pressed states |
| Accent | `#8CD6F7` | Chips, highlights |
| Success | `#4CAF50` | Success dialogs, enabled chip |
| Error | `#F44336` | Validation errors, delete |
| Warning | `#FF9800` | Warning dialogs |
| Background | `#F5F7FA` | Screen background |
| Card | `#FFFFFF` | Card background |
| Text Primary | `#2C3E50` | Main text |
| Text Secondary | `#7F8C8D` | Hints, captions |
| Border | `#E0E0E0` | Borders, dividers |

#### 2. `utils/app_theme.dart`
Single `AppTheme.lightTheme` (no dark theme):
- Material3 enabled
- Cairo font family
- `ColorScheme.light` with primary: `#769DAD`
- Styled AppBar, Card, ElevatedButton, InputDecoration, FAB, BottomSheet

#### 3. `utils/app_route.dart`
```dart
class AppRoute {
  static const String splashRoute = '/';
  static const String homeRoute = '/home';
  static const String addComplaintRoute = '/add-complaint';
}
```

#### 4. `utils/app_assets.dart`
Asset paths for images/icons.

### Phase 2: Network Layer

#### 5. `network/dio_client.dart`
Singleton Dio client (same pattern as tasks_app):
- Base URL: `http://localhost:9999/tasks-complaint-emp`
- Connect/Receive timeout: 30s
- Content-Type: application/json
- Error interceptor:
  - 400 → extract validation error messages
  - 404 → "السجل غير موجود"
  - 500 → "خطأ في الخادم"
  - Timeout → "انتهت مهلة الاتصال"
  - No internet → "لا يوجد اتصال بالإنترنت"
- No auth interceptor (API has no JWT)

#### 6. `network/complaint_api_repository.dart`
```dart
class ComplaintApiRepository {
  Future<List<ComplaintModel>> getAllComplaints();
  Future<ComplaintModel> getComplaintById(int id);
  Future<ComplaintModel> createComplaint(ComplaintModel complaint);
  Future<ComplaintModel> updateComplaint(int id, ComplaintModel complaint);
  Future<void> deleteComplaint(int id);
  Future<List<ComplaintModel>> getByAppName(String appName);
  Future<List<ComplaintModel>> getByDepartment(String department);
  Future<List<ComplaintModel>> getByEmpName(String empName);
}
```

### Phase 3: Model & State

#### 7. `models/complaint_model.dart`
```dart
class ComplaintModel {
  final int? id;
  final String appName;
  final String complaintName;
  final String placeName;
  final String department;
  final String subPlace;
  final String empName;
  final int empNumber;
  final int empMobile;
  final bool isEnable;
  final DateTime? createdAt;

  // fromJson, toJson, copyWith
}
```

#### 8. `controller/complaint_provider.dart`
```dart
class ComplaintProvider with ChangeNotifier {
  List<ComplaintModel> _complaints = [];
  List<ComplaintModel> _filteredComplaints = [];
  bool _isLoading = false;
  String? _error;
  String? _activeFilter; // 'appName', 'department', 'empName', null

  // Getters
  List<ComplaintModel> get complaints => _filteredComplaints;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveFilter => _activeFilter != null;

  // Methods
  Future<void> fetchAllComplaints();
  Future<void> createComplaint(ComplaintModel complaint);
  Future<void> updateComplaint(int id, ComplaintModel complaint);
  Future<void> deleteComplaint(int id);
  void filterByAppName(String appName);
  void filterByDepartment(String department);
  void filterByEmpName(String empName);
  void clearFilter();
}
```

### Phase 4: Widgets

#### 9. `common_widgets/custom_widgets/custom_text.dart`
```dart
class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
}
```
Uses `style: TextStyle(fontFamily: 'Cairo', ...)`.

#### 10. `common_widgets/custom_widgets/custom_text_field.dart`
Styled TextFormField with:
- Arabic hint text
- RTL support (auto from Directionality)
- Validation (required, number, etc.)
- Icon prefix
- Rounded border matching theme

#### 11. `common_widgets/custom_widgets/custom_button.dart`
Primary ElevatedButton with:
- Loading state (CircularProgressIndicator)
- Full-width option
- Consistent with theme colors

#### 12. `common_widgets/custom_widgets/custom_dropdown.dart`
DropdownButtonFormField with:
- Arabic labels
- Default "اختر" (Choose) hint
- Validation

#### 13. `common_widgets/custom_widgets/custom_loading.dart`
Centered CircularProgressIndicator with optional message.

#### 14. `common_widgets/custom_widgets/custom_complaint_card.dart`
Card displaying:
- App name badge (top-left, colored chip)
- Complaint title (bold)
- Employee name + number
- Department + Place
- Status chip: "مفعل" (green) / "معطل" (red)
- Created date (formatted Arabic)
- Responsive layout

#### 15. `common_widgets/reusable_widgets.dart`
```dart
void navigateTo(BuildContext context, Widget widget) => Navigator.push(...);
void navigateToReplacement(BuildContext context, Widget widget) => Navigator.pushReplacement(...);
Widget gap(double height) => SizedBox(height: height);
void showCustomBottomSheet(BuildContext context, Widget child) => showModalBottomSheet(...);
```

### Phase 5: Screens

#### 16. `screens/splash/splash_screen.dart`
- Centered logo/icon + "شكاوى الموظفين" text
- Fade-in animation
- 3-second delay → navigate to HomeScreen
- Same pattern as tasks_app

#### 17. `screens/home/home_screen.dart`
**Main Screen - Complaint List:**
- **AppBar**:
  - Title: "شكاوى الموظفين"
  - Filter icon (opens filter bottom sheet)
  - Refresh icon (fetchAllComplaints)
- **Filter Bottom Sheet** (modal):
  - Title: "تصفية الشكاوى"
  - 3 dropdowns: تطبيق/نظام, القسم, اسم الموظف
  - "تطبيق" button (Apply)
  - "مسح" button (Clear filter)
  - Closes on apply
- **Body**:
  - Loading: Centered spinner
  - Error: Error message + retry
  - Empty: "لا توجد شكاوى" with icon
  - Data: ListView.builder (or GridView for tablet/web)
- **FAB**: "+" → navigate to AddComplaintScreen
- **Responsive**: LayoutBuilder with max-width constraint for web

#### 18. `screens/add_complaint/add_complaint_screen.dart`
**Main Feature - Add New Complaint Form:**
- **AppBar**: "إضافة شكوى جديدة" with back arrow
- **SingleChildScrollView** with padding
- **Form** (GlobalKey<FormState>):
  1. **تطبيق/نظام** (App Name) - Dropdown: ['اختر التطبيق', 'SAP', 'Oracle', 'Microsoft', 'Other']
  2. **اسم الشكوى** (Complaint Name) - Text field, required
  3. **المكان** (Place Name) - Dropdown: ['اختر المكان', 'المكتب الرئيسي', 'فرع مكتب', 'المخازن', 'الورشة']
  4. **القسم** (Department) - Dropdown: ['اختر القسم', 'IT', 'الموارد البشرية', 'المالية', 'الصيانة', 'الإدارة']
  5. **المكان الفرعي** (Sub Place) - Text field, optional, default "none"
  6. **اسم الموظف** (Employee Name) - Text field, required
  7. **رقم الموظف** (Employee Number) - Number keyboard, required
  8. **جوال الموظف** (Employee Mobile) - Number keyboard, required
- **Submit Button**: "حفظ الشكوى" with loading state
- **Success**: awesome_dialog with checkmark → Navigator.pop
- **Error**: Fluttertoast with error message
- **Responsive**: ConstrainedBox(maxWidth: 600) for web centering

### Phase 6: App Shell

#### 19. `main.dart`
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'شكاوى الموظفين',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('ar', 'SA'),
      // Force RTL
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      initialRoute: AppRoute.splashRoute,
      routes: {
        AppRoute.splashRoute: (_) => const SplashScreen(),
        AppRoute.homeRoute: (_) => const HomeScreen(),
        AppRoute.addComplaintRoute: (_) => const AddComplaintScreen(),
      },
    );
  }
}
```

---

## UI Design Details

### Responsive Breakpoints
| Device | Width | Layout |
|--------|-------|--------|
| Mobile | < 600px | Full-width cards, single column ListView |
| Tablet | 600-1024px | 2-column GridView, centered |
| Web/Desktop | > 1024px | Max-width 800px centered, 2-column GridView |

Implementation: `LayoutBuilder` in HomeScreen and AddComplaintScreen.

### Arabic UI Strings
| Key | Arabic |
|-----|--------|
| App Title | شكاوى الموظفين |
| Add Complaint | إضافة شكوى جديدة |
| App Name | تطبيق/نظام |
| Complaint Name | اسم الشكوى |
| Place | المكان |
| Department | القسم |
| Sub Place | المكان الفرعي |
| Employee Name | اسم الموظف |
| Employee Number | رقم الموظف |
| Employee Mobile | جوال الموظف |
| Save | حفظ الشكوى |
| Cancel | إلغاء |
| Delete | حذف |
| Filter | تصفية |
| Apply | تطبيق |
| Clear | مسح |
| All | الكل |
| No Complaints | لا توجد شكاوى |
| Success | تمت الإضافة بنجاح |
| Error | حدث خطأ |
| Confirm Delete | هل أنت متأكد من الحذف؟ |
| Loading | جاري التحميل... |
| Choose App | اختر التطبيق |
| Choose Place | اختر المكان |
| Choose Department | اختر القسم |
| Enabled | مفعل |
| Disabled | معطل |

---

## Testing Checklist

1. Splash screen loads → auto-navigates to home
2. Home screen shows empty state initially
3. FAB navigates to add complaint form
4. Form validation catches empty required fields
5. Dropdown defaults show "اختر" hint
6. Complaint created successfully → toast + list refresh
7. Complaint card shows all fields correctly
8. Filter bottom sheet opens with 3 dropdowns
9. Filter applies and updates list
10. Clear filter restores full list
11. Delete complaint with confirmation dialog
12. Pull-to-refresh works
13. RTL layout renders correctly
14. Responsive on mobile width (< 600px)
15. Responsive on web width (> 1024px)
16. Error handling: no internet → toast
17. Error handling: server down → toast

---

## Build & Run

```bash
cd tasks_complaints
flutter pub get
flutter run -d chrome      # Web
flutter run                 # Android
flutter build apk          # Build APK
flutter build web          # Build Web
```

---

## Summary

| Component | Count | Files |
|-----------|-------|-------|
| Utils | 4 | colors, theme, routes, assets |
| Network | 2 | dio_client, api_repository |
| Model | 1 | complaint_model |
| Controller | 1 | complaint_provider |
| Widgets | 7 | text, text_field, button, dropdown, loading, card, helpers |
| Screens | 3 | splash, home, add_complaint |
| Config | 1 | main.dart |
| **Total** | **19** | Complete complaint management app |

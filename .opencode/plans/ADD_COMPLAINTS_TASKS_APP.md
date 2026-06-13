# Add Complaints to tasks_app

## Problem
`manage_complmaints_screen.dart` imports 6 files that **don't exist** in `tasks_app`:
- `complaint_model.dart`
- `complaint_provider.dart`
- `custom_complaint_card.dart`
- `custom_loading.dart`
- `custom_dropdown.dart`
- Routes: `chatbotRoute`, `addComplaintRoute`

## Backend Gap
No `getByDepartmentAndIsEnable` endpoint exists. Need to add it.

---

## Step 1: Add Backend Endpoint

### TaskEmpComplaintRepository.java
Add:
```java
List<TaskEmpComplaint> findByDepartmentAndIsEnable(String department, Boolean isEnable);
```

### TaskEmpComplaintService.java + Impl
Add `getByDepartmentAndIsEnable(String department, Boolean isEnable)` method.

### TaskEmpComplaintController.java
Add endpoint:
```java
@GetMapping("/department/{department}/enable/{isEnable}")
public ResponseEntity<List<TaskEmpComplaintResponse>> getByDepartmentAndIsEnable(
        @PathVariable String department, @PathVariable Boolean isEnable)
```

---

## Step 2: Create Flutter Files in tasks_app

| # | File | Purpose |
|---|------|---------|
| 1 | `lib/models/complaint_model.dart` | ComplaintModel with `fromJson`/`toJson` |
| 2 | `lib/newtork_repos/remote_repo/api_repos/api_network_complaint_repos.dart` | Abstract repository |
| 3 | `lib/newtork_repos/remote_repo/api_repos/api_network_complaint_repos_impl.dart` | Implementation (separate DioClient for complaints API) |
| 4 | `lib/controller/complaint_provider.dart` | State management with CRUD |
| 5 | `lib/common_widgets/custom_widgets/custom_complaint_card.dart` | Complaint card widget |
| 6 | `lib/common_widgets/custom_widgets/custom_loading.dart` | Loading widget |
| 7 | `lib/common_widgets/custom_widgets/custom_dropdown.dart` | Dropdown widget |

---

## Step 3: Complaints DioClient

Since `tasks_app` DioClient points to `tasks-api` (port 8099) with auth, complaints API needs a **separate DioClient**:
- Base URL: `http://41.33.226.211:8099/tasks-complaint-emp`
- No auth tokens needed
- Simple error handling

---

## Step 4: Fix manage_complmaints_screen.dart

- Fix all broken imports
- Replace `fetchAllComplaints()` with `getByDepartmentAndIsEnable(department, isEnable)`
- Get department from `UserProvider.currentUser.department`
- Remove chatbot route reference (not in tasks_app)
- Keep CRUD operations (create, update, delete)

---

## Step 5: Update custom_drawer.dart

Add new drawer item at index 8:
```dart
_buildDrawerItem(
  index: 8,
  icon: Icons.report_problem_outlined,
  title: 'شكاوى الموظفين',
  onTap: () => Navigator.push(context, MaterialPageRoute(
    builder: (context) => const ManageComplaintsScreen(),
  )),
),
```

---

## Step 6: Update main.dart

Add `ComplaintProvider` to `MultiProvider`.

---

## Step 7: Update app_route.dart

Add route constant for complaints screen.

---

## Files to Create (7)

| # | File |
|---|------|
| 1 | `lib/models/complaint_model.dart` |
| 2 | `lib/newtork_repos/remote_repo/api_repos/api_network_complaint_repos.dart` |
| 3 | `lib/newtork_repos/remote_repo/api_repos/api_network_complaint_repos_impl.dart` |
| 4 | `lib/controller/complaint_provider.dart` |
| 5 | `lib/common_widgets/custom_widgets/custom_complaint_card.dart` |
| 6 | `lib/common_widgets/custom_widgets/custom_loading.dart` |
| 7 | `lib/common_widgets/custom_widgets/custom_dropdown.dart` |

## Files to Modify (5)

| # | File | Change |
|---|------|--------|
| 1 | `manage_complmaints_screen.dart` | Fix imports, use `getByDepartmentAndIsEnable` |
| 2 | `custom_drawer.dart` | Add complaints navigation item |
| 3 | `main.dart` | Add `ComplaintProvider` |
| 4 | `app_route.dart` | Add complaints route |
| 5 | Backend `TaskEmpComplaintController.java` | Add endpoint |

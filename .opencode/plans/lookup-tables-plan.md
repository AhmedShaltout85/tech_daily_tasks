# Plan: Add `about_app` and `place_item` Tables

## Overview
Add two new lookup tables to the backend and Flutter app, replacing hardcoded dropdown values with dynamic data from the API.

---

## Backend (tasks-complaint-emp)

### 1. Entity: `AboutApp.java`
**Path:** `src/main/java/com/a08r/tasks_emp_complaint/entity/AboutApp.java`

- Table: `about_app`
- Fields: `id` (Long, auto-increment), `appName` (String), `recommended` (String, nullable), `department` (String)
- Same Lombok pattern as `TaskEmpComplaint`: `@Getter`, `@Setter`, `@NoArgsConstructor`, `@AllArgsConstructor`, `@Builder`

### 2. Entity: `PlaceItem.java`
**Path:** `src/main/java/com/a08r/tasks_emp_complaint/entity/PlaceItem.java`

- Table: `place_item`
- Fields: `id` (Long, auto-increment), `placeName` (String)
- Same Lombok pattern

### 3. DTOs

**`AboutAppRequest.java`** — validation: `@NotBlank` on `appName` and `department`
**`AboutAppResponse.java`** — mirrors entity fields (id, appName, recommended, department)
**`PlaceItemRequest.java`** — validation: `@NotBlank` on `placeName`
**`PlaceItemResponse.java`** — mirrors entity fields (id, placeName)

### 4. Repositories

**`AboutAppRepository.java`** — extends `JpaRepository<AboutApp, Long>`
- `List<AboutApp> findByAppName(String appName)`
- `List<AboutApp> findByDepartment(String department)`

**`PlaceItemRepository.java`** — extends `JpaRepository<PlaceItem, Long>`
- `List<PlaceItem> findByPlaceName(String placeName)`

### 5. Services

**`AboutAppService.java`** (interface) + **`AboutAppServiceImpl.java`**
- CRUD: `createItem`, `getAllItems`, `getItemById`, `updateItem`, `deleteItem`
- Filters: `getByAppName`, `getByDepartment`
- `mapToResponse()` private helper

**`PlaceItemService.java`** (interface) + **`PlaceItemServiceImpl.java`**
- CRUD: `createItem`, `getAllItems`, `getItemById`, `updateItem`, `deleteItem`
- Filter: `getByPlaceName`
- `mapToResponse()` private helper

### 6. Controllers

**`AboutAppController.java`** — `@RequestMapping("/api/about-apps")`
- `POST /` → 201 CREATED
- `GET /` → 200 OK (all)
- `GET /{id}` → 200 OK
- `PUT /{id}` → 200 OK
- `DELETE /{id}` → 200 OK (MessageResponse)
- `GET /app/{appName}` → filter
- `GET /department/{department}` → filter

**`PlaceItemController.java`** — `@RequestMapping("/api/place-items")`
- `POST /` → 201 CREATED
- `GET /` → 200 OK (all)
- `GET /{id}` → 200 OK
- `PUT /{id}` → 200 OK
- `DELETE /{id}` → 200 OK (MessageResponse)
- `GET /place/{placeName}` → filter

### 7. Integration Tests

**`AboutAppIntegrationTest.java`** — CRUD + filter tests
**`PlaceItemIntegrationTest.java`** — CRUD + filter tests

---

## Flutter (tasks_complaints)

### 8. New Models

**`lib/models/about_app_model.dart`**
```dart
class AboutAppModel {
  final int? id;
  final String appName;
  final String? recommended;
  final String department;
  // fromJson, toJson, copyWith
}
```

**`lib/models/place_item_model.dart`**
```dart
class PlaceItemModel {
  final int? id;
  final String placeName;
  // fromJson, toJson, copyWith
}
```

### 9. New API Repository

**`lib/network/lookup_api_repository.dart`**
- `Future<List<AboutAppModel>> getAllAboutApps()`
- `Future<List<PlaceItemModel>> getAllPlaceItems()`

### 10. New Provider

**`lib/controller/lookup_provider.dart`** — `ChangeNotifier`
- `List<AboutAppModel> aboutApps`
- `List<PlaceItemModel> placeItems`
- `bool isLoading`
- `String? error`
- `Future<void> fetchAboutApps()`
- `Future<void> fetchPlaceItems()`
- `Future<void> fetchAllLookups()` — fetches both in parallel
- `List<String> get appNames` — extracts distinct appName strings
- `List<String> get placeNames` — extracts distinct placeName strings

### 11. Register Provider in `main.dart`

Add `LookupProvider` to `MultiProvider`:
```dart
ChangeNotifierProvider(create: (_) => LookupProvider()),
```

### 12. Update `add_complaint_screen.dart`

- Remove hardcoded `_appNames` and `_placeNames` lists
- In `initState`, call `context.read<LookupProvider>().fetchAllLookups()`
- Replace dropdown `items` with `Provider.of<LookupProvider>(context).appNames` and `.placeNames`
- Show loading indicator while lookup data is loading
- Keep `_departments` as hardcoded (not requested to change)

---

## Files to Create (20 new files)

| # | File | Type |
|---|------|------|
| 1 | `entity/AboutApp.java` | Backend entity |
| 2 | `entity/PlaceItem.java` | Backend entity |
| 3 | `dto/AboutAppRequest.java` | Backend DTO |
| 4 | `dto/AboutAppResponse.java` | Backend DTO |
| 5 | `dto/PlaceItemRequest.java` | Backend DTO |
| 6 | `dto/PlaceItemResponse.java` | Backend DTO |
| 7 | `repository/AboutAppRepository.java` | Backend repo |
| 8 | `repository/PlaceItemRepository.java` | Backend repo |
| 9 | `service/AboutAppService.java` | Backend service interface |
| 10 | `service/AboutAppServiceImpl.java` | Backend service impl |
| 11 | `service/PlaceItemService.java` | Backend service interface |
| 12 | `service/PlaceItemServiceImpl.java` | Backend service impl |
| 13 | `controller/AboutAppController.java` | Backend controller |
| 14 | `controller/PlaceItemController.java` | Backend controller |
| 15 | `AboutAppIntegrationTest.java` | Backend test |
| 16 | `PlaceItemIntegrationTest.java` | Backend test |
| 17 | `models/about_app_model.dart` | Flutter model |
| 18 | `models/place_item_model.dart` | Flutter model |
| 19 | `network/lookup_api_repository.dart` | Flutter API repo |
| 20 | `controller/lookup_provider.dart` | Flutter provider |

## Files to Modify (3 files)

| # | File | Change |
|---|------|--------|
| 1 | `main.dart` | Add `LookupProvider` to MultiProvider |
| 2 | `add_complaint_screen.dart` | Remove hardcoded lists, fetch from provider |
| 3 | `home_screen.dart` | If dropdowns use same lists, update them too |

## Implementation Order

1. Backend entities (AboutApp, PlaceItem)
2. Backend DTOs (Request + Response for both)
3. Backend repositories
4. Backend services (interface + impl)
5. Backend controllers
6. Backend tests — run `./mvnw test`
7. Flutter models
8. Flutter API repository
9. Flutter provider
10. Update `main.dart`
11. Update `add_complaint_screen.dart`
12. Run `flutter analyze`

# Chatbot Server - Implementation Plan

## Overview
Build a Spring Boot chatbot server with SQL Server backend and Flutter UI in the `tasks_complaints` app. The chatbot displays predefined IT/Technical support questions; the user taps a question to see the answer. No login, no Firebase — guest mode only.

---

## Part 1: Backend — Spring Boot `chatbot-server`

### Project Setup
- **Project name**: `chatbot-server`
- **Port**: `8080`
- **Context path**: `/chatbot-api`
- **Database**: SQL Server (same server as `tasks-complaint-emp`)
- **Base URL**: `http://localhost:8080/chatbot-api`

### Entity: `ChatbotQA`

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | BIGINT (auto-increment) | NO | Primary key |
| `question` | NVARCHAR(500) | NO | The question text shown to user |
| `answer` | NVARCHAR(MAX) | NO | The answer text shown after selection |
| `category` | NVARCHAR(255) | YES | Grouping (e.g., "General", "SAP", "Network") |
| `display_order` | INT | NO | Order to display questions (ascending) |
| `is_active` | BIT | NO | Enable/disable question without deleting |

### DTOs

**`ChatbotQARequest.java`**
- `question` — @NotBlank, @Size(max=500)
- `answer` — @NotBlank
- `category` — @Size(max=255), optional
- `displayOrder` — @NotNull
- `isActive` — default true

**`ChatbotQAResponse.java`**
- `id`, `question`, `answer`, `category`, `displayOrder`, `isActive`

### Repository: `ChatbotQARepository`
```java
List<ChatbotQA> findByIsActiveTrueOrderByDisplayOrderAsc();
List<ChatbotQA> findByCategoryAndIsActiveTrue(String category);
List<ChatbotQA> findByIsActiveTrue();
```

### Service: `ChatbotQAService` (interface) + `ChatbotQAServiceImpl`
- `getAllActiveQuestions()` — returns active questions ordered by displayOrder
- `getCategories()` — returns distinct categories of active questions
- `getAnswerById(Long id)` — returns full QA by id
- `getByCategory(String category)` — filter by category
- CRUD: `createItem`, `getAllItems`, `getItemById`, `updateItem`, `deleteItem`

### Controller: `ChatbotQAController`
**Base path**: `/api/chatbot`

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| `GET` | `/api/chatbot/questions` | Get all active questions (id, question, category, displayOrder) | No |
| `GET` | `/api/chatbot/questions/{id}` | Get full QA (question + answer) | No |
| `GET` | `/api/chatbot/categories` | Get distinct active categories | No |
| `GET` | `/api/chatbot/questions/category/{category}` | Filter by category | No |
| `GET` | `/api/chatbot/admin/all` | Get ALL questions (including inactive) | No |
| `POST` | `/api/chatbot/admin` | Create question | No |
| `PUT` | `/api/chatbot/admin/{id}` | Update question | No |
| `DELETE` | `/api/chatbot/admin/{id}` | Delete question | No |

### Integration Tests
- `ChatbotQAIntegrationTest.java` — CRUD + filter tests (same pattern as existing)

---

## Part 2: Frontend — Flutter `tasks_complaints`

### New Files

**`lib/models/chatbot_qa_model.dart`**
```dart
class ChatbotQAModel {
  final int? id;
  final String question;
  final String? answer;
  final String? category;
  final int displayOrder;
  final bool isActive;
  // fromJson, toJson, copyWith
}
```

**`lib/network/chatbot_api_repository.dart`**
- `Future<List<ChatbotQAModel>> getActiveQuestions()`
- `Future<ChatbotQAModel> getAnswerById(int id)`
- `Future<List<String>> getCategories()`
- `Future<List<ChatbotQAModel>> getByCategory(String category)`

**`lib/controller/chatbot_provider.dart`** — `ChangeNotifier`
- `List<ChatbotQAModel> questions` — active questions list
- `List<String> categories` — distinct categories
- `String? selectedCategory` — current filter
- `ChatbotQAModel? selectedQuestion` — question being answered
- `String? selectedAnswer` — answer text to display
- `bool isLoading`
- `String? error`
- `Future<void> fetchQuestions()`
- `Future<void> fetchCategories()`
- `Future<void> selectQuestion(int id)` — fetches answer by id
- `void clearAnswer()` — go back to question list
- `void filterByCategory(String? category)`

**`lib/screens/chatbot/chatbot_screen.dart`**

UI Layout:
```
┌─────────────────────────────┐
│  AppBar: "المساعد الذكي"     │
├─────────────────────────────┤
│  Category chips (horizontal │
│  scrollable filter bar)     │
├─────────────────────────────┤
│  Question list / Answer view│
│                             │
│  [If no question selected:] │
│  ┌─────────────────────┐    │
│  │ 💬 سؤال 1           │    │
│  └─────────────────────┘    │
│  ┌─────────────────────┐    │
│  │ 💬 سؤال 2           │    │
│  └─────────────────────┘    │
│  ┌─────────────────────┐    │
│  │ 💬 سؤال 3           │    │
│  └─────────────────────┘    │
│                             │
│  [If question selected:]    │
│  ┌─────────────────────┐    │
│  │ السؤال: ...          │    │
│  └─────────────────────┘    │
│  ┌─────────────────────┐    │
│  │ الإجابة: ...        │    │
│  └─────────────────────┘    │
│  [Back button]              │
└─────────────────────────────┘
```

### Modified Files

**`lib/main.dart`**
- Add `ChatbotProvider` to `MultiProvider`

**`lib/screens/home/home_screen.dart`**
- Add FAB or button to navigate to ChatbotScreen
- Or add a chatbot icon in the AppBar

### Chatbot Screen Flow
1. Screen opens → `fetchQuestions()` + `fetchCategories()`
2. User sees category chips at top (e.g., "الكل", "SAP", "الشبكات", "عام")
3. User taps a category → filters question list
4. User taps a question → `selectQuestion(id)` → shows answer card with:
   - Question text at top
   - Answer text below
   - "العودة" (Back) button to return to question list
5. Pull-to-refresh to reload questions

### Chatbot Card Design
- Question card: White card with chat icon, question text, tap arrow
- Answer card: Gradient header with question, answer body, back button
- Category chips: Filterable, highlighted when active
- Loading state: Spinner while fetching
- Empty state: "لا توجد أسئلة" message

---

## Part 3: Database Seed Data

### Categories

| # | Category |
|---|----------|
| 1 | منظومة المعامل |
| 2 | DMS منظومة |
| 3 | منظومة المخازن |
| 4 | منظومة الطوارئ |
| 5 | منظومة مسبق الدفع |
| 6 | منظومة الامن |
| 7 | منظومة الشئون القانونية |
| 8 | منظومة صيانة الحبارات |
| 9 | منظومة MASTER |
| 10 | منظومة العلاوات |
| 11 | منظومة صيانة ورشة العدادات |
| 12 | منظومة تسجيل الحضور والانصراف |
| 13 | اخرى |

### Default Seed Questions (sample per category)

| # | Question | Category |
|---|----------|----------|
| 1 | كيف أسجل معاملة جديدة في منظومة المعامل؟ | منظومة المعامل |
| 2 | كيف أتابع حالة المعاملة المقدمة؟ | منظومة المعامل |
| 3 | كيف أرفع مستند في منظومة DMS؟ | DMS منظومة |
| 4 | كيف أبحث عن مستند محفوظ في DMS؟ | DMS منظومة |
| 5 | كيف أسجل وارد جديد في المخازن؟ | منظومة المخازن |
| 6 | كيف أطلب صرف مواد من المخزن؟ | منظومة المخازن |
| 7 | كيف أبلاغ عن حالة طوارئ في المنظومة؟ | منظومة الطوارئ |
| 8 | كيف أتحقق من حالة بلاغ الطوارئ؟ | منظومة الطوارئ |
| 9 | كيف أسجل دفعة مسبقة الدفع؟ | منظومة مسبق الدفع |
| 10 | كيف أتابع حالة السداد؟ | منظومة مسبق الدفع |
| 11 | كيف أسجل حضوري في المنظومة؟ | منظومة تسجيل الحضور والانصراف |
| 12 | كيف أطلب صيانة لجهاز الحاسوب؟ | اخرى |
| 13 | كيف أغير كلمة المرور الخاصة بي؟ | اخرى |
| 14 | ما هي ساعات الدعم الفني؟ | اخرى |

---

## Files to Create

### Backend (16 files)
| # | File |
|---|------|
| 1 | `entity/ChatbotQA.java` |
| 2 | `dto/ChatbotQARequest.java` |
| 3 | `dto/ChatbotQAResponse.java` |
| 4 | `repository/ChatbotQARepository.java` |
| 5 | `service/ChatbotQAService.java` |
| 6 | `service/ChatbotQAServiceImpl.java` |
| 7 | `controller/ChatbotQAController.java` |
| 8 | `ChatbotQAIntegrationTest.java` |
| 9 | `REST_CLIENT.http` |
| 10 | `README.md` |

### Flutter (4 new files)
| # | File |
|---|------|
| 1 | `models/chatbot_qa_model.dart` |
| 2 | `network/chatbot_api_repository.dart` |
| 3 | `controller/chatbot_provider.dart` |
| 4 | `screens/chatbot/chatbot_screen.dart` |

### Flutter (2 modified files)
| # | File | Change |
|---|------|--------|
| 1 | `main.dart` | Add `ChatbotProvider` to MultiProvider |
| 2 | `home_screen.dart` | Add navigation button to ChatbotScreen |

---

## Implementation Order

1. Backend: Create Spring Boot project with entity, DTOs, repository
2. Backend: Create service interface + implementation
3. Backend: Create controller with all endpoints
4. Backend: Add seed data (SQL or data.sql)
5. Backend: Create integration tests — run `./mvnw test`
6. Flutter: Create model, API repository, provider
7. Flutter: Create chatbot screen with full UI
8. Flutter: Update main.dart and home_screen.dart
9. Flutter: Run `flutter analyze`
10. Test end-to-end flow

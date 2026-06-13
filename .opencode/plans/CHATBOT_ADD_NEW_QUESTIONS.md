# Chatbot Q&A - Adding New Questions

This document describes all the ways to add new questions and answers to the chatbot system.

---

## Method 1: SQL INSERT (Direct to Database)

The most straightforward way. Run SQL statements directly against the `tech_daily_tasks` database.

### Single Question

```sql
INSERT INTO chatbot_qa (question, answer, category, display_order, is_active)
VALUES ('your question here', 'your answer here', 'category name', 22, 1);
```

### Multiple Questions at Once

```sql
INSERT INTO chatbot_qa (question, answer, category, display_order, is_active)
VALUES 
('السؤال الأول', 'الجواب الأول', 'منظومة المعامل', 22, 1),
('السؤال الثاني', 'الجواب الثاني', 'DMS', 23, 1),
('السؤال الثالث', 'الجواب الثالث', 'المخازن', 24, 1);
```

### Verify the Insert

```sql
SELECT * FROM chatbot_qa ORDER BY display_order;
SELECT COUNT(*) FROM chatbot_qa;
```

### Disable a Question (Soft Delete)

```sql
UPDATE chatbot_qa SET is_active = 0 WHERE id = 1;
```

### Delete a Question Permanently

```sql
DELETE FROM chatbot_qa WHERE id = 1;
```

---

## Method 2: REST API (After Starting the Backend)

Start the chatbot backend first:

```bash
cd tasks-chatbot-qa
./mvnw spring-boot:run
```

The API will be available at: `http://localhost:8080/tasks-chatbot-qa`

### Create a New Question

```bash
curl -X POST http://localhost:8080/tasks-chatbot-qa/api/chatbot/admin \
  -H "Content-Type: application/json" \
  -d '{
    "question": "ما هي منظومة المعامل الإلكترونية؟",
    "answer": "منظومة المعامل الإلكترونية هي نظام لإدارة المعامل الإدارية",
    "category": "منظومة المعامل",
    "displayOrder": 22,
    "isActive": true
  }'
```

### Update an Existing Question

```bash
curl -X PUT http://localhost:8080/tasks-chatbot-qa/api/chatbot/admin/1 \
  -H "Content-Type: application/json" \
  -d '{
    "question": "السؤال المحدث",
    "answer": "الجواب المحدث",
    "category": "منظومة المعامل",
    "displayOrder": 1,
    "isActive": true
  }'
```

### Delete a Question

```bash
curl -X DELETE http://localhost:8080/tasks-chatbot-qa/api/chatbot/admin/1
```

### View All Questions (Admin - includes inactive)

```bash
curl http://localhost:8080/tasks-chatbot-qa/api/chatbot/admin/all
```

### View Active Questions Only

```bash
curl http://localhost:8080/tasks-chatbot-qa/api/chatbot/questions
```

### View All Categories

```bash
curl http://localhost:8080/tasks-chatbot-qa/api/chatbot/categories
```

### Filter Questions by Category

```bash
curl http://localhost:8080/tasks-chatbot-qa/api/chatbot/questions/category/منظومة%20المعامل
```

---

## Method 3: Postman / API Client

### Endpoint Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/chatbot/admin` | Create new Q&A |
| PUT | `/api/chatbot/admin/{id}` | Update existing Q&A |
| DELETE | `/api/chatbot/admin/{id}` | Delete Q&A |
| GET | `/api/chatbot/admin/all` | Get all (including inactive) |
| GET | `/api/chatbot/questions` | Get active questions |
| GET | `/api/chatbot/questions/{id}` | Get single Q&A by ID |
| GET | `/api/chatbot/categories` | Get distinct categories |
| GET | `/api/chatbot/questions/category/{category}` | Filter by category |

### Base URL

```
http://localhost:8080/tasks-chatbot-qa
```

### Request Body (JSON)

```json
{
  "question": "Your question in Arabic",
  "answer": "Your detailed answer in Arabic",
  "category": "Category Name",
  "displayOrder": 1,
  "isActive": true
}
```

### Field Validation Rules

| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| question | String | Yes | Max 500 characters |
| answer | String | Yes | No length limit |
| category | String | No | Max 255 characters |
| displayOrder | Integer | Yes | Order in the list |
| isActive | Boolean | No | Default: true |

---

## Method 4: Flutter App (Chatbot Screen)

Users can browse existing questions in the app at:

- Home Screen → Chat icon (💬) in AppBar → Chatbot Screen

The app reads questions from the API and displays them in categories.

---

## Available Categories

| # | Category |
|---|----------|
| 1 | منظومة المعامل |
| 2 | DMS |
| 3 | المخازن |
| 4 | الطوارئ |
| 5 | منظومة الرواتب |
| 6 | منظومة الموارد البشرية |
| 7 | منظومة المحاسبة |
| 8 | منظومة المبيعات |
| 9 | منظومة المشتريات |
| 10 | منظومة Inventor |
| 11 | منظومة AutoCAD |
| 12 | منظومة البريد الإلكتروني |
| 13 | منظومة الاتصالات |

You can also add new categories by simply using a new category name when creating a question.

---

## File Locations

| Component | Path |
|-----------|------|
| Backend Entity | `tasks-chatbot-qa/src/main/java/com/ao8r/tasks_chatbot_qa/entity/ChatbotQA.java` |
| Backend Controller | `tasks-chatbot-qa/src/main/java/com/ao8r/tasks_chatbot_qa/controller/ChatbotQAController.java` |
| Backend Service | `tasks-chatbot-qa/src/main/java/com/ao8r/tasks_chatbot_qa/service/ChatbotQAServiceImpl.java` |
| Backend Repository | `tasks-chatbot-qa/src/main/java/com/ao8r/tasks_chatbot_qa/repository/ChatbotQARepository.java` |
| Flutter Model | `tasks_complaints/lib/models/chatbot_qa_model.dart` |
| Flutter API Repo | `tasks_complaints/lib/network/chatbot_api_repository.dart` |
| Flutter Provider | `tasks_complaints/lib/controller/chatbot_provider.dart` |
| Flutter Screen | `tasks_complaints/lib/screens/chatbot/chatbot_screen.dart` |
| Application Properties | `tasks-chatbot-qa/src/main/resources/application.properties` |

---

## Quick Start

1. Start the chatbot backend on port 8080
2. Use any of the methods above to add questions
3. Open the Flutter app → tap the chat icon → browse categories → see new questions

```bash
# Start backend
cd tasks-chatbot-qa && ./mvnw spring-boot:run

# Add a question via curl
curl -X POST http://localhost:8080/tasks-chatbot-qa/api/chatbot/admin \
  -H "Content-Type: application/json" \
  -d '{"question":"ما هو؟","answer":"هذا اختبار","category":"DMS","displayOrder":30,"isActive":true}'
```

# API Test Script for tasks_api

## Base URL
BASE_URL=http://localhost:8080

# =====================================================
# Test Signup Endpoints (with department)
# =====================================================

echo "=== Testing Signup Endpoints ==="

# Signup Admin
echo -e "\n1. Signup Admin:"
curl -s -X POST "$BASE_URL/api/auth/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "displayName": "System Administrator",
    "username": "admin",
    "password": "admin123",
    "role": "ADMIN",
    "department": "IT"
  }'

# Signup Manager
echo -e "\n\n2. Signup Manager:"
curl -s -X POST "$BASE_URL/api/auth/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "displayName": "Test Manager",
    "username": "manager",
    "password": "manager123",
    "role": "MANAGER",
    "department": "HR"
  }'

# Signup User
echo -e "\n\n3. Signup User:"
curl -s -X POST "$BASE_URL/api/auth/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "displayName": "Test User",
    "username": "user",
    "password": "user123",
    "role": "USER",
    "department": "Sales"
  }'

# =====================================================
# Test Signin Endpoints
# =====================================================

echo -e "\n\n\n=== Testing Signin Endpoints ==="

# Signin Admin
echo -e "\n1. Signin Admin:"
curl -s -X POST "$BASE_URL/api/auth/signin" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123"
  }'

# Signin Manager
echo -e "\n\n2. Signin Manager:"
curl -s -X POST "$BASE_URL/api/auth/signin" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "manager",
    "password": "manager123"
  }'

# Signin User
echo -e "\n\n3. Signin User:"
curl -s -X POST "$BASE_URL/api/auth/signin" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "user",
    "password": "user123"
  }'

# =====================================================
# Test Protected Endpoints
# =====================================================

echo -e "\n\n\n=== Testing Protected Endpoints ==="

# Get Admin Token first
ADMIN_TOKEN=$(curl -s -X POST "$BASE_URL/api/auth/signin" \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}' | grep -o '"token":"[^"]*' | cut -d'"' -f4)

# Get User Token first
USER_TOKEN=$(curl -s -X POST "$BASE_URL/api/auth/signin" \
  -H "Content-Type: application/json" \
  -d '{"username": "user", "password": "user123"}' | grep -o '"token":"[^"]*' | cut -d'"' -f4)

# Test Public Endpoint (no auth required)
echo -e "\n1. Public Endpoint (no auth):"
curl -s "$BASE_URL/api/test/public"

# Test User Endpoint (USER role required)
echo -e "\n\n2. User Endpoint (with USER token):"
curl -s "$BASE_URL/api/test/user" \
  -H "Authorization: Bearer $USER_TOKEN"

# Test Admin Endpoint with User Token (should fail)
echo -e "\n\n3. Admin Endpoint (with USER token - should fail):"
curl -s "$BASE_URL/api/test/admin" \
  -H "Authorization: Bearer $USER_TOKEN"

# Test Admin Endpoint with Admin Token (should succeed)
echo -e "\n\n4. Admin Endpoint (with ADMIN token - should succeed):"
curl -s "$BASE_URL/api/test/admin" \
  -H "Authorization: Bearer $ADMIN_TOKEN"

echo -e "\n\n\n=== All Tests Complete ==="

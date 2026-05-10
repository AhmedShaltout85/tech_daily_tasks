@echo off
REM API Test Script for tasks_api (Windows)

set BASE_URL=http://localhost:8080

echo === Testing Signup Endpoints ===

echo.
echo 1. Signup Admin:
curl -s -X POST "%BASE_URL%/api/auth/signup" -H "Content-Type: application/json" -d "{\"displayName\": \"System Administrator\", \"username\": \"admin\", \"password\": \"admin123\", \"role\": \"ADMIN\"}"

echo.
echo 2. Signup Manager:
curl -s -X POST "%BASE_URL%/api/auth/signup" -H "Content-Type: application/json" -d "{\"displayName\": \"Test Manager\", \"username\": \"manager\", \"password\": \"manager123\", \"role\": \"MANAGER\"}"

echo.
echo 3. Signup User:
curl -s -X POST "%BASE_URL%/api/auth/signup" -H "Content-Type: application/json" -d "{\"displayName\": \"Test User\", \"username\": \"user\", \"password\": \"user123\", \"role\": \"USER\"}"

echo.
echo === Testing Signin Endpoints ===

echo.
echo 1. Signin Admin:
curl -s -X POST "%BASE_URL%/api/auth/signin" -H "Content-Type: application/json" -d "{\"username\": \"admin\", \"password\": \"admin123\"}"

echo.
echo 2. Signin Manager:
curl -s -X POST "%BASE_URL%/api/auth/signin" -H "Content-Type: application/json" -d "{\"username\": \"manager\", \"password\": \"manager123\"}"

echo.
echo 3. Signin User:
curl -s -X POST "%BASE_URL%/api/auth/signin" -H "Content-Type: application/json" -d "{\"username\": \"user\", \"password\": \"user123\"}"

echo.
echo === All Tests Complete ===
pause

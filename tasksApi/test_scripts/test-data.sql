-- =====================================================
-- Test Data for tasks_api
-- Run this script after creating the database
-- =====================================================

USE tech_daily_tasks;
GO

-- Insert test users (password is 'test123' encoded with BCrypt)
-- BCrypt encoding for 'test123' = $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy

-- Admin user
INSERT INTO users (display_name, username, password, role, is_enabled, created_at)
VALUES 
(
    'System Administrator',
    'admin',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    'ADMIN',
    1,
    GETDATE()
);

-- Manager user
INSERT INTO users (display_name, username, password, role, is_enabled, created_at)
VALUES 
(
    'Test Manager',
    'manager',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    'MANAGER',
    1,
    GETDATE()
);

-- General Manager user
INSERT INTO users (display_name, username, password, role, is_enabled, created_at)
VALUES 
(
    'Test General Manager',
    'generalmanager',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    'GENERAL_MANAGER',
    1,
    GETDATE()
);

-- Sector Manager user
INSERT INTO users (display_name, username, password, role, is_enabled, created_at)
VALUES 
(
    'Test Sector Manager',
    'sectormanager',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    'SECTOR_MANAGER',
    1,
    GETDATE()
);

-- Regular user
INSERT INTO users (display_name, username, password, role, is_enabled, created_at)
VALUES 
(
    'Test User',
    'user',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    'USER',
    1,
    GETDATE()
);

-- =====================================================
-- Test Credentials
-- =====================================================
-- All users use password: test123
--
-- Username      | Role
-- --------------|------------------
-- admin         | ADMIN
-- manager       | MANAGER
-- generalmanager| GENERAL_MANAGER
-- sectormanager | SECTOR_MANAGER
-- user          | USER
-- =====================================================

-- Verify inserted data
SELECT id, display_name, username, role, is_enabled, created_at 
FROM users;

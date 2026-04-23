CREATE TABLE task_users (
    id          BIGINT IDENTITY(1,1) PRIMARY KEY,
    display_name NVARCHAR(255)     NOT NULL,
    username     NVARCHAR(255)     NOT NULL UNIQUE,
    password    NVARCHAR(255)     NOT NULL,
    is_enable    BIT               NOT NULL DEFAULT 1,
    role        NVARCHAR(255)     NOT NULL,
    department  NVARCHAR(255)    NOT NULL,
    created_at   DATETIME2         NOT NULL DEFAULT GETUTCDATE()
);



--
CREATE TABLE daily_task (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    task_title NVARCHAR(255) NOT NULL,
    task_status BIT NOT NULL,
    app_name NVARCHAR(255) NOT NULL,
    visit_place NVARCHAR(255) NOT NULL,
    sub_place   NVARCHAR(255) NOT NULL DEFAULT 'none',
    assigned_to NVARCHAR(255) NOT NULL,
    assigned_by NVARCHAR(255) NOT NULL,
    co_operator NVARCHAR(255)  NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NULL,
    expected_completion_date DATETIME2 NOT NULL,
    task_priority NVARCHAR(50) NOT NULL,
    task_note NVARCHAR(MAX) NULL DEFAULT 'none',
    is_remote BIT NOT NULL DEFAULT 0
);
--
CREATE TABLE daily_task_co_operator (
    daily_task_id BIGINT NOT NULL,
    co_operator NVARCHAR(255) NOT NULL,
    CONSTRAINT fk_daily_task FOREIGN KEY (daily_task_id) REFERENCES daily_task(id)
);

--
CREATE TABLE about_app (
    id          BIGINT        IDENTITY(1,1)  PRIMARY KEY,
    app_name    NVARCHAR(255)                NOT NULL,
    recommended NVARCHAR(255)                NULL,
    department  NVARCHAR(255)                NOT NULL
);
--
-- Create the recommended values table (stores list of strings)
CREATE TABLE about_app_recommended (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    about_app_id BIGINT NOT NULL,
    recommended_value NVARCHAR(255) NOT NULL,
    CONSTRAINT fk_about_app FOREIGN KEY (about_app_id) 
        REFERENCES about_app(id) ON DELETE CASCADE
);
--
CREATE TABLE place_item (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    place_name VARCHAR(255) NOT NULL
);
--
CREATE TABLE preventive_item (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    app_name NVARCHAR(255) NOT NULL,
    action NVARCHAR(255) NOT NULL
);
--
CREATE TABLE preventive_maintenance (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    app_name VARCHAR(255) NOT NULL,
    action VARCHAR(255) NOT NULL,
    username VARCHAR(255) NOT NULL,
    place_name VARCHAR(255) NOT NULL,
    sub_place   NVARCHAR(255) NOT NULL DEFAULT 'none',
    is_remote BIT NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
);


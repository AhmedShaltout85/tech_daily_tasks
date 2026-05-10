CREATE TABLE daily_task (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    task_title NVARCHAR(255) NOT NULL,
    task_status BIT NOT NULL,
    app_name NVARCHAR(255) NOT NULL,
    visit_place NVARCHAR(255) NOT NULL,
    sub_place   NVARCHAR(255) NOT NULL DEFAULT 'none',
    assigned_to NVARCHAR(255) NOT NULL,
    assigned_by NVARCHAR(255) NOT NULL,
    co_operator NVARCHAR(255) NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NULL,
    expected_completion_date DATETIME2 NOT NULL,
    task_priority NVARCHAR(50) NOT NULL,
    task_note NVARCHAR(MAX) NULL DEFAULT 'none',
    is_remote BIT NOT NULL DEFAULT 0
);

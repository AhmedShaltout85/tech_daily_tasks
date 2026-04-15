--create users table
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

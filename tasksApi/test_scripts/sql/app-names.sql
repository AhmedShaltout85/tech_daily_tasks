CREATE TABLE apps_name (
    id          BIGINT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    app_name    NVARCHAR(255) NOT NULL,
    department    NVARCHAR(255) NOT NULL
);

CREATE TABLE preventive_item (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    app_name NVARCHAR(255) NOT NULL,
    action NVARCHAR(255) NOT NULL
);

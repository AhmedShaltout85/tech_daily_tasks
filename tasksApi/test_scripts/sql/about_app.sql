CREATE TABLE about_app (
    id          BIGINT        IDENTITY(1,1)  PRIMARY KEY,
    app_name    NVARCHAR(255)                NOT NULL,
    recommended NVARCHAR(255)                NOT NULL
);

CREATE TABLE about_app_recommended (
    id          BIGINT        IDENTITY(1,1)  PRIMARY KEY,
    app_name   NVARCHAR(255)                NOT NULL,
    recommended_value NVARCHAR(255)            NOT NULL
);
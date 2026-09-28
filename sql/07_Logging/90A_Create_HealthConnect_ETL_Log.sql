USE dev_HealthConnect_raw;
GO

CREATE TABLE dbo.HealthConnect_ETL_Log
(
    Run_ID BIGINT IDENTITY(1,1) PRIMARY KEY,

    Process_Name NVARCHAR(200) NOT NULL,

    Start_Time DATETIME2(0) NOT NULL,

    End_Time DATETIME2(0) NULL,

    Status NVARCHAR(20) NOT NULL,

    Row_Count INT NULL,

    Error_Message NVARCHAR(MAX) NULL
);
GO
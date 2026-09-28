USE dev_HealthConnect_raw;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_ETL_Log_Insert
    @Process_Name NVARCHAR(200),
    @Start_Time DATETIME2(0),
    @End_Time DATETIME2(0) = NULL,
    @Status NVARCHAR(20),
    @Row_Count INT = NULL,
    @Error_Message NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.HealthConnect_ETL_Log
    (
        Process_Name,
        Start_Time,
        End_Time,
        Status,
        Row_Count,
        Error_Message
    )
    VALUES
    (
        @Process_Name,
        @Start_Time,
        @End_Time,
        @Status,
        @Row_Count,
        @Error_Message
    );

    SELECT
        SCOPE_IDENTITY() AS Run_ID,
        'SUCCESS' AS Status,
        'ETL log inserted successfully.' AS Message;
END;
GO


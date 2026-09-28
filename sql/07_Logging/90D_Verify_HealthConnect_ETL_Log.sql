USE dev_HealthConnect_raw;
GO

SELECT TOP 10
    Run_ID,
    Process_Name,
    Start_Time,
    End_Time,
    Status,
    Row_Count,
    Error_Message
FROM dbo.HealthConnect_ETL_Log
ORDER BY Run_ID DESC;
GO

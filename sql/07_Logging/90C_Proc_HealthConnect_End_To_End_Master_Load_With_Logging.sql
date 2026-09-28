USE dev_HealthConnect_raw;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_End_To_End_Master_Load_With_Logging
    @PatientsFilePath NVARCHAR(1000),
    @ProvidersFilePath NVARCHAR(1000),
    @PayersFilePath NVARCHAR(1000),
    @EncountersFilePath NVARCHAR(1000),
    @DiagnosesFilePath NVARCHAR(1000),
    @ProceduresFilePath NVARCHAR(1000),
    @MedicationsFilePath NVARCHAR(1000),
    @ClaimsFilePath NVARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @StartTime DATETIME2(0) = GETDATE();
    DECLARE @EndTime DATETIME2(0);
    DECLARE @ErrorMessage NVARCHAR(MAX) = NULL;

    BEGIN TRY
        EXEC dbo.Proc_HealthConnect_End_To_End_Master_Load
            @PatientsFilePath = @PatientsFilePath,
            @ProvidersFilePath = @ProvidersFilePath,
            @PayersFilePath = @PayersFilePath,
            @EncountersFilePath = @EncountersFilePath,
            @DiagnosesFilePath = @DiagnosesFilePath,
            @ProceduresFilePath = @ProceduresFilePath,
            @MedicationsFilePath = @MedicationsFilePath,
            @ClaimsFilePath = @ClaimsFilePath;

        SET @EndTime = GETDATE();

        INSERT INTO dbo.HealthConnect_ETL_Log
        (
            Process_Name,
            Start_Time,
            End_Time,
            Status,
            Row_Count,
            Error_Message
        )
        SELECT
            'HealthConnect End-to-End Pipeline',
            @StartTime,
            @EndTime,
            'SUCCESS',
            (SELECT COUNT(*) FROM dev_HealthConnect_raw.dbo.raw_patients)
            + (SELECT COUNT(*) FROM dev_HealthConnect_raw.dbo.raw_providers)
            + (SELECT COUNT(*) FROM dev_HealthConnect_raw.dbo.raw_payers)
            + (SELECT COUNT(*) FROM dev_HealthConnect_raw.dbo.raw_encounters)
            + (SELECT COUNT(*) FROM dev_HealthConnect_raw.dbo.raw_diagnoses)
            + (SELECT COUNT(*) FROM dev_HealthConnect_raw.dbo.raw_procedures)
            + (SELECT COUNT(*) FROM dev_HealthConnect_raw.dbo.raw_medications)
            + (SELECT COUNT(*) FROM dev_HealthConnect_raw.dbo.raw_claims),
            NULL;

        SELECT
            'SUCCESS' AS Status,
            'End-to-End pipeline completed and logged successfully.' AS Message;
    END TRY
    BEGIN CATCH
        SET @EndTime = GETDATE();
        SET @ErrorMessage = ERROR_MESSAGE();

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
            'HealthConnect End-to-End Pipeline',
            @StartTime,
            @EndTime,
            'FAILED',
            0,
            @ErrorMessage
        );

        SELECT
            'FAILED' AS Status,
            @ErrorMessage AS Error_Message;

        THROW;
    END CATCH
END;
GO

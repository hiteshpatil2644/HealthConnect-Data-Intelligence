USE dev_HealthConnect_raw;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Source_To_Raw_Master_Load
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

    BEGIN TRY

        EXEC dbo.Proc_HealthConnect_Source_To_Raw_Patients_Load
            @FilePath = @PatientsFilePath;

        EXEC dbo.Proc_HealthConnect_Source_To_Raw_Providers_Load
            @FilePath = @ProvidersFilePath;

        EXEC dbo.Proc_HealthConnect_Source_To_Raw_Payers_Load
            @FilePath = @PayersFilePath;

        EXEC dbo.Proc_HealthConnect_Source_To_Raw_Encounters_Load
            @FilePath = @EncountersFilePath;

        EXEC dbo.Proc_HealthConnect_Source_To_Raw_Diagnoses_Load
            @FilePath = @DiagnosesFilePath;

        EXEC dbo.Proc_HealthConnect_Source_To_Raw_Procedures_Load
            @FilePath = @ProceduresFilePath;

        EXEC dbo.Proc_HealthConnect_Source_To_Raw_Medications_Load
            @FilePath = @MedicationsFilePath;

        EXEC dbo.Proc_HealthConnect_Source_To_Raw_Claims_Load
            @FilePath = @ClaimsFilePath;

        SELECT
            'SUCCESS' AS Status,
            'SOURCE to RAW master load completed successfully.' AS Message;

    END TRY

    BEGIN CATCH

        SELECT
            'FAILED' AS Status,
            ERROR_NUMBER() AS Error_Number,
            ERROR_MESSAGE() AS Error_Message;

        THROW;

    END CATCH
END;
GO

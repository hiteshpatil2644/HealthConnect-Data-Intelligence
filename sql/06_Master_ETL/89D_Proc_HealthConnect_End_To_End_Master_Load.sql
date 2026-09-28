USE dev_HealthConnect_raw;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_End_To_End_Master_Load
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

    BEGIN TRY

        -------------------------------------------------
        -- STEP 1: SOURCE → RAW
        -------------------------------------------------

        EXEC dev_HealthConnect_raw.dbo
            .Proc_HealthConnect_Source_To_Raw_Master_Load
            @PatientsFilePath = @PatientsFilePath,
            @ProvidersFilePath = @ProvidersFilePath,
            @PayersFilePath = @PayersFilePath,
            @EncountersFilePath = @EncountersFilePath,
            @DiagnosesFilePath = @DiagnosesFilePath,
            @ProceduresFilePath = @ProceduresFilePath,
            @MedicationsFilePath = @MedicationsFilePath,
            @ClaimsFilePath = @ClaimsFilePath;


        -------------------------------------------------
        -- STEP 2: RAW → CLEANSED
        -------------------------------------------------

        EXEC dev_HealthConnect_cleansed.dbo
            .Proc_HealthConnect_Raw_To_Cleansed_Master_Load;


        -------------------------------------------------
        -- STEP 3: CLEANSED → REFINED
        -------------------------------------------------

        EXEC dev_HealthConnect_refined.dbo
            .Proc_HealthConnect_Cleansed_To_Refined_Master_Load;


        -------------------------------------------------
        -- FINAL SUCCESS
        -------------------------------------------------

        SELECT
            'SUCCESS' AS Status,
            'HealthConnect End-to-End pipeline completed successfully.'
                AS Message;

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

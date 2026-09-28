USE dev_HealthConnect_cleansed;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Raw_To_Cleansed_Master_Load
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        ------------------------------------------------------------
        -- 1. PATIENTS
        ------------------------------------------------------------
        EXEC dbo.Proc_HealthConnect_Raw_To_Cleansed_Patients_Load;


        ------------------------------------------------------------
        -- 2. PROVIDERS
        ------------------------------------------------------------
        EXEC dbo.Proc_HealthConnect_Raw_To_Cleansed_Providers_Load;


        ------------------------------------------------------------
        -- 3. PAYERS
        ------------------------------------------------------------
        EXEC dbo.Proc_HealthConnect_Raw_To_Cleansed_Payers_Load;


        ------------------------------------------------------------
        -- 4. ENCOUNTERS
        ------------------------------------------------------------
        EXEC dbo.Proc_HealthConnect_Raw_To_Cleansed_Encounters_Load;


        ------------------------------------------------------------
        -- 5. DIAGNOSES
        ------------------------------------------------------------
        EXEC dbo.Proc_HealthConnect_Raw_To_Cleansed_Diagnoses_Load;


        ------------------------------------------------------------
        -- 6. PROCEDURES
        ------------------------------------------------------------
        EXEC dbo.Proc_HealthConnect_Raw_To_Cleansed_Procedures_Load;


        ------------------------------------------------------------
        -- 7. MEDICATIONS
        ------------------------------------------------------------
        EXEC dbo.Proc_HealthConnect_Raw_To_Cleansed_Medications_Load;


        ------------------------------------------------------------
        -- 8. CLAIMS
        ------------------------------------------------------------
        EXEC dbo.Proc_HealthConnect_Raw_To_Cleansed_Claims_Load;


        ------------------------------------------------------------
        -- SUCCESS
        ------------------------------------------------------------
        SELECT
            'SUCCESS' AS Status,
            'RAW to CLEANSED master load completed successfully.'
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

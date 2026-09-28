USE dev_HealthConnect_refined;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Cleansed_To_Refined_Master_Load
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        EXEC dbo.Proc_HealthConnect_Cleansed_To_Refined_Patients_Load;

        EXEC dbo.Proc_HealthConnect_Cleansed_To_Refined_Providers_Load;

        EXEC dbo.Proc_HealthConnect_Cleansed_To_Refined_Payers_Load;

        EXEC dbo.Proc_HealthConnect_Cleansed_To_Refined_Encounters_Load;

        EXEC dbo.Proc_HealthConnect_Cleansed_To_Refined_Diagnoses_Load;

        EXEC dbo.Proc_HealthConnect_Cleansed_To_Refined_Procedures_Load;

        EXEC dbo.Proc_HealthConnect_Cleansed_To_Refined_Medications_Load;

        EXEC dbo.Proc_HealthConnect_Cleansed_To_Refined_Claims_Load;

        SELECT
            'SUCCESS' AS Status,
            'CLEANSED to REFINED master load completed successfully.'
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

USE dev_HealthConnect_cleansed;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Raw_To_Cleansed_Diagnoses_Load
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        ------------------------------------------------------------
        -- 1. Clear CLEANSED table
        ------------------------------------------------------------
        TRUNCATE TABLE dbo.cleansed_diagnoses;

        ------------------------------------------------------------
        -- 2. Load RAW → CLEANSED
        --    TRIM + UPPERCASE strings
        --    Add Load_Date
        ------------------------------------------------------------
        INSERT INTO dbo.cleansed_diagnoses
        (
            diagnosis_id,
            encounter_id,
            diagnosis_description,
            is_primary,
            load_date
        )
        SELECT
            diagnosis_id,
            encounter_id,
            UPPER(TRIM(diagnosis_description)),
            is_primary,
            GETDATE()
        FROM dev_HealthConnect_raw.dbo.raw_diagnoses;

        ------------------------------------------------------------
        -- 3. Commit
        ------------------------------------------------------------
        COMMIT TRANSACTION;

        ------------------------------------------------------------
        -- 4. Success result
        ------------------------------------------------------------
        SELECT
            'SUCCESS' AS Status,
            'Diagnoses RAW to CLEANSED load completed successfully.' AS Message,
            COUNT(*) AS Row_Count
        FROM dbo.cleansed_diagnoses;

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
            'FAILED' AS Status,
            ERROR_NUMBER() AS Error_Number,
            ERROR_MESSAGE() AS Error_Message;

        THROW;

    END CATCH
END;
GO

USE dev_HealthConnect_cleansed;
GO

EXEC dbo.Proc_HealthConnect_Raw_To_Cleansed_Diagnoses_Load;
GO
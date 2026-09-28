USE dev_HealthConnect_cleansed;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Raw_To_Cleansed_Encounters_Load
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        ------------------------------------------------------------
        -- 1. Clear CLEANSED table
        ------------------------------------------------------------
        TRUNCATE TABLE dbo.cleansed_encounters;

        ------------------------------------------------------------
        -- 2. Load RAW → CLEANSED
        --    TRIM + UPPERCASE strings
        --    Add Load_Date
        ------------------------------------------------------------
        INSERT INTO dbo.cleansed_encounters
        (
            encounter_id,
            patient_id,
            provider_id,
            encounter_type,
            encounter_start,
            encounter_end,
            height_cm,
            weight_kg,
            systolic_bp,
            diastolic_bp,
            load_date
        )
        SELECT
            encounter_id,
            patient_id,
            provider_id,
            UPPER(TRIM(encounter_type)),
            encounter_start,
            encounter_end,
            height_cm,
            weight_kg,
            systolic_bp,
            diastolic_bp,
            GETDATE()
        FROM dev_HealthConnect_raw.dbo.raw_encounters;

        ------------------------------------------------------------
        -- 3. Commit
        ------------------------------------------------------------
        COMMIT TRANSACTION;

        ------------------------------------------------------------
        -- 4. Success result
        ------------------------------------------------------------
        SELECT
            'SUCCESS' AS Status,
            'Encounters RAW to CLEANSED load completed successfully.' AS Message,
            COUNT(*) AS Row_Count
        FROM dbo.cleansed_encounters;

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

EXEC dbo.Proc_HealthConnect_Raw_To_Cleansed_Encounters_Load;
GO
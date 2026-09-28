USE dev_HealthConnect_cleansed;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Raw_To_Cleansed_Providers_Load
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        ------------------------------------------------------------
        -- 1. Clear CLEANSED table
        ------------------------------------------------------------
        TRUNCATE TABLE dbo.cleansed_providers;

        ------------------------------------------------------------
        -- 2. Load RAW → CLEANSED
        --    TRIM + UPPERCASE strings
        --    Add Load_Date
        ------------------------------------------------------------
        INSERT INTO dbo.cleansed_providers
        (
            provider_id,
            first_name,
            last_name,
            specialty,
            npi,
            load_date
        )
        SELECT
            provider_id,
            UPPER(TRIM(first_name)),
            UPPER(TRIM(last_name)),
            UPPER(TRIM(specialty)),
            TRIM(npi),
            GETDATE()
        FROM dev_HealthConnect_raw.dbo.raw_providers;

        ------------------------------------------------------------
        -- 3. Commit
        ------------------------------------------------------------
        COMMIT TRANSACTION;

        ------------------------------------------------------------
        -- 4. Success result
        ------------------------------------------------------------
        SELECT
            'SUCCESS' AS Status,
            'Providers RAW to CLEANSED load completed successfully.' AS Message,
            COUNT(*) AS Row_Count
        FROM dbo.cleansed_providers;

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

EXEC dbo.Proc_HealthConnect_Raw_To_Cleansed_Providers_Load;
GO
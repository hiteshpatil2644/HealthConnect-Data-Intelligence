USE dev_HealthConnect_cleansed;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Raw_To_Cleansed_Claims_Load
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        ------------------------------------------------------------
        -- 1. Clear CLEANSED table
        ------------------------------------------------------------
        TRUNCATE TABLE dbo.cleansed_claims;

        ------------------------------------------------------------
        -- 2. Load RAW → CLEANSED
        --    TRIM + UPPERCASE strings
        --    Add Load_Date
        ------------------------------------------------------------
        INSERT INTO dbo.cleansed_claims
        (
            claim_id,
            encounter_id,
            payer_id,
            admit_date,
            discharge_date,
            total_billed_amount,
            total_allowed_amount,
            total_paid_amount,
            claim_status,
            load_date
        )
        SELECT
            claim_id,
            encounter_id,
            payer_id,
            admit_date,
            discharge_date,
            total_billed_amount,
            total_allowed_amount,
            total_paid_amount,
            UPPER(
                TRIM(
                    REPLACE(
                        REPLACE(claim_status, CHAR(13), ''),
                        CHAR(10), ''
                    )
                )
            ),
            GETDATE()
        FROM dev_HealthConnect_raw.dbo.raw_claims;

        ------------------------------------------------------------
        -- 3. Commit
        ------------------------------------------------------------
        COMMIT TRANSACTION;

        ------------------------------------------------------------
        -- 4. Success result
        ------------------------------------------------------------
        SELECT
            'SUCCESS' AS Status,
            'Claims RAW to CLEANSED load completed successfully.' AS Message,
            COUNT(*) AS Row_Count
        FROM dbo.cleansed_claims;

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

EXEC dbo.Proc_HealthConnect_Raw_To_Cleansed_Claims_Load;
GO
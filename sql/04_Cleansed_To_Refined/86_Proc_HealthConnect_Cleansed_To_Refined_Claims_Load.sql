USE dev_HealthConnect_refined;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Cleansed_To_Refined_Claims_Load
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        ------------------------------------------------------------
        -- 1. UPDATE existing claims
        --    SCD TYPE 1
        ------------------------------------------------------------
        UPDATE tgt
        SET
            tgt.encounter_id = src.encounter_id,
            tgt.payer_id = src.payer_id,
            tgt.admit_date = src.admit_date,
            tgt.discharge_date = src.discharge_date,
            tgt.total_billed_amount = src.total_billed_amount,
            tgt.total_allowed_amount = src.total_allowed_amount,
            tgt.total_paid_amount = src.total_paid_amount,
            tgt.claim_status = src.claim_status,
            tgt.last_updated_date = CAST(GETDATE() AS DATE)
        FROM refined_dw.refined_claims tgt
        INNER JOIN dev_HealthConnect_cleansed.dbo.cleansed_claims src
            ON tgt.claim_id = src.claim_id
        WHERE
               ISNULL(tgt.encounter_id, 0) <> ISNULL(src.encounter_id, 0)
            OR ISNULL(tgt.payer_id, 0) <> ISNULL(src.payer_id, 0)
            OR ISNULL(tgt.admit_date, '1900-01-01')
                <> ISNULL(src.admit_date, '1900-01-01')
            OR ISNULL(tgt.discharge_date, '1900-01-01')
                <> ISNULL(src.discharge_date, '1900-01-01')
            OR ISNULL(tgt.total_billed_amount, 0)
                <> ISNULL(src.total_billed_amount, 0)
            OR ISNULL(tgt.total_allowed_amount, 0)
                <> ISNULL(src.total_allowed_amount, 0)
            OR ISNULL(tgt.total_paid_amount, 0)
                <> ISNULL(src.total_paid_amount, 0)
            OR ISNULL(tgt.claim_status, '')
                <> ISNULL(src.claim_status, '');

        ------------------------------------------------------------
        -- 2. INSERT new claims
        ------------------------------------------------------------
        INSERT INTO refined_dw.refined_claims
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
            load_date,
            last_updated_date
        )
        SELECT
            src.claim_id,
            src.encounter_id,
            src.payer_id,
            src.admit_date,
            src.discharge_date,
            src.total_billed_amount,
            src.total_allowed_amount,
            src.total_paid_amount,
            src.claim_status,
            CAST(src.load_date AS DATE),
            CAST(GETDATE() AS DATE)
        FROM dev_HealthConnect_cleansed.dbo.cleansed_claims src
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM refined_dw.refined_claims tgt
            WHERE tgt.claim_id = src.claim_id
        );

        ------------------------------------------------------------
        -- 3. COMMIT
        ------------------------------------------------------------
        COMMIT TRANSACTION;

        ------------------------------------------------------------
        -- 4. SUCCESS RESULT
        ------------------------------------------------------------
        SELECT
            'SUCCESS' AS Status,
            'Claims CLEANSED to REFINED SCD Type 1 load completed successfully.'
                AS Message,
            COUNT(*) AS Row_Count
        FROM refined_dw.refined_claims;

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

USE dev_HealthConnect_refined;
GO

EXEC dbo.Proc_HealthConnect_Cleansed_To_Refined_Claims_Load;
GO
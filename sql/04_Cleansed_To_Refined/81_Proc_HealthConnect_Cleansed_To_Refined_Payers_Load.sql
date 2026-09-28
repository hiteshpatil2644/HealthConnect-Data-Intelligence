USE dev_HealthConnect_refined;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Cleansed_To_Refined_Payers_Load
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        ------------------------------------------------------------
        -- 1. UPDATE existing payers
        --    SCD TYPE 1
        ------------------------------------------------------------
        UPDATE tgt
        SET
            tgt.payer_name = src.payer_name,
            tgt.last_updated_date = CAST(GETDATE() AS DATE)
        FROM refined_dw.refined_payers tgt
        INNER JOIN dev_HealthConnect_cleansed.dbo.cleansed_payers src
            ON tgt.payer_id = src.payer_id
        WHERE
            ISNULL(tgt.payer_name, '') <> ISNULL(src.payer_name, '');

        ------------------------------------------------------------
        -- 2. INSERT new payers
        ------------------------------------------------------------
        INSERT INTO refined_dw.refined_payers
        (
            payer_id,
            payer_name,
            load_date,
            last_updated_date
        )
        SELECT
            src.payer_id,
            src.payer_name,
            CAST(src.load_date AS DATE),
            CAST(GETDATE() AS DATE)
        FROM dev_HealthConnect_cleansed.dbo.cleansed_payers src
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM refined_dw.refined_payers tgt
            WHERE tgt.payer_id = src.payer_id
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
            'Payers CLEANSED to REFINED SCD Type 1 load completed successfully.'
                AS Message,
            COUNT(*) AS Row_Count
        FROM refined_dw.refined_payers;

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

EXEC dbo.Proc_HealthConnect_Cleansed_To_Refined_Payers_Load;
GO
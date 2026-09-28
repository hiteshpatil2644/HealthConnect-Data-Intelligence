USE dev_HealthConnect_refined;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Cleansed_To_Refined_Providers_Load
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        ------------------------------------------------------------
        -- 1. UPDATE existing providers
        --    SCD TYPE 1
        ------------------------------------------------------------
        UPDATE tgt
        SET
            tgt.first_name = src.first_name,
            tgt.last_name = src.last_name,
            tgt.specialty = src.specialty,
            tgt.npi = src.npi,
            tgt.last_updated_date = CAST(GETDATE() AS DATE)
        FROM refined_dw.refined_providers tgt
        INNER JOIN dev_HealthConnect_cleansed.dbo.cleansed_providers src
            ON tgt.provider_id = src.provider_id
        WHERE
               ISNULL(tgt.first_name, '') <> ISNULL(src.first_name, '')
            OR ISNULL(tgt.last_name, '') <> ISNULL(src.last_name, '')
            OR ISNULL(tgt.specialty, '') <> ISNULL(src.specialty, '')
            OR ISNULL(tgt.npi, '') <> ISNULL(src.npi, '');

        ------------------------------------------------------------
        -- 2. INSERT new providers
        ------------------------------------------------------------
        INSERT INTO refined_dw.refined_providers
        (
            provider_id,
            first_name,
            last_name,
            specialty,
            npi,
            load_date,
            last_updated_date
        )
        SELECT
            src.provider_id,
            src.first_name,
            src.last_name,
            src.specialty,
            src.npi,
            CAST(src.load_date AS DATE),
            CAST(GETDATE() AS DATE)
        FROM dev_HealthConnect_cleansed.dbo.cleansed_providers src
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM refined_dw.refined_providers tgt
            WHERE tgt.provider_id = src.provider_id
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
            'Providers CLEANSED to REFINED SCD Type 1 load completed successfully.'
                AS Message,
            COUNT(*) AS Row_Count
        FROM refined_dw.refined_providers;

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

EXEC dbo.Proc_HealthConnect_Cleansed_To_Refined_Providers_Load;
GO
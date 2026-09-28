USE dev_HealthConnect_refined;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Cleansed_To_Refined_Procedures_Load
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        ------------------------------------------------------------
        -- 1. UPDATE existing procedures
        --    SCD TYPE 1
        ------------------------------------------------------------
        UPDATE tgt
        SET
            tgt.encounter_id = src.encounter_id,
            tgt.procedure_description = src.procedure_description,
            tgt.last_updated_date = CAST(GETDATE() AS DATE)
        FROM refined_dw.refined_procedures tgt
        INNER JOIN dev_HealthConnect_cleansed.dbo.cleansed_procedures src
            ON tgt.procedure_id = src.procedure_id
        WHERE
               ISNULL(tgt.encounter_id, 0) <> ISNULL(src.encounter_id, 0)
            OR ISNULL(tgt.procedure_description, '')
                <> ISNULL(src.procedure_description, '');

        ------------------------------------------------------------
        -- 2. INSERT new procedures
        ------------------------------------------------------------
        INSERT INTO refined_dw.refined_procedures
        (
            procedure_id,
            encounter_id,
            procedure_description,
            load_date,
            last_updated_date
        )
        SELECT
            src.procedure_id,
            src.encounter_id,
            src.procedure_description,
            CAST(src.load_date AS DATE),
            CAST(GETDATE() AS DATE)
        FROM dev_HealthConnect_cleansed.dbo.cleansed_procedures src
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM refined_dw.refined_procedures tgt
            WHERE tgt.procedure_id = src.procedure_id
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
            'Procedures CLEANSED to REFINED SCD Type 1 load completed successfully.'
                AS Message,
            COUNT(*) AS Row_Count
        FROM refined_dw.refined_procedures;

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

EXEC dbo.Proc_HealthConnect_Cleansed_To_Refined_Procedures_Load;
GO
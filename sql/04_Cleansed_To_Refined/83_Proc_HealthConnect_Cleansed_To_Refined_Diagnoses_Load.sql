USE dev_HealthConnect_refined;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Cleansed_To_Refined_Diagnoses_Load
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        ------------------------------------------------------------
        -- 1. UPDATE existing diagnoses
        --    SCD TYPE 1
        ------------------------------------------------------------
        UPDATE tgt
        SET
            tgt.encounter_id = src.encounter_id,
            tgt.diagnosis_description = src.diagnosis_description,
            tgt.is_primary = src.is_primary,
            tgt.last_updated_date = CAST(GETDATE() AS DATE)
        FROM refined_dw.refined_diagnoses tgt
        INNER JOIN dev_HealthConnect_cleansed.dbo.cleansed_diagnoses src
            ON tgt.diagnosis_id = src.diagnosis_id
        WHERE
               ISNULL(tgt.encounter_id, 0) <> ISNULL(src.encounter_id, 0)
            OR ISNULL(tgt.diagnosis_description, '') 
                <> ISNULL(src.diagnosis_description, '')
            OR ISNULL(tgt.is_primary, '') <> ISNULL(src.is_primary, '');

        ------------------------------------------------------------
        -- 2. INSERT new diagnoses
        ------------------------------------------------------------
        INSERT INTO refined_dw.refined_diagnoses
        (
            diagnosis_id,
            encounter_id,
            diagnosis_description,
            is_primary,
            load_date,
            last_updated_date
        )
        SELECT
            src.diagnosis_id,
            src.encounter_id,
            src.diagnosis_description,
            src.is_primary,
            CAST(src.load_date AS DATE),
            CAST(GETDATE() AS DATE)
        FROM dev_HealthConnect_cleansed.dbo.cleansed_diagnoses src
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM refined_dw.refined_diagnoses tgt
            WHERE tgt.diagnosis_id = src.diagnosis_id
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
            'Diagnoses CLEANSED to REFINED SCD Type 1 load completed successfully.'
                AS Message,
            COUNT(*) AS Row_Count
        FROM refined_dw.refined_diagnoses;

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

EXEC dbo.Proc_HealthConnect_Cleansed_To_Refined_Diagnoses_Load;
GO
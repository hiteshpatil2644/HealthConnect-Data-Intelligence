USE dev_HealthConnect_refined;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Cleansed_To_Refined_Medications_Load
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        ------------------------------------------------------------
        -- 1. UPDATE existing medications
        --    SCD TYPE 1
        ------------------------------------------------------------
        UPDATE tgt
        SET
            tgt.encounter_id = src.encounter_id,
            tgt.drug_name = src.drug_name,
            tgt.route = src.route,
            tgt.dose = src.dose,
            tgt.frequency = src.frequency,
            tgt.days_supply = src.days_supply,
            tgt.last_updated_date = CAST(GETDATE() AS DATE)
        FROM refined_dw.refined_medications tgt
        INNER JOIN dev_HealthConnect_cleansed.dbo.cleansed_medications src
            ON tgt.medication_id = src.medication_id
        WHERE
               ISNULL(tgt.encounter_id, 0) <> ISNULL(src.encounter_id, 0)
            OR ISNULL(tgt.drug_name, '') <> ISNULL(src.drug_name, '')
            OR ISNULL(tgt.route, '') <> ISNULL(src.route, '')
            OR ISNULL(tgt.dose, '') <> ISNULL(src.dose, '')
            OR ISNULL(tgt.frequency, '') <> ISNULL(src.frequency, '')
            OR ISNULL(tgt.days_supply, 0) <> ISNULL(src.days_supply, 0);

        ------------------------------------------------------------
        -- 2. INSERT new medications
        ------------------------------------------------------------
        INSERT INTO refined_dw.refined_medications
        (
            medication_id,
            encounter_id,
            drug_name,
            route,
            dose,
            frequency,
            days_supply,
            load_date,
            last_updated_date
        )
        SELECT
            src.medication_id,
            src.encounter_id,
            src.drug_name,
            src.route,
            src.dose,
            src.frequency,
            src.days_supply,
            CAST(src.load_date AS DATE),
            CAST(GETDATE() AS DATE)
        FROM dev_HealthConnect_cleansed.dbo.cleansed_medications src
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM refined_dw.refined_medications tgt
            WHERE tgt.medication_id = src.medication_id
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
            'Medications CLEANSED to REFINED SCD Type 1 load completed successfully.'
                AS Message,
            COUNT(*) AS Row_Count
        FROM refined_dw.refined_medications;

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

EXEC dbo.Proc_HealthConnect_Cleansed_To_Refined_Medications_Load;
GO
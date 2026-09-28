USE dev_HealthConnect_refined;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Cleansed_To_Refined_Encounters_Load
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        ------------------------------------------------------------
        -- 1. UPDATE existing encounters
        --    SCD TYPE 1
        ------------------------------------------------------------
        UPDATE tgt
        SET
            tgt.patient_id = src.patient_id,
            tgt.provider_id = src.provider_id,
            tgt.encounter_type = src.encounter_type,
            tgt.encounter_start = src.encounter_start,
            tgt.encounter_end = src.encounter_end,
            tgt.height_cm = src.height_cm,
            tgt.weight_kg = src.weight_kg,
            tgt.systolic_bp = src.systolic_bp,
            tgt.diastolic_bp = src.diastolic_bp,
            tgt.last_updated_date = CAST(GETDATE() AS DATE)
        FROM refined_dw.refined_encounters tgt
        INNER JOIN dev_HealthConnect_cleansed.dbo.cleansed_encounters src
            ON tgt.encounter_id = src.encounter_id
        WHERE
               ISNULL(tgt.patient_id, 0) <> ISNULL(src.patient_id, 0)
            OR ISNULL(tgt.provider_id, 0) <> ISNULL(src.provider_id, 0)
            OR ISNULL(tgt.encounter_type, '') <> ISNULL(src.encounter_type, '')
            OR ISNULL(tgt.encounter_start, '1900-01-01') 
                <> ISNULL(src.encounter_start, '1900-01-01')
            OR ISNULL(tgt.encounter_end, '1900-01-01') 
                <> ISNULL(src.encounter_end, '1900-01-01')
            OR ISNULL(tgt.height_cm, 0) <> ISNULL(src.height_cm, 0)
            OR ISNULL(tgt.weight_kg, 0) <> ISNULL(src.weight_kg, 0)
            OR ISNULL(tgt.systolic_bp, 0) <> ISNULL(src.systolic_bp, 0)
            OR ISNULL(tgt.diastolic_bp, 0) <> ISNULL(src.diastolic_bp, 0);

        ------------------------------------------------------------
        -- 2. INSERT new encounters
        ------------------------------------------------------------
        INSERT INTO refined_dw.refined_encounters
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
            load_date,
            last_updated_date
        )
        SELECT
            src.encounter_id,
            src.patient_id,
            src.provider_id,
            src.encounter_type,
            src.encounter_start,
            src.encounter_end,
            src.height_cm,
            src.weight_kg,
            src.systolic_bp,
            src.diastolic_bp,
            CAST(src.load_date AS DATE),
            CAST(GETDATE() AS DATE)
        FROM dev_HealthConnect_cleansed.dbo.cleansed_encounters src
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM refined_dw.refined_encounters tgt
            WHERE tgt.encounter_id = src.encounter_id
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
            'Encounters CLEANSED to REFINED SCD Type 1 load completed successfully.'
                AS Message,
            COUNT(*) AS Row_Count
        FROM refined_dw.refined_encounters;

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

EXEC dbo.Proc_HealthConnect_Cleansed_To_Refined_Encounters_Load;
GO
USE dev_HealthConnect_refined;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Cleansed_To_Refined_Patients_Load
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        ------------------------------------------------------------
        -- 1. UPDATE existing patients
        --    SCD TYPE 1
        ------------------------------------------------------------
        UPDATE tgt
        SET
            tgt.first_name = src.first_name,
            tgt.last_name = src.last_name,
            tgt.gender = src.gender,
            tgt.date_of_birth = src.date_of_birth,
            tgt.state_code = src.state_code,
            tgt.city = src.city,
            tgt.phone = src.phone,
            tgt.last_updated_date = CAST(GETDATE() AS DATE)
        FROM refined_dw.refined_patients tgt
        INNER JOIN dev_HealthConnect_cleansed.dbo.cleansed_patients src
            ON tgt.patient_id = src.patient_id
        WHERE
               ISNULL(tgt.first_name, '') <> ISNULL(src.first_name, '')
            OR ISNULL(tgt.last_name, '') <> ISNULL(src.last_name, '')
            OR ISNULL(tgt.gender, '') <> ISNULL(src.gender, '')
            OR ISNULL(tgt.date_of_birth, '1900-01-01')
                <> ISNULL(src.date_of_birth, '1900-01-01')
            OR ISNULL(tgt.state_code, '') <> ISNULL(src.state_code, '')
            OR ISNULL(tgt.city, '') <> ISNULL(src.city, '')
            OR ISNULL(tgt.phone, '') <> ISNULL(src.phone, '');

        ------------------------------------------------------------
        -- 2. INSERT new patients
        ------------------------------------------------------------
        INSERT INTO refined_dw.refined_patients
        (
            patient_id,
            first_name,
            last_name,
            gender,
            date_of_birth,
            state_code,
            city,
            phone,
            load_date,
            last_updated_date
        )
        SELECT
            src.patient_id,
            src.first_name,
            src.last_name,
            src.gender,
            src.date_of_birth,
            src.state_code,
            src.city,
            src.phone,
            CAST(src.load_date AS DATE),
            CAST(GETDATE() AS DATE)
        FROM dev_HealthConnect_cleansed.dbo.cleansed_patients src
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM refined_dw.refined_patients tgt
            WHERE tgt.patient_id = src.patient_id
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
            'Patients CLEANSED to REFINED SCD Type 1 load completed successfully.'
                AS Message,
            COUNT(*) AS Row_Count
        FROM refined_dw.refined_patients;

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

EXEC dbo.Proc_HealthConnect_Cleansed_To_Refined_Patients_Load;
GO
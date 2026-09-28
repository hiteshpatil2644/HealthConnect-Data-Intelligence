USE dev_HealthConnect_raw;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Source_To_Raw_Diagnoses_Load
    @FilePath NVARCHAR(4000)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        ------------------------------------------------------------
        -- 1. Temporary staging table
        ------------------------------------------------------------
        IF OBJECT_ID('tempdb..#Diagnoses_Stage') IS NOT NULL
            DROP TABLE #Diagnoses_Stage;

        CREATE TABLE #Diagnoses_Stage
        (
            diagnosis_id          INT,
            encounter_id          INT,
            diagnosis_description VARCHAR(500),
            is_primary             BIT
        );

        ------------------------------------------------------------
        -- 2. Load CSV into staging
        ------------------------------------------------------------
        DECLARE @SQL NVARCHAR(MAX);

        SET @SQL = N'
            BULK INSERT #Diagnoses_Stage
            FROM ''' + REPLACE(@FilePath, '''', '''''') + N'''
            WITH
            (
                FIRSTROW = 2,
                FIELDTERMINATOR = '','',
                ROWTERMINATOR = ''0x0d0a'',
                TABLOCK
            );';

        EXEC sys.sp_executesql @SQL;

        ------------------------------------------------------------
        -- 3. Validate Encounter references
        ------------------------------------------------------------
        IF EXISTS
        (
            SELECT 1
            FROM #Diagnoses_Stage AS S
            LEFT JOIN dbo.raw_encounters AS E
                ON S.encounter_id = E.encounter_id
            WHERE E.encounter_id IS NULL
        )
        BEGIN
            THROW 50003, 'Diagnosis contains an invalid encounter_id.', 1;
        END;

        ------------------------------------------------------------
        -- 4. Update existing diagnoses
        ------------------------------------------------------------
        UPDATE R
        SET
            R.encounter_id = S.encounter_id,
            R.diagnosis_description = S.diagnosis_description,
            R.is_primary = S.is_primary
        FROM dbo.raw_diagnoses AS R
        INNER JOIN #Diagnoses_Stage AS S
            ON R.diagnosis_id = S.diagnosis_id;

        ------------------------------------------------------------
        -- 5. Insert new diagnoses
        ------------------------------------------------------------
        INSERT INTO dbo.raw_diagnoses
        (
            diagnosis_id,
            encounter_id,
            diagnosis_description,
            is_primary
        )
        SELECT
            S.diagnosis_id,
            S.encounter_id,
            S.diagnosis_description,
            S.is_primary
        FROM #Diagnoses_Stage AS S
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.raw_diagnoses AS R
            WHERE R.diagnosis_id = S.diagnosis_id
        );

        ------------------------------------------------------------
        -- 6. Commit
        ------------------------------------------------------------
        COMMIT TRANSACTION;

        ------------------------------------------------------------
        -- 7. Success result
        ------------------------------------------------------------
        SELECT
            'SUCCESS' AS Status,
            'Diagnoses CSV loaded successfully into RAW.' AS Message,
            COUNT(*) AS Row_Count
        FROM dbo.raw_diagnoses;

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

USE dev_HealthConnect_raw;
GO

EXEC dbo.Proc_HealthConnect_Source_To_Raw_Diagnoses_Load
    @FilePath = 'D:\HelthConnect\InboundFiles\diagnoses_20260927.csv';
GO
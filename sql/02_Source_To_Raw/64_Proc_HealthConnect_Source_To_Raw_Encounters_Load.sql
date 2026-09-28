USE dev_HealthConnect_raw;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Source_To_Raw_Encounters_Load
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
        IF OBJECT_ID('tempdb..#Encounters_Stage') IS NOT NULL
            DROP TABLE #Encounters_Stage;

        CREATE TABLE #Encounters_Stage
        (
            encounter_id    INT,
            patient_id      INT,
            provider_id     INT,
            encounter_type  VARCHAR(10),
            encounter_start DATETIME,
            encounter_end   DATETIME,
            height_cm       FLOAT,
            weight_kg       FLOAT,
            systolic_bp     INT,
            diastolic_bp    INT
        );

        ------------------------------------------------------------
        -- 2. Load CSV into staging
        ------------------------------------------------------------
        DECLARE @SQL NVARCHAR(MAX);

        SET @SQL = N'
            BULK INSERT #Encounters_Stage
            FROM ''' + REPLACE(@FilePath, '''', '''''') + N'''
            WITH
            (
                FIRSTROW = 2,
                FIELDTERMINATOR = '','',
                ROWTERMINATOR = ''0x0a'',
                TABLOCK
            );';

        EXEC sys.sp_executesql @SQL;

        ------------------------------------------------------------
        -- 3. Validate Patient references
        ------------------------------------------------------------
        IF EXISTS
        (
            SELECT 1
            FROM #Encounters_Stage AS S
            LEFT JOIN dbo.raw_patients AS P
                ON S.patient_id = P.patient_id
            WHERE P.patient_id IS NULL
        )
        BEGIN
            THROW 50001, 'Encounter contains an invalid patient_id.', 1;
        END;

        ------------------------------------------------------------
        -- 4. Validate Provider references
        ------------------------------------------------------------
        IF EXISTS
        (
            SELECT 1
            FROM #Encounters_Stage AS S
            LEFT JOIN dbo.raw_providers AS P
                ON S.provider_id = P.provider_id
            WHERE P.provider_id IS NULL
        )
        BEGIN
            THROW 50002, 'Encounter contains an invalid provider_id.', 1;
        END;

        ------------------------------------------------------------
        -- 5. Update existing encounters
        ------------------------------------------------------------
        UPDATE R
        SET
            R.patient_id = S.patient_id,
            R.provider_id = S.provider_id,
            R.encounter_type = S.encounter_type,
            R.encounter_start = S.encounter_start,
            R.encounter_end = S.encounter_end,
            R.height_cm = S.height_cm,
            R.weight_kg = S.weight_kg,
            R.systolic_bp = S.systolic_bp,
            R.diastolic_bp = S.diastolic_bp
        FROM dbo.raw_encounters AS R
        INNER JOIN #Encounters_Stage AS S
            ON R.encounter_id = S.encounter_id;

        ------------------------------------------------------------
        -- 6. Insert new encounters
        ------------------------------------------------------------
        INSERT INTO dbo.raw_encounters
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
            diastolic_bp
        )
        SELECT
            S.encounter_id,
            S.patient_id,
            S.provider_id,
            S.encounter_type,
            S.encounter_start,
            S.encounter_end,
            S.height_cm,
            S.weight_kg,
            S.systolic_bp,
            S.diastolic_bp
        FROM #Encounters_Stage AS S
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.raw_encounters AS R
            WHERE R.encounter_id = S.encounter_id
        );

        ------------------------------------------------------------
        -- 7. Commit
        ------------------------------------------------------------
        COMMIT TRANSACTION;

        ------------------------------------------------------------
        -- 8. Success result
        ------------------------------------------------------------
        SELECT
            'SUCCESS' AS Status,
            'Encounters CSV loaded successfully into RAW.' AS Message,
            COUNT(*) AS Row_Count
        FROM dbo.raw_encounters;

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

EXEC dbo.Proc_HealthConnect_Source_To_Raw_Encounters_Load
    @FilePath = 'D:\HelthConnect\InboundFiles\encounters_20260927.csv';
GO
USE dev_HealthConnect_raw;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Source_To_Raw_Medications_Load
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
        IF OBJECT_ID('tempdb..#Medications_Stage') IS NOT NULL
            DROP TABLE #Medications_Stage;

        CREATE TABLE #Medications_Stage
        (
            medication_id INT,
            encounter_id  INT,
            drug_name     VARCHAR(50),
            route         VARCHAR(20),
            dose          VARCHAR(20),
            frequency     VARCHAR(10),
            days_supply   INT
        );

        ------------------------------------------------------------
        -- 2. Load CSV into staging
        ------------------------------------------------------------
        DECLARE @SQL NVARCHAR(MAX);

        SET @SQL = N'
            BULK INSERT #Medications_Stage
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
        -- 3. Validate Encounter references
        ------------------------------------------------------------
        IF EXISTS
        (
            SELECT 1
            FROM #Medications_Stage AS S
            LEFT JOIN dbo.raw_encounters AS E
                ON S.encounter_id = E.encounter_id
            WHERE E.encounter_id IS NULL
        )
        BEGIN
            THROW 50005, 'Medication contains an invalid encounter_id.', 1;
        END;

        ------------------------------------------------------------
        -- 4. Update existing medications
        ------------------------------------------------------------
        UPDATE R
        SET
            R.encounter_id = S.encounter_id,
            R.drug_name = S.drug_name,
            R.route = S.route,
            R.dose = S.dose,
            R.frequency = S.frequency,
            R.days_supply = S.days_supply
        FROM dbo.raw_medications AS R
        INNER JOIN #Medications_Stage AS S
            ON R.medication_id = S.medication_id;

        ------------------------------------------------------------
        -- 5. Insert new medications
        ------------------------------------------------------------
        INSERT INTO dbo.raw_medications
        (
            medication_id,
            encounter_id,
            drug_name,
            route,
            dose,
            frequency,
            days_supply
        )
        SELECT
            S.medication_id,
            S.encounter_id,
            S.drug_name,
            S.route,
            S.dose,
            S.frequency,
            S.days_supply
        FROM #Medications_Stage AS S
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.raw_medications AS R
            WHERE R.medication_id = S.medication_id
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
            'Medications CSV loaded successfully into RAW.' AS Message,
            COUNT(*) AS Row_Count
        FROM dbo.raw_medications;

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

EXEC dbo.Proc_HealthConnect_Source_To_Raw_Medications_Load
    @FilePath = 'D:\HelthConnect\InboundFiles\medications_20260927.csv';
GO
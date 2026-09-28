USE dev_HealthConnect_raw;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Source_To_Raw_Procedures_Load
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
        IF OBJECT_ID('tempdb..#Procedures_Stage') IS NOT NULL
            DROP TABLE #Procedures_Stage;

        CREATE TABLE #Procedures_Stage
        (
            procedure_id          INT,
            encounter_id          INT,
            procedure_description VARCHAR(500)
        );

        ------------------------------------------------------------
        -- 2. Load CSV into staging
        ------------------------------------------------------------
        DECLARE @SQL NVARCHAR(MAX);

        SET @SQL = N'
            BULK INSERT #Procedures_Stage
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
            FROM #Procedures_Stage AS S
            LEFT JOIN dbo.raw_encounters AS E
                ON S.encounter_id = E.encounter_id
            WHERE E.encounter_id IS NULL
        )
        BEGIN
            THROW 50004, 'Procedure contains an invalid encounter_id.', 1;
        END;

        ------------------------------------------------------------
        -- 4. Update existing procedures
        ------------------------------------------------------------
        UPDATE R
        SET
            R.encounter_id = S.encounter_id,
            R.procedure_description = S.procedure_description
        FROM dbo.raw_procedures AS R
        INNER JOIN #Procedures_Stage AS S
            ON R.procedure_id = S.procedure_id;

        ------------------------------------------------------------
        -- 5. Insert new procedures
        ------------------------------------------------------------
        INSERT INTO dbo.raw_procedures
        (
            procedure_id,
            encounter_id,
            procedure_description
        )
        SELECT
            S.procedure_id,
            S.encounter_id,
            S.procedure_description
        FROM #Procedures_Stage AS S
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.raw_procedures AS R
            WHERE R.procedure_id = S.procedure_id
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
            'Procedures CSV loaded successfully into RAW.' AS Message,
            COUNT(*) AS Row_Count
        FROM dbo.raw_procedures;

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

EXEC dbo.Proc_HealthConnect_Source_To_Raw_Procedures_Load
    @FilePath = 'D:\HelthConnect\InboundFiles\procedures_20260927.csv';
GO
USE dev_HealthConnect_raw;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Source_To_Raw_Payers_Load
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
        IF OBJECT_ID('tempdb..#Payers_Stage') IS NOT NULL
            DROP TABLE #Payers_Stage;

        CREATE TABLE #Payers_Stage
        (
            payer_id    INT,
            payer_name  VARCHAR(200)
        );

        ------------------------------------------------------------
        -- 2. Load CSV into staging
        ------------------------------------------------------------
        DECLARE @SQL NVARCHAR(MAX);

        SET @SQL = N'
            BULK INSERT #Payers_Stage
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
        -- 3. Update existing payers
        ------------------------------------------------------------
        UPDATE R
        SET
            R.payer_name = S.payer_name
        FROM dbo.raw_payers AS R
        INNER JOIN #Payers_Stage AS S
            ON R.payer_id = S.payer_id;

        ------------------------------------------------------------
        -- 4. Insert new payers
        ------------------------------------------------------------
        INSERT INTO dbo.raw_payers
        (
            payer_id,
            payer_name
        )
        SELECT
            S.payer_id,
            S.payer_name
        FROM #Payers_Stage AS S
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.raw_payers AS R
            WHERE R.payer_id = S.payer_id
        );

        ------------------------------------------------------------
        -- 5. Commit
        ------------------------------------------------------------
        COMMIT TRANSACTION;

        ------------------------------------------------------------
        -- 6. Success result
        ------------------------------------------------------------
        SELECT
            'SUCCESS' AS Status,
            'Payers CSV loaded successfully into RAW.' AS Message,
            COUNT(*) AS Row_Count
        FROM dbo.raw_payers;

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

EXEC dbo.Proc_HealthConnect_Source_To_Raw_Payers_Load
    @FilePath = 'D:\HelthConnect\InboundFiles\payers_20260927.csv';
GO
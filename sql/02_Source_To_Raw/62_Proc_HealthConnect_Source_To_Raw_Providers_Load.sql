USE dev_HealthConnect_raw;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Source_To_Raw_Providers_Load
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
        IF OBJECT_ID('tempdb..#Providers_Stage') IS NOT NULL
            DROP TABLE #Providers_Stage;

        CREATE TABLE #Providers_Stage
        (
            provider_id   INT,
            first_name    VARCHAR(100),
            last_name     VARCHAR(100),
            specialty     VARCHAR(100),
            npi           VARCHAR(20)
        );

        ------------------------------------------------------------
        -- 2. Load CSV into staging
        ------------------------------------------------------------
        DECLARE @SQL NVARCHAR(MAX);

        SET @SQL = N'
            BULK INSERT #Providers_Stage
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
        -- 3. Update existing providers
        ------------------------------------------------------------
        UPDATE R
        SET
            R.first_name = S.first_name,
            R.last_name = S.last_name,
            R.specialty = S.specialty,
            R.npi = S.npi
        FROM dbo.raw_providers AS R
        INNER JOIN #Providers_Stage AS S
            ON R.provider_id = S.provider_id;

        ------------------------------------------------------------
        -- 4. Insert new providers
        ------------------------------------------------------------
        INSERT INTO dbo.raw_providers
        (
            provider_id,
            first_name,
            last_name,
            specialty,
            npi
        )
        SELECT
            S.provider_id,
            S.first_name,
            S.last_name,
            S.specialty,
            S.npi
        FROM #Providers_Stage AS S
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.raw_providers AS R
            WHERE R.provider_id = S.provider_id
        );

        ------------------------------------------------------------
        -- 5. Commit transaction
        ------------------------------------------------------------
        COMMIT TRANSACTION;

        ------------------------------------------------------------
        -- 6. Success result
        ------------------------------------------------------------
        SELECT
            'SUCCESS' AS Status,
            'Providers CSV loaded successfully into RAW.' AS Message,
            COUNT(*) AS Row_Count
        FROM dbo.raw_providers;

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

EXEC dbo.Proc_HealthConnect_Source_To_Raw_Providers_Load
    @FilePath = 'D:\HelthConnect\InboundFiles\providers_20260927.csv';
GO
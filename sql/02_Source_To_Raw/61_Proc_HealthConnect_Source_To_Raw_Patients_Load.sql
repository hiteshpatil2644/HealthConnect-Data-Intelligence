USE dev_HealthConnect_raw;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Source_To_Raw_Patients_Load
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
        IF OBJECT_ID('tempdb..#Patients_Stage') IS NOT NULL
            DROP TABLE #Patients_Stage;

        CREATE TABLE #Patients_Stage
        (
            patient_id      INT,
            first_name      VARCHAR(100),
            last_name       VARCHAR(100),
            gender          VARCHAR(1),
            date_of_birth   DATE,
            state_code      VARCHAR(10),
            city            VARCHAR(100),
            phone           VARCHAR(20)
        );

        ------------------------------------------------------------
        -- 2. Load CSV into staging table
        ------------------------------------------------------------
        DECLARE @SQL NVARCHAR(MAX);

        SET @SQL = N'
            BULK INSERT #Patients_Stage
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
        -- 3. Update existing patients
        ------------------------------------------------------------
        UPDATE R
        SET
            R.first_name = S.first_name,
            R.last_name = S.last_name,
            R.gender = S.gender,
            R.date_of_birth = S.date_of_birth,
            R.state_code = S.state_code,
            R.city = S.city,
            R.phone = S.phone
        FROM dbo.raw_patients AS R
        INNER JOIN #Patients_Stage AS S
            ON R.patient_id = S.patient_id;

        ------------------------------------------------------------
        -- 4. Insert new patients
        ------------------------------------------------------------
        INSERT INTO dbo.raw_patients
        (
            patient_id,
            first_name,
            last_name,
            gender,
            date_of_birth,
            state_code,
            city,
            phone
        )
        SELECT
            S.patient_id,
            S.first_name,
            S.last_name,
            S.gender,
            S.date_of_birth,
            S.state_code,
            S.city,
            S.phone
        FROM #Patients_Stage AS S
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.raw_patients AS R
            WHERE R.patient_id = S.patient_id
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
            'Patients CSV loaded successfully into RAW.' AS Message,
            COUNT(*) AS Row_Count
        FROM dbo.raw_patients;

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

EXEC dbo.Proc_HealthConnect_Source_To_Raw_Patients_Load
    @FilePath = 'D:\HelthConnect\InboundFiles\patients_20260927.csv';
GO
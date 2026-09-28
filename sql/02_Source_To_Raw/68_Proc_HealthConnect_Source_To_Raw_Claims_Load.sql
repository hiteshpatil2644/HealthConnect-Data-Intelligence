USE dev_HealthConnect_raw;
GO

CREATE OR ALTER PROCEDURE dbo.Proc_HealthConnect_Source_To_Raw_Claims_Load
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
        IF OBJECT_ID('tempdb..#Claims_Stage') IS NOT NULL
            DROP TABLE #Claims_Stage;

        CREATE TABLE #Claims_Stage
        (
            claim_id              INT,
            encounter_id          INT,
            payer_id              INT,
            admit_date            DATE,
            discharge_date        DATE,
            total_billed_amount   FLOAT,
            total_allowed_amount  FLOAT,
            total_paid_amount     FLOAT,
            claim_status          VARCHAR(20)
        );

        ------------------------------------------------------------
        -- 2. Load CSV into staging
        ------------------------------------------------------------
        DECLARE @SQL NVARCHAR(MAX);

        SET @SQL = N'
            BULK INSERT #Claims_Stage
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
        -- 3. Clean CR/LF and spaces from claim_status
        ------------------------------------------------------------
        UPDATE #Claims_Stage
        SET claim_status =
            LTRIM(
                RTRIM(
                    REPLACE(
                        REPLACE(claim_status, CHAR(13), ''),
                        CHAR(10), ''
                    )
                )
            );

        ------------------------------------------------------------
        -- 4. Validate Encounter references
        ------------------------------------------------------------
        IF EXISTS
        (
            SELECT 1
            FROM #Claims_Stage AS S
            LEFT JOIN dbo.raw_encounters AS E
                ON S.encounter_id = E.encounter_id
            WHERE E.encounter_id IS NULL
        )
        BEGIN
            THROW 50006, 'Claim contains an invalid encounter_id.', 1;
        END;

        ------------------------------------------------------------
        -- 5. Validate Payer references
        ------------------------------------------------------------
        IF EXISTS
        (
            SELECT 1
            FROM #Claims_Stage AS S
            LEFT JOIN dbo.raw_payers AS P
                ON S.payer_id = P.payer_id
            WHERE P.payer_id IS NULL
        )
        BEGIN
            THROW 50007, 'Claim contains an invalid payer_id.', 1;
        END;

        ------------------------------------------------------------
        -- 6. Validate Claim Status
        ------------------------------------------------------------
        IF EXISTS
        (
            SELECT 1
            FROM #Claims_Stage
            WHERE claim_status NOT IN
            (
                'Paid',
                'Rejected',
                'Approved',
                'Pending'
            )
        )
        BEGIN
            THROW 50008, 'Claim contains an invalid claim_status.', 1;
        END;

        ------------------------------------------------------------
        -- 7. Update existing claims
        ------------------------------------------------------------
        UPDATE R
        SET
            R.encounter_id = S.encounter_id,
            R.payer_id = S.payer_id,
            R.admit_date = S.admit_date,
            R.discharge_date = S.discharge_date,
            R.total_billed_amount = S.total_billed_amount,
            R.total_allowed_amount = S.total_allowed_amount,
            R.total_paid_amount = S.total_paid_amount,
            R.claim_status = S.claim_status
        FROM dbo.raw_claims AS R
        INNER JOIN #Claims_Stage AS S
            ON R.claim_id = S.claim_id;

        ------------------------------------------------------------
        -- 8. Insert new claims
        ------------------------------------------------------------
        INSERT INTO dbo.raw_claims
        (
            claim_id,
            encounter_id,
            payer_id,
            admit_date,
            discharge_date,
            total_billed_amount,
            total_allowed_amount,
            total_paid_amount,
            claim_status
        )
        SELECT
            S.claim_id,
            S.encounter_id,
            S.payer_id,
            S.admit_date,
            S.discharge_date,
            S.total_billed_amount,
            S.total_allowed_amount,
            S.total_paid_amount,
            S.claim_status
        FROM #Claims_Stage AS S
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.raw_claims AS R
            WHERE R.claim_id = S.claim_id
        );

        ------------------------------------------------------------
        -- 9. Commit
        ------------------------------------------------------------
        COMMIT TRANSACTION;

        ------------------------------------------------------------
        -- 10. Success result
        ------------------------------------------------------------
        SELECT
            'SUCCESS' AS Status,
            'Claims CSV loaded successfully into RAW.' AS Message,
            COUNT(*) AS Row_Count
        FROM dbo.raw_claims;

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

EXEC dbo.Proc_HealthConnect_Source_To_Raw_Claims_Load
    @FilePath = 'D:\HelthConnect\InboundFiles\claims_20260927.csv';
GO
/* =========================================================
   HEALTHCONNECT
   SOURCE CSV -> RAW
   PAYER LOAD
   ========================================================= */

USE dev_HealthConnect_raw;
GO

/* STEP 1 - Clear existing development data */
DELETE FROM dbo.raw_payers;
GO

/* STEP 2 - Load CSV into RAW */
BULK INSERT dbo.raw_payers
FROM 'D:\HelthConnect\InboundFiles\payers_20260927.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);
GO

/* STEP 3 - Verify row count */
SELECT
    COUNT(*) AS Rows_Loaded
FROM dbo.raw_payers;
GO

/* STEP 4 - Verify data */
SELECT
    payer_id,
    payer_name
FROM dbo.raw_payers
ORDER BY payer_id;
GO
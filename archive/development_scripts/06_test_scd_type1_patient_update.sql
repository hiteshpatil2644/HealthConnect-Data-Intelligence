/* =========================================================
   HEALTHCONNECT
   PROVIDER SOURCE -> RAW LAYER
   ========================================================= */

USE dev_HealthConnect_raw;
GO


/* =========================================================
   STEP 1 - CLEAR EXISTING PROVIDER DATA
   ========================================================= */

DELETE FROM dbo.raw_providers;
GO


/* =========================================================
   STEP 2 - LOAD PROVIDER CSV INTO RAW
   ========================================================= */

BULK INSERT dbo.raw_providers
FROM 'D:\HelthConnect\InboundFiles\providers_20260927.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);
GO


/* =========================================================
   STEP 3 - VERIFY ROW COUNT
   ========================================================= */

SELECT
    COUNT(*) AS Rows_Loaded
FROM dbo.raw_providers;
GO


/* =========================================================
   STEP 4 - VERIFY DATA
   ========================================================= */

SELECT
    provider_id,
    first_name,
    last_name,
    specialty,
    npi
FROM dbo.raw_providers
ORDER BY provider_id;
GO

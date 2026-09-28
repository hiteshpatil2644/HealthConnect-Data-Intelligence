/* =========================================================
   HEALTHCONNECT
   SOURCE CSV -> RAW
   DIAGNOSES LOAD
   ========================================================= */

USE dev_HealthConnect_raw;
GO

/* STEP 1 - Clear existing development data */

DELETE FROM dbo.raw_diagnoses;
GO

/* STEP 2 - Load CSV into RAW */

BULK INSERT dbo.raw_diagnoses
FROM 'D:\HelthConnect\InboundFiles\diagnoses_20260927.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0d0a'
);
GO

/* STEP 3 - Verify row count */

SELECT
    COUNT(*) AS Rows_Loaded
FROM dbo.raw_diagnoses;
GO

/* STEP 4 - Verify RAW data */

SELECT
    diagnosis_id,
    encounter_id,
    diagnosis_description,
    is_primary
FROM dbo.raw_diagnoses
ORDER BY diagnosis_id;
GO
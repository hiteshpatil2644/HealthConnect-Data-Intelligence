/* =========================================================
   HEALTHCONNECT
   SOURCE CSV -> RAW
   ENCOUNTERS LOAD
   ========================================================= */

USE dev_HealthConnect_raw;
GO

/* STEP 1 - Clear existing development data */

DELETE FROM dbo.raw_encounters;
GO

/* STEP 2 - Load CSV into RAW */

BULK INSERT dbo.raw_encounters
FROM 'D:\HelthConnect\InboundFiles\encounters_20260927.csv'
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
FROM dbo.raw_encounters;
GO

/* STEP 4 - Verify RAW data */

SELECT
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
FROM dbo.raw_encounters
ORDER BY encounter_id;
GO
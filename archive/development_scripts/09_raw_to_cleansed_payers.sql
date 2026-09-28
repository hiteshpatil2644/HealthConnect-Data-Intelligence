/* =========================================================
   HEALTHCONNECT
   RAW -> CLEANSED
   PAYER LOAD
   ========================================================= */

USE dev_HealthConnect_cleansed;
GO

/* STEP 1 - Clear existing development data */

DELETE FROM dbo.cleansed_payers;
GO

/* STEP 2 - Load RAW -> CLEANSED */

INSERT INTO dbo.cleansed_payers
(
    payer_id,
    payer_name,
    load_date
)
SELECT
    payer_id,
    UPPER(TRIM(payer_name)),
    CAST(GETDATE() AS DATE)
FROM dev_HealthConnect_raw.dbo.raw_payers;
GO

/* STEP 3 - Verify row count */

SELECT
    COUNT(*) AS Rows_Loaded
FROM dbo.cleansed_payers;
GO

/* STEP 4 - Verify cleansed data */

SELECT
    payer_id,
    payer_name,
    load_date
FROM dbo.cleansed_payers
ORDER BY payer_id;
GO
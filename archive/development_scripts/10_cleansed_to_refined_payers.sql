/* =========================================================
   HEALTHCONNECT
   CLEANSED -> REFINED
   PAYER LOAD
   SCD TYPE 1
   ========================================================= */

USE dev_HealthConnect_refined;
GO

/* =========================================================
   STEP 1 - UPDATE EXISTING PAYERS
   ========================================================= */

UPDATE T
SET
    T.payer_name = S.payer_name,
    T.last_updated_date = CAST(GETDATE() AS DATE)
FROM refined_dw.refined_payers AS T
INNER JOIN dev_HealthConnect_cleansed.dbo.cleansed_payers AS S
    ON T.payer_id = S.payer_id
WHERE
    ISNULL(T.payer_name, '') <> ISNULL(S.payer_name, '');
GO

/* =========================================================
   STEP 2 - INSERT NEW PAYERS
   ========================================================= */

INSERT INTO refined_dw.refined_payers
(
    payer_id,
    payer_name,
    load_date,
    last_updated_date
)
SELECT
    S.payer_id,
    S.payer_name,
    S.load_date,
    CAST(GETDATE() AS DATE)
FROM dev_HealthConnect_cleansed.dbo.cleansed_payers AS S
WHERE NOT EXISTS
(
    SELECT 1
    FROM refined_dw.refined_payers AS T
    WHERE T.payer_id = S.payer_id
);
GO

/* =========================================================
   STEP 3 - VERIFY ROW COUNT
   ========================================================= */

SELECT
    COUNT(*) AS Refined_Payer_Count
FROM refined_dw.refined_payers;
GO

/* =========================================================
   STEP 4 - VERIFY REFINED DATA
   ========================================================= */

SELECT
    payer_id,
    payer_name,
    load_date,
    last_updated_date
FROM refined_dw.refined_payers
ORDER BY payer_id;
GO
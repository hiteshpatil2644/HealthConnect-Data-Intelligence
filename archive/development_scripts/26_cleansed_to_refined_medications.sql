USE dev_HealthConnect_refined;
GO

/* =========================================================
   CLEANSED → REFINED
   MEDICATIONS - SCD TYPE 1
   ========================================================= */

-- 1. Update existing records only when attributes change

UPDATE T
SET
    T.encounter_id = S.encounter_id,
    T.drug_name = S.drug_name,
    T.route = S.route,
    T.dose = S.dose,
    T.frequency = S.frequency,
    T.days_supply = S.days_supply,
    T.last_updated_date = CAST(GETDATE() AS DATE)
FROM refined_dw.refined_medications AS T
INNER JOIN dev_HealthConnect_cleansed.dbo.cleansed_medications AS S
    ON T.medication_id = S.medication_id
WHERE
    ISNULL(T.encounter_id, -1) <> ISNULL(S.encounter_id, -1)
    OR ISNULL(T.drug_name, '') COLLATE Latin1_General_100_BIN2
       <> ISNULL(S.drug_name, '') COLLATE Latin1_General_100_BIN2
    OR ISNULL(T.route, '') COLLATE Latin1_General_100_BIN2
       <> ISNULL(S.route, '') COLLATE Latin1_General_100_BIN2
    OR ISNULL(T.dose, '') COLLATE Latin1_General_100_BIN2
       <> ISNULL(S.dose, '') COLLATE Latin1_General_100_BIN2
    OR ISNULL(T.frequency, '') COLLATE Latin1_General_100_BIN2
       <> ISNULL(S.frequency, '') COLLATE Latin1_General_100_BIN2
    OR ISNULL(T.days_supply, -1) <> ISNULL(S.days_supply, -1);

-- 2. Insert new medication records

INSERT INTO refined_dw.refined_medications
(
    medication_id,
    encounter_id,
    drug_name,
    route,
    dose,
    frequency,
    days_supply,
    load_date,
    last_updated_date
)
SELECT
    S.medication_id,
    S.encounter_id,
    S.drug_name,
    S.route,
    S.dose,
    S.frequency,
    S.days_supply,
    S.load_date,
    CAST(GETDATE() AS DATE)
FROM dev_HealthConnect_cleansed.dbo.cleansed_medications AS S
WHERE NOT EXISTS
(
    SELECT 1
    FROM refined_dw.refined_medications AS T
    WHERE T.medication_id = S.medication_id
);

GO

/* =========================================================
   VALIDATION
   ========================================================= */

SELECT COUNT(*) AS Rows_Loaded
FROM refined_dw.refined_medications;
GO

SELECT
    medication_id,
    encounter_id,
    drug_name,
    route,
    dose,
    frequency,
    days_supply,
    load_date,
    last_updated_date
FROM refined_dw.refined_medications
ORDER BY medication_id;
GO
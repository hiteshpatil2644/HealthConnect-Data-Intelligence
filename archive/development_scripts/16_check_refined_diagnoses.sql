USE dev_HealthConnect_refined;
GO

/* =========================================================
   CLEANSED → REFINED
   SCD TYPE 1
   ========================================================= */

-- 1. Update existing diagnosis records
--    Only update when an attribute has changed

UPDATE T
SET
    T.encounter_id = S.encounter_id,
    T.diagnosis_description = S.diagnosis_description,
    T.is_primary = S.is_primary,
    T.last_updated_date = CAST(GETDATE() AS DATE)
FROM refined_dw.refined_diagnoses AS T
INNER JOIN dev_HealthConnect_cleansed.dbo.cleansed_diagnoses AS S
    ON T.diagnosis_id = S.diagnosis_id
WHERE
    ISNULL(T.encounter_id, -1) <> ISNULL(S.encounter_id, -1)
    OR ISNULL(T.diagnosis_description, '') <> ISNULL(S.diagnosis_description, '')
    OR ISNULL(T.is_primary, '') <> ISNULL(S.is_primary, '');

-- 2. Insert new diagnosis records

INSERT INTO refined_dw.refined_diagnoses
(
    diagnosis_id,
    encounter_id,
    diagnosis_description,
    is_primary,
    load_date,
    last_updated_date
)
SELECT
    S.diagnosis_id,
    S.encounter_id,
    S.diagnosis_description,
    S.is_primary,
    S.load_date,
    CAST(GETDATE() AS DATE)
FROM dev_HealthConnect_cleansed.dbo.cleansed_diagnoses AS S
WHERE NOT EXISTS
(
    SELECT 1
    FROM refined_dw.refined_diagnoses AS T
    WHERE T.diagnosis_id = S.diagnosis_id
);

GO

/* =========================================================
   VALIDATION
   ========================================================= */

SELECT COUNT(*) AS Rows_Loaded
FROM refined_dw.refined_diagnoses;
GO

SELECT
    diagnosis_id,
    encounter_id,
    diagnosis_description,
    is_primary,
    load_date,
    last_updated_date
FROM refined_dw.refined_diagnoses
ORDER BY diagnosis_id;
GO
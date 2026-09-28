/* =========================================================
   HEALTHCONNECT
   CLEANSED -> REFINED
   ENCOUNTERS LOAD
   SCD TYPE 1
   ========================================================= */

USE dev_HealthConnect_refined;
GO

/* =========================================================
   STEP 1 - UPDATE EXISTING ENCOUNTERS
   ========================================================= */

UPDATE T
SET
    T.patient_id       = S.patient_id,
    T.provider_id      = S.provider_id,
    T.encounter_type   = S.encounter_type,
    T.encounter_start  = S.encounter_start,
    T.encounter_end    = S.encounter_end,
    T.height_cm        = S.height_cm,
    T.weight_kg        = S.weight_kg,
    T.systolic_bp      = S.systolic_bp,
    T.diastolic_bp     = S.diastolic_bp,
    T.last_updated_date = CAST(GETDATE() AS DATE)
FROM refined_dw.refined_encounters AS T
INNER JOIN dev_HealthConnect_cleansed.dbo.cleansed_encounters AS S
    ON T.encounter_id = S.encounter_id
WHERE
       ISNULL(T.patient_id, -1) <> ISNULL(S.patient_id, -1)
    OR ISNULL(T.provider_id, -1) <> ISNULL(S.provider_id, -1)
    OR ISNULL(T.encounter_type, '') <> ISNULL(S.encounter_type, '')
    OR ISNULL(T.encounter_start, '1900-01-01') <> ISNULL(S.encounter_start, '1900-01-01')
    OR ISNULL(T.encounter_end, '1900-01-01') <> ISNULL(S.encounter_end, '1900-01-01')
    OR ISNULL(T.height_cm, -1) <> ISNULL(S.height_cm, -1)
    OR ISNULL(T.weight_kg, -1) <> ISNULL(S.weight_kg, -1)
    OR ISNULL(T.systolic_bp, -1) <> ISNULL(S.systolic_bp, -1)
    OR ISNULL(T.diastolic_bp, -1) <> ISNULL(S.diastolic_bp, -1);
GO

/* =========================================================
   STEP 2 - INSERT NEW ENCOUNTERS
   ========================================================= */

INSERT INTO refined_dw.refined_encounters
(
    encounter_id,
    patient_id,
    provider_id,
    encounter_type,
    encounter_start,
    encounter_end,
    height_cm,
    weight_kg,
    systolic_bp,
    diastolic_bp,
    load_date,
    last_updated_date
)
SELECT
    S.encounter_id,
    S.patient_id,
    S.provider_id,
    S.encounter_type,
    S.encounter_start,
    S.encounter_end,
    S.height_cm,
    S.weight_kg,
    S.systolic_bp,
    S.diastolic_bp,
    S.load_date,
    CAST(GETDATE() AS DATE)
FROM dev_HealthConnect_cleansed.dbo.cleansed_encounters AS S
WHERE NOT EXISTS
(
    SELECT 1
    FROM refined_dw.refined_encounters AS T
    WHERE T.encounter_id = S.encounter_id
);
GO

/* =========================================================
   STEP 3 - VERIFY ROW COUNT
   ========================================================= */

SELECT
    COUNT(*) AS Refined_Encounter_Count
FROM refined_dw.refined_encounters;
GO

/* =========================================================
   STEP 4 - VERIFY REFINED DATA
   ========================================================= */

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
    diastolic_bp,
    load_date,
    last_updated_date
FROM refined_dw.refined_encounters
ORDER BY encounter_id;
GO
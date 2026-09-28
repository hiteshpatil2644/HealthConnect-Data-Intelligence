USE dev_HealthConnect_refined;
GO

/* =========================================================
   CLEANSED → REFINED
   PROCEDURES - SCD TYPE 1
   ========================================================= */

-- 1. Update existing records only when values changed

UPDATE T
SET
    T.encounter_id = S.encounter_id,
    T.procedure_description = S.procedure_description,
    T.last_updated_date = CAST(GETDATE() AS DATE)
FROM refined_dw.refined_procedures AS T
INNER JOIN dev_HealthConnect_cleansed.dbo.cleansed_procedures AS S
    ON T.procedure_id = S.procedure_id
WHERE
    ISNULL(T.encounter_id, -1) <> ISNULL(S.encounter_id, -1)
    OR ISNULL(TRIM(T.procedure_description), '') 
       <> ISNULL(TRIM(S.procedure_description), '');

-- 2. Insert new records

INSERT INTO refined_dw.refined_procedures
(
    procedure_id,
    encounter_id,
    procedure_description,
    load_date,
    last_updated_date
)
SELECT
    S.procedure_id,
    S.encounter_id,
    S.procedure_description,
    S.load_date,
    CAST(GETDATE() AS DATE)
FROM dev_HealthConnect_cleansed.dbo.cleansed_procedures AS S
WHERE NOT EXISTS
(
    SELECT 1
    FROM refined_dw.refined_procedures AS T
    WHERE T.procedure_id = S.procedure_id
);

GO

/* =========================================================
   VALIDATION
   ========================================================= */

SELECT COUNT(*) AS Rows_Loaded
FROM refined_dw.refined_procedures;
GO

SELECT
    procedure_id,
    encounter_id,
    procedure_description,
    load_date,
    last_updated_date
FROM refined_dw.refined_procedures
ORDER BY procedure_id;
GO
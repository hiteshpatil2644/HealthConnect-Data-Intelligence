USE dev_HealthConnect_refined;
GO

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
GO

SELECT
    medication_id,
    drug_name,
    dose,
    load_date,
    last_updated_date
FROM refined_dw.refined_medications
WHERE medication_id = 7001;
GO
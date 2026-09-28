USE dev_HealthConnect_refined;
GO

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
    OR ISNULL(T.procedure_description, '') COLLATE Latin1_General_100_BIN2
       <> ISNULL(S.procedure_description, '') COLLATE Latin1_General_100_BIN2;
GO

SELECT
    procedure_id,
    procedure_description,
    load_date,
    last_updated_date
FROM refined_dw.refined_procedures
WHERE procedure_id = 6001;
GO
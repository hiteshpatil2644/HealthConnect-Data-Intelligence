SELECT
    'CLEANSED' AS Layer,
    procedure_id,
    procedure_description,
    load_date
FROM dev_HealthConnect_cleansed.dbo.cleansed_procedures
WHERE procedure_id = 6001

UNION ALL

SELECT
    'REFINED' AS Layer,
    procedure_id,
    procedure_description,
    load_date
FROM dev_HealthConnect_refined.refined_dw.refined_procedures
WHERE procedure_id = 6001;
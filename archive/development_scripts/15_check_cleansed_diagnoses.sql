USE dev_HealthConnect_cleansed;
GO

DELETE FROM dbo.cleansed_diagnoses;
GO

INSERT INTO dbo.cleansed_diagnoses
(
    diagnosis_id,
    encounter_id,
    diagnosis_description,
    is_primary,
    load_date
)
SELECT
    diagnosis_id,
    encounter_id,
    UPPER(TRIM(diagnosis_description)),
    CAST(is_primary AS VARCHAR(10)),
    CAST(GETDATE() AS DATE)
FROM dev_HealthConnect_raw.dbo.raw_diagnoses;
GO

SELECT COUNT(*) AS Rows_Loaded
FROM dbo.cleansed_diagnoses;
GO

SELECT
    diagnosis_id,
    encounter_id,
    diagnosis_description,
    is_primary,
    load_date
FROM dbo.cleansed_diagnoses
ORDER BY diagnosis_id;
GO
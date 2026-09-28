USE dev_HealthConnect_cleansed;
GO

-- Existing cleansed data remove
DELETE FROM dbo.cleansed_medications;
GO

-- RAW → CLEANSED
INSERT INTO dbo.cleansed_medications
(
    medication_id,
    encounter_id,
    drug_name,
    route,
    dose,
    frequency,
    days_supply,
    load_date
)
SELECT
    medication_id,
    encounter_id,
    UPPER(TRIM(drug_name)),
    UPPER(TRIM(route)),
    UPPER(TRIM(dose)),
    UPPER(TRIM(frequency)),
    days_supply,
    CAST(GETDATE() AS DATE)
FROM dev_HealthConnect_raw.dbo.raw_medications;
GO

-- Validation
SELECT COUNT(*) AS Rows_Loaded
FROM dbo.cleansed_medications;
GO

SELECT
    medication_id,
    encounter_id,
    drug_name,
    route,
    dose,
    frequency,
    days_supply,
    load_date
FROM dbo.cleansed_medications
ORDER BY medication_id;
GO
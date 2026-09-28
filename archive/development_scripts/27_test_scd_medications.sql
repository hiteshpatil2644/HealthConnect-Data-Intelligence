USE dev_HealthConnect_cleansed;
GO

-- Change one attribute in CLEANSED
UPDATE dbo.cleansed_medications
SET
    dose = '10 MG'
WHERE medication_id = 7001;
GO

-- Verify CLEANSED
SELECT
    medication_id,
    drug_name,
    dose,
    load_date
FROM dbo.cleansed_medications
WHERE medication_id = 7001;
GO
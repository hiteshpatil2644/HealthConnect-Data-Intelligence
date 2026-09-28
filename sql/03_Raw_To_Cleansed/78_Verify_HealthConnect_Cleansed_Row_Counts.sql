USE dev_HealthConnect_cleansed;
GO

SELECT 'cleansed_patients' AS Table_Name, COUNT(*) AS Row_Count
FROM dbo.cleansed_patients

UNION ALL

SELECT 'cleansed_providers', COUNT(*)
FROM dbo.cleansed_providers

UNION ALL

SELECT 'cleansed_payers', COUNT(*)
FROM dbo.cleansed_payers

UNION ALL

SELECT 'cleansed_encounters', COUNT(*)
FROM dbo.cleansed_encounters

UNION ALL

SELECT 'cleansed_diagnoses', COUNT(*)
FROM dbo.cleansed_diagnoses

UNION ALL

SELECT 'cleansed_procedures', COUNT(*)
FROM dbo.cleansed_procedures

UNION ALL

SELECT 'cleansed_medications', COUNT(*)
FROM dbo.cleansed_medications

UNION ALL

SELECT 'cleansed_claims', COUNT(*)
FROM dbo.cleansed_claims

ORDER BY Table_Name;
GO

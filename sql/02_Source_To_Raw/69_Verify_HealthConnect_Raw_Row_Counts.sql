USE dev_HealthConnect_raw;
GO

SELECT 'raw_patients' AS Table_Name, COUNT(*) AS Row_Count
FROM dbo.raw_patients

UNION ALL

SELECT 'raw_providers', COUNT(*)
FROM dbo.raw_providers

UNION ALL

SELECT 'raw_payers', COUNT(*)
FROM dbo.raw_payers

UNION ALL

SELECT 'raw_encounters', COUNT(*)
FROM dbo.raw_encounters

UNION ALL

SELECT 'raw_diagnoses', COUNT(*)
FROM dbo.raw_diagnoses

UNION ALL

SELECT 'raw_procedures', COUNT(*)
FROM dbo.raw_procedures

UNION ALL

SELECT 'raw_medications', COUNT(*)
FROM dbo.raw_medications

UNION ALL

SELECT 'raw_claims', COUNT(*)
FROM dbo.raw_claims;
GO
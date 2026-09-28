USE dev_HealthConnect_raw;
GO

DELETE FROM dbo.raw_medications;
GO

BULK INSERT dbo.raw_medications
FROM 'D:\HelthConnect\InboundFiles\medications_20260927.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);
GO

SELECT COUNT(*) AS Rows_Loaded
FROM dbo.raw_medications;
GO

SELECT
    medication_id,
    encounter_id,
    drug_name,
    route,
    dose,
    frequency,
    days_supply
FROM dbo.raw_medications
ORDER BY medication_id;
GO
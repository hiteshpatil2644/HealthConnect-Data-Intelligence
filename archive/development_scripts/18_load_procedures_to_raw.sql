USE dev_HealthConnect_raw;
GO

DELETE FROM dbo.raw_procedures;
GO

BULK INSERT dbo.raw_procedures
FROM 'D:\HelthConnect\InboundFiles\procedures_20260927.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);
GO

SELECT COUNT(*) AS Rows_Loaded
FROM dbo.raw_procedures;
GO

SELECT
    procedure_id,
    encounter_id,
    procedure_description
FROM dbo.raw_procedures
ORDER BY procedure_id;
GO
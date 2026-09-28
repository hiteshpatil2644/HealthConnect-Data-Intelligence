USE dev_HealthConnect_cleansed;
GO

-- Existing cleansed data remove
DELETE FROM dbo.cleansed_procedures;
GO

-- RAW → CLEANSED
INSERT INTO dbo.cleansed_procedures
(
    procedure_id,
    encounter_id,
    procedure_description,
    load_date
)
SELECT
    procedure_id,
    encounter_id,
    UPPER(TRIM(procedure_description)),
    CAST(GETDATE() AS DATE)
FROM dev_HealthConnect_raw.dbo.raw_procedures;
GO

-- Validation
SELECT COUNT(*) AS Rows_Loaded
FROM dbo.cleansed_procedures;
GO

SELECT
    procedure_id,
    encounter_id,
    procedure_description,
    load_date
FROM dbo.cleansed_procedures
ORDER BY procedure_id;
GO
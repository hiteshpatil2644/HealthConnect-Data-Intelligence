USE dev_HealthConnect_raw;
GO

DELETE FROM dbo.raw_claims;
GO

BULK INSERT dbo.raw_claims
FROM 'D:\HelthConnect\InboundFiles\claims_20260927.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);
GO

SELECT COUNT(*) AS Rows_Loaded
FROM dbo.raw_claims;
GO

SELECT
    claim_id,
    encounter_id,
    payer_id,
    admit_date,
    discharge_date,
    total_billed_amount,
    total_allowed_amount,
    total_paid_amount,
    claim_status
FROM dbo.raw_claims
ORDER BY claim_id;
GO
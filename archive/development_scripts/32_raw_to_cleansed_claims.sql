USE dev_HealthConnect_cleansed;
GO

DELETE FROM dbo.cleansed_claims;
GO

INSERT INTO dbo.cleansed_claims
(
    claim_id,
    encounter_id,
    payer_id,
    admit_date,
    discharge_date,
    total_billed_amount,
    total_allowed_amount,
    total_paid_amount,
    claim_status,
    load_date
)
SELECT
    claim_id,
    encounter_id,
    payer_id,
    admit_date,
    discharge_date,
    total_billed_amount,
    total_allowed_amount,
    total_paid_amount,
    UPPER(TRIM(claim_status)),
    CAST(GETDATE() AS DATE)
FROM dev_HealthConnect_raw.dbo.raw_claims;
GO

SELECT COUNT(*) AS Rows_Loaded
FROM dbo.cleansed_claims;
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
    claim_status,
    load_date
FROM dbo.cleansed_claims
ORDER BY claim_id;
GO
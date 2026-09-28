USE dev_HealthConnect_cleansed;
GO

UPDATE dbo.cleansed_claims
SET
    total_paid_amount = 11800
WHERE claim_id = 8001;
GO

SELECT
    claim_id,
    total_billed_amount,
    total_allowed_amount,
    total_paid_amount,
    claim_status,
    load_date
FROM dbo.cleansed_claims
WHERE claim_id = 8001;
GO
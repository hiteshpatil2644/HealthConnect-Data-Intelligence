USE dev_HealthConnect_refined;
GO

UPDATE T
SET
    T.encounter_id = S.encounter_id,
    T.payer_id = S.payer_id,
    T.admit_date = S.admit_date,
    T.discharge_date = S.discharge_date,
    T.total_billed_amount = S.total_billed_amount,
    T.total_allowed_amount = S.total_allowed_amount,
    T.total_paid_amount = S.total_paid_amount,
    T.claim_status = S.claim_status,
    T.last_updated_date = CAST(GETDATE() AS DATE)
FROM refined_dw.refined_claims AS T
INNER JOIN dev_HealthConnect_cleansed.dbo.cleansed_claims AS S
    ON T.claim_id = S.claim_id
WHERE
    ISNULL(T.encounter_id, -1) <> ISNULL(S.encounter_id, -1)
    OR ISNULL(T.payer_id, -1) <> ISNULL(S.payer_id, -1)
    OR ISNULL(T.admit_date, '1900-01-01') <> ISNULL(S.admit_date, '1900-01-01')
    OR ISNULL(T.discharge_date, '1900-01-01') <> ISNULL(S.discharge_date, '1900-01-01')
    OR ISNULL(T.total_billed_amount, -1) <> ISNULL(S.total_billed_amount, -1)
    OR ISNULL(T.total_allowed_amount, -1) <> ISNULL(S.total_allowed_amount, -1)
    OR ISNULL(T.total_paid_amount, -1) <> ISNULL(S.total_paid_amount, -1)
    OR ISNULL(T.claim_status, '') COLLATE Latin1_General_100_BIN2
       <> ISNULL(S.claim_status, '') COLLATE Latin1_General_100_BIN2;
GO

SELECT
    claim_id,
    total_billed_amount,
    total_allowed_amount,
    total_paid_amount,
    claim_status,
    load_date,
    last_updated_date
FROM refined_dw.refined_claims
WHERE claim_id = 8001;
GO
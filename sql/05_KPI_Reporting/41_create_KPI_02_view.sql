USE dev_HealthConnect_refined;
GO

IF OBJECT_ID('refined_dw.vw_KPI_02_Payer_Claim_Summary', 'V') IS NOT NULL
    DROP VIEW refined_dw.vw_KPI_02_Payer_Claim_Summary;
GO

CREATE VIEW refined_dw.vw_KPI_02_Payer_Claim_Summary
AS
SELECT
    P.payer_id,
    P.payer_name,
    SUM(C.total_paid_amount) AS Total_Claim_Amount_Paid,
    COUNT(DISTINCT C.claim_id) AS Number_of_Claims
FROM refined_dw.refined_claims AS C
INNER JOIN refined_dw.refined_payers AS P
    ON C.payer_id = P.payer_id
GROUP BY
    P.payer_id,
    P.payer_name;
GO

SELECT
    payer_id,
    payer_name,
    Total_Claim_Amount_Paid,
    Number_of_Claims
FROM refined_dw.vw_KPI_02_Payer_Claim_Summary
ORDER BY Total_Claim_Amount_Paid DESC;
GO
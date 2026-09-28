USE dev_HealthConnect_refined;
GO

/* =========================================================
   KPI-02
   PAYER-WISE CLAIM SUMMARY

   Metrics:
   1. Total Claim Amount Paid
   2. Number of Claims
   ========================================================= */

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
    P.payer_name

ORDER BY
    Total_Claim_Amount_Paid DESC;
GO
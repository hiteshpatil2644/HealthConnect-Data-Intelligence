USE dev_HealthConnect_refined;
GO

/* =========================================================
   KPI-01
   YEARLY CLAIM TREND

   Metrics:
   1. Total Claim Amount Paid
   2. Number of Claims Processed
   3. Average Claim Amount Paid
   ========================================================= */

SELECT
    YEAR(admit_date) AS Claim_Year,

    SUM(total_paid_amount) AS Total_Claim_Amount_Paid,

    COUNT(DISTINCT claim_id) AS Number_of_Claims_Processed,

    AVG(total_paid_amount) AS Average_Claim_Amount_Paid

FROM refined_dw.refined_claims

WHERE admit_date IS NOT NULL

GROUP BY
    YEAR(admit_date)

ORDER BY
    Claim_Year;
GO
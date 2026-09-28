USE dev_HealthConnect_refined;
GO

/* =========================================================
   KPI-05
   DIAGNOSES CONTRIBUTING MOST TO CLAIM COSTS
   ========================================================= */

SELECT
    d.diagnosis_id,
    d.diagnosis_description,

    SUM(c.total_paid_amount) AS Total_Claim_Amount_Paid,

    COUNT(DISTINCT c.claim_id) AS Number_of_Claims,

    AVG(c.total_paid_amount) AS Average_Claim_Amount_Paid

FROM refined_dw.refined_diagnoses AS d

INNER JOIN refined_dw.refined_claims AS c
    ON d.encounter_id = c.encounter_id

GROUP BY
    d.diagnosis_id,
    d.diagnosis_description

ORDER BY
    Total_Claim_Amount_Paid DESC;
GO
USE dev_HealthConnect_refined;
GO

/* =========================================================
   KPI-07
   GENDER-WISE CLAIM SUMMARY
   ========================================================= */

SELECT
    p.gender,

    SUM(c.total_paid_amount) AS Total_Claim_Amount_Paid,

    COUNT(DISTINCT c.claim_id) AS Number_of_Claims,

    AVG(c.total_paid_amount) AS Average_Claim_Amount

FROM refined_dw.refined_claims AS c

INNER JOIN refined_dw.refined_encounters AS e
    ON c.encounter_id = e.encounter_id

INNER JOIN refined_dw.refined_patients AS p
    ON e.patient_id = p.patient_id

GROUP BY
    p.gender

ORDER BY
    p.gender;
GO
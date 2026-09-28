USE dev_HealthConnect_refined;
GO

IF OBJECT_ID('refined_dw.vw_KPI_07_Gender_Claim_Summary', 'V') IS NOT NULL
    DROP VIEW refined_dw.vw_KPI_07_Gender_Claim_Summary;
GO

CREATE VIEW refined_dw.vw_KPI_07_Gender_Claim_Summary
AS
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
    p.gender;
GO

/* Verify KPI-7 View */

SELECT
    gender,
    Total_Claim_Amount_Paid,
    Number_of_Claims,
    Average_Claim_Amount
FROM refined_dw.vw_KPI_07_Gender_Claim_Summary
ORDER BY
    gender;
GO

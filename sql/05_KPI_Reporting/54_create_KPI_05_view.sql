USE dev_HealthConnect_refined;
GO

IF OBJECT_ID('refined_dw.vw_KPI_05_Diagnosis_Claim_Cost', 'V') IS NOT NULL
    DROP VIEW refined_dw.vw_KPI_05_Diagnosis_Claim_Cost;
GO

CREATE VIEW refined_dw.vw_KPI_05_Diagnosis_Claim_Cost
AS
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
    d.diagnosis_description;
GO

/* Verify KPI-5 View */

SELECT
    diagnosis_id,
    diagnosis_description,
    Total_Claim_Amount_Paid,
    Number_of_Claims,
    Average_Claim_Amount_Paid
FROM refined_dw.vw_KPI_05_Diagnosis_Claim_Cost
ORDER BY
    Total_Claim_Amount_Paid DESC;
GO
USE dev_HealthConnect_refined;
GO

/* =========================================================
   KPI-08
   MOST FREQUENTLY PRESCRIBED MEDICATIONS
   ========================================================= */

SELECT
    medication_id,
    drug_name,

    COUNT(*) AS Prescription_Count

FROM refined_dw.refined_medications

GROUP BY
    medication_id,
    drug_name

ORDER BY
    Prescription_Count DESC,
    drug_name;
GO
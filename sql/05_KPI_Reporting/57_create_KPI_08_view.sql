USE dev_HealthConnect_refined;
GO

IF OBJECT_ID('refined_dw.vw_KPI_08_Medication_Frequency', 'V') IS NOT NULL
    DROP VIEW refined_dw.vw_KPI_08_Medication_Frequency;
GO

CREATE VIEW refined_dw.vw_KPI_08_Medication_Frequency
AS
SELECT
    medication_id,
    drug_name,

    COUNT(*) AS Prescription_Count

FROM refined_dw.refined_medications

GROUP BY
    medication_id,
    drug_name;
GO

/* Verify KPI-8 View */

SELECT
    medication_id,
    drug_name,
    Prescription_Count
FROM refined_dw.vw_KPI_08_Medication_Frequency
ORDER BY
    Prescription_Count DESC,
    drug_name;
GO
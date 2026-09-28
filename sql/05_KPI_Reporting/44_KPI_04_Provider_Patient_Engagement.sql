USE dev_HealthConnect_refined;
GO

/* =========================================================
   KPI-04
   PROVIDER PATIENT ENGAGEMENT OVER 5 YEARS

   Metric:
   Unique patients handled by each provider
   ========================================================= */

SELECT
    p.provider_id,
    CONCAT(
        p.first_name,
        ' ',
        p.last_name
    ) AS Provider_Name,

    p.specialty,

    COUNT(DISTINCT e.patient_id) AS Unique_Patients_Engaged,

    COUNT(DISTINCT e.encounter_id) AS Total_Visits

FROM refined_dw.refined_encounters AS e

INNER JOIN refined_dw.refined_providers AS p
    ON e.provider_id = p.provider_id

WHERE e.encounter_start >= DATEADD(
    YEAR,
    -5,
    (SELECT MAX(encounter_start)
     FROM refined_dw.refined_encounters)
)

GROUP BY
    p.provider_id,
    p.first_name,
    p.last_name,
    p.specialty

ORDER BY
    Unique_Patients_Engaged DESC,
    Total_Visits DESC;
GO

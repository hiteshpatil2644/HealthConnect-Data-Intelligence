USE dev_HealthConnect_refined;
GO

IF OBJECT_ID('refined_dw.vw_KPI_04_Provider_Patient_Engagement', 'V') IS NOT NULL
    DROP VIEW refined_dw.vw_KPI_04_Provider_Patient_Engagement;
GO

CREATE VIEW refined_dw.vw_KPI_04_Provider_Patient_Engagement
AS
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
    (
        SELECT MAX(encounter_start)
        FROM refined_dw.refined_encounters
    )
)

GROUP BY
    p.provider_id,
    p.first_name,
    p.last_name,
    p.specialty;
GO

/* Verify KPI-4 View */

SELECT
    provider_id,
    Provider_Name,
    specialty,
    Unique_Patients_Engaged,
    Total_Visits
FROM refined_dw.vw_KPI_04_Provider_Patient_Engagement
ORDER BY
    Unique_Patients_Engaged DESC,
    Total_Visits DESC;
GO
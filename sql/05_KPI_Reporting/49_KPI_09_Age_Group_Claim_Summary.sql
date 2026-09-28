USE dev_HealthConnect_refined;
GO

/* =========================================================
   KPI-09
   AGE GROUP-WISE CLAIM SUMMARY
   ========================================================= */

SELECT
    CASE
        WHEN DATEDIFF(YEAR, p.date_of_birth, e.encounter_start) < 18
            THEN 'Under 18'

        WHEN DATEDIFF(YEAR, p.date_of_birth, e.encounter_start) BETWEEN 18 AND 30
            THEN '18-30'

        WHEN DATEDIFF(YEAR, p.date_of_birth, e.encounter_start) BETWEEN 31 AND 45
            THEN '31-45'

        WHEN DATEDIFF(YEAR, p.date_of_birth, e.encounter_start) BETWEEN 46 AND 60
            THEN '46-60'

        ELSE '60+'
    END AS Age_Group,

    SUM(c.total_paid_amount) AS Total_Claim_Amount_Paid,

    COUNT(DISTINCT c.claim_id) AS Number_of_Claims

FROM refined_dw.refined_claims AS c

INNER JOIN refined_dw.refined_encounters AS e
    ON c.encounter_id = e.encounter_id

INNER JOIN refined_dw.refined_patients AS p
    ON e.patient_id = p.patient_id

GROUP BY
    CASE
        WHEN DATEDIFF(YEAR, p.date_of_birth, e.encounter_start) < 18
            THEN 'Under 18'

        WHEN DATEDIFF(YEAR, p.date_of_birth, e.encounter_start) BETWEEN 18 AND 30
            THEN '18-30'

        WHEN DATEDIFF(YEAR, p.date_of_birth, e.encounter_start) BETWEEN 31 AND 45
            THEN '31-45'

        WHEN DATEDIFF(YEAR, p.date_of_birth, e.encounter_start) BETWEEN 46 AND 60
            THEN '46-60'

        ELSE '60+'
    END

ORDER BY
    Total_Claim_Amount_Paid DESC;
GO
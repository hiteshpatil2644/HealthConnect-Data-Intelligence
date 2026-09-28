USE dev_HealthConnect_refined;
GO

/* =========================================================
   KPI-06
   YEARLY VISITS, TOTAL CLAIM COST
   AND AVERAGE COST PER VISIT
   ========================================================= */

SELECT
    YEAR(e.encounter_start) AS Visit_Year,

    COUNT(DISTINCT e.encounter_id) AS Total_Visits,

    SUM(c.total_paid_amount) AS Total_Claim_Cost,

    AVG(c.total_paid_amount) AS Average_Cost_Per_Visit

FROM refined_dw.refined_encounters AS e

INNER JOIN refined_dw.refined_claims AS c
    ON e.encounter_id = c.encounter_id

WHERE e.encounter_start IS NOT NULL

GROUP BY
    YEAR(e.encounter_start)

ORDER BY
    Visit_Year;
GO
USE dev_HealthConnect_refined;
GO

IF OBJECT_ID('refined_dw.vw_KPI_06_Yearly_Visit_Cost', 'V') IS NOT NULL
    DROP VIEW refined_dw.vw_KPI_06_Yearly_Visit_Cost;
GO

CREATE VIEW refined_dw.vw_KPI_06_Yearly_Visit_Cost
AS
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
    YEAR(e.encounter_start);
GO

/* Verify KPI-6 View */

SELECT
    Visit_Year,
    Total_Visits,
    Total_Claim_Cost,
    Average_Cost_Per_Visit
FROM refined_dw.vw_KPI_06_Yearly_Visit_Cost
ORDER BY
    Visit_Year;
GO
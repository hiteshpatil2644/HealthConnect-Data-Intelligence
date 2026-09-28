USE dev_HealthConnect_refined;
GO

/* =========================================================
   KPI-10
   AVERAGE INPATIENT STAY DURATION YoY
   AND PERCENTAGE CHANGE
   ========================================================= */

WITH Inpatient_Stay AS
(
    SELECT
        YEAR(e.encounter_start) AS Stay_Year,

        DATEDIFF(
            DAY,
            c.admit_date,
            c.discharge_date
        ) AS Stay_Days

    FROM refined_dw.refined_encounters AS e

    INNER JOIN refined_dw.refined_claims AS c
        ON e.encounter_id = c.encounter_id

    WHERE
        e.encounter_type = 'IPD'
        AND c.admit_date IS NOT NULL
        AND c.discharge_date IS NOT NULL
),

Yearly_Average AS
(
    SELECT
        Stay_Year,

        AVG(
            CAST(Stay_Days AS DECIMAL(10,2))
        ) AS Average_Inpatient_Stay_Days

    FROM Inpatient_Stay

    GROUP BY
        Stay_Year
)

SELECT
    Stay_Year,

    Average_Inpatient_Stay_Days,

    LAG(Average_Inpatient_Stay_Days)
        OVER (
            ORDER BY Stay_Year
        ) AS Previous_Year_Average_Stay_Days,

    CASE
        WHEN LAG(Average_Inpatient_Stay_Days)
             OVER (ORDER BY Stay_Year) IS NULL
        THEN NULL

        WHEN LAG(Average_Inpatient_Stay_Days)
             OVER (ORDER BY Stay_Year) = 0
        THEN NULL

        ELSE
            (
                (
                    Average_Inpatient_Stay_Days
                    -
                    LAG(Average_Inpatient_Stay_Days)
                    OVER (ORDER BY Stay_Year)
                )
                /
                LAG(Average_Inpatient_Stay_Days)
                OVER (ORDER BY Stay_Year)
            ) * 100
    END AS YoY_Percentage_Change

FROM Yearly_Average

ORDER BY
    Stay_Year;
GO
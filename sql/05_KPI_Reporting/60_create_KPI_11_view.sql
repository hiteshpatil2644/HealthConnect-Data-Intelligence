USE dev_HealthConnect_refined;
GO

IF OBJECT_ID('refined_dw.vw_KPI_11_Claim_Paid_YoY_Growth', 'V') IS NOT NULL
    DROP VIEW refined_dw.vw_KPI_11_Claim_Paid_YoY_Growth;
GO

CREATE VIEW refined_dw.vw_KPI_11_Claim_Paid_YoY_Growth
AS
WITH Yearly_Claims AS
(
    SELECT
        YEAR(admit_date) AS Claim_Year,

        SUM(total_paid_amount) AS Total_Paid_Claim_Amount

    FROM refined_dw.refined_claims

    WHERE admit_date IS NOT NULL

    GROUP BY YEAR(admit_date)
)
SELECT
    Claim_Year,

    Total_Paid_Claim_Amount,

    LAG(Total_Paid_Claim_Amount)
        OVER (ORDER BY Claim_Year)
        AS Previous_Year_Paid_Claim_Amount,

    Total_Paid_Claim_Amount
      - LAG(Total_Paid_Claim_Amount)
            OVER (ORDER BY Claim_Year)
        AS Change_Vs_Previous_Year,

    CASE
        WHEN LAG(Total_Paid_Claim_Amount)
                OVER (ORDER BY Claim_Year) IS NULL
            THEN NULL

        WHEN LAG(Total_Paid_Claim_Amount)
                OVER (ORDER BY Claim_Year) = 0
            THEN NULL

        ELSE
        (
            (
                Total_Paid_Claim_Amount
                -
                LAG(Total_Paid_Claim_Amount)
                    OVER (ORDER BY Claim_Year)
            )
            /
            LAG(Total_Paid_Claim_Amount)
                OVER (ORDER BY Claim_Year)
        ) * 100
    END AS YoY_Growth_Percentage

FROM Yearly_Claims;
GO

/* Verify KPI-11 View */

SELECT
    Claim_Year,
    Total_Paid_Claim_Amount,
    Previous_Year_Paid_Claim_Amount,
    Change_Vs_Previous_Year,
    YoY_Growth_Percentage
FROM refined_dw.vw_KPI_11_Claim_Paid_YoY_Growth
ORDER BY Claim_Year;
GO
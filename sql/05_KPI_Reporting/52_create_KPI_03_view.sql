USE dev_HealthConnect_refined;
GO

IF OBJECT_ID('refined_dw.vw_KPI_03_Claim_Period_Summary', 'V') IS NOT NULL
    DROP VIEW refined_dw.vw_KPI_03_Claim_Period_Summary;
GO

CREATE VIEW refined_dw.vw_KPI_03_Claim_Period_Summary
AS
WITH ReferenceDate AS
(
    SELECT
        MAX(admit_date) AS Reference_Date
    FROM refined_dw.refined_claims
),
PeriodDates AS
(
    SELECT
        Reference_Date,

        DATEFROMPARTS(
            YEAR(Reference_Date), 1, 1
        ) AS Current_Year_Start,

        DATEFROMPARTS(
            YEAR(Reference_Date) - 1, 1, 1
        ) AS Previous_Year_Start,

        DATEADD(
            QUARTER,
            DATEDIFF(QUARTER, 0, Reference_Date),
            0
        ) AS Current_Quarter_Start,

        DATEADD(
            QUARTER,
            -1,
            DATEADD(
                QUARTER,
                DATEDIFF(QUARTER, 0, Reference_Date),
                0
            )
        ) AS Previous_Quarter_Start,

        DATEFROMPARTS(
            YEAR(Reference_Date),
            MONTH(Reference_Date),
            1
        ) AS Current_Month_Start,

        DATEADD(
            MONTH,
            -1,
            DATEFROMPARTS(
                YEAR(Reference_Date),
                MONTH(Reference_Date),
                1
            )
        ) AS Previous_Month_Start,

        DATEADD(
            DAY,
            -(DATEPART(WEEKDAY, Reference_Date) - 1),
            Reference_Date
        ) AS Current_Week_Start
    FROM ReferenceDate
),
FinalPeriods AS
(
    SELECT
        *,
        DATEADD(
            DAY,
            -7,
            Current_Week_Start
        ) AS Previous_Week_Start
    FROM PeriodDates
)
SELECT

    Reference_Date,

    SUM(
        CASE
            WHEN admit_date >= Current_Year_Start
             AND admit_date <= Reference_Date
            THEN total_paid_amount
            ELSE 0
        END
    ) AS Current_Year_YTD_Claim_Amount,

    SUM(
        CASE
            WHEN admit_date >= Previous_Year_Start
             AND admit_date <= DATEADD(YEAR, -1, Reference_Date)
            THEN total_paid_amount
            ELSE 0
        END
    ) AS Previous_Year_YTD_Claim_Amount,

    SUM(
        CASE
            WHEN admit_date >= Current_Quarter_Start
             AND admit_date <= Reference_Date
            THEN total_paid_amount
            ELSE 0
        END
    ) AS Current_Quarter_Claim_Amount,

    SUM(
        CASE
            WHEN admit_date >= Previous_Quarter_Start
             AND admit_date < Current_Quarter_Start
            THEN total_paid_amount
            ELSE 0
        END
    ) AS Previous_Quarter_Claim_Amount,

    SUM(
        CASE
            WHEN admit_date >= Current_Month_Start
             AND admit_date <= Reference_Date
            THEN total_paid_amount
            ELSE 0
        END
    ) AS Current_Month_Claim_Amount,

    SUM(
        CASE
            WHEN admit_date >= Previous_Month_Start
             AND admit_date < Current_Month_Start
            THEN total_paid_amount
            ELSE 0
        END
    ) AS Previous_Month_Claim_Amount,

    SUM(
        CASE
            WHEN admit_date >= Current_Week_Start
             AND admit_date <= Reference_Date
            THEN total_paid_amount
            ELSE 0
        END
    ) AS Current_Week_Claim_Amount,

    SUM(
        CASE
            WHEN admit_date >= Previous_Week_Start
             AND admit_date < Current_Week_Start
            THEN total_paid_amount
            ELSE 0
        END
    ) AS Previous_Week_Claim_Amount

FROM refined_dw.refined_claims
CROSS JOIN FinalPeriods
GROUP BY
    Reference_Date;
GO

/* Verify KPI-3 View */

SELECT *
FROM refined_dw.vw_KPI_03_Claim_Period_Summary;
GO
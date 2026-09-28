USE dev_HealthConnect_refined;
GO

/* =========================================================
   KPI-03
   CURRENT / PREVIOUS YEAR
   YTD / QTD / MTD / WTD CLAIM AMOUNT

   Reference Date = Latest available claim date
   ========================================================= */

DECLARE @ReferenceDate DATE;

SELECT
    @ReferenceDate = MAX(admit_date)
FROM refined_dw.refined_claims;


/* =========================================================
   PERIOD START DATES
   ========================================================= */

DECLARE @CurrentYearStart DATE =
    DATEFROMPARTS(YEAR(@ReferenceDate), 1, 1);

DECLARE @PreviousYearStart DATE =
    DATEFROMPARTS(YEAR(@ReferenceDate) - 1, 1, 1);

DECLARE @CurrentQuarterStart DATE =
    DATEADD(
        QUARTER,
        DATEDIFF(QUARTER, 0, @ReferenceDate),
        0
    );

DECLARE @PreviousQuarterStart DATE =
    DATEADD(
        QUARTER,
        -1,
        @CurrentQuarterStart
    );

DECLARE @CurrentMonthStart DATE =
    DATEFROMPARTS(
        YEAR(@ReferenceDate),
        MONTH(@ReferenceDate),
        1
    );

DECLARE @PreviousMonthStart DATE =
    DATEADD(
        MONTH,
        -1,
        @CurrentMonthStart
    );

DECLARE @CurrentWeekStart DATE =
    DATEADD(
        DAY,
        -(DATEPART(WEEKDAY, @ReferenceDate) - 1),
        @ReferenceDate
    );

DECLARE @PreviousWeekStart DATE =
    DATEADD(
        DAY,
        -7,
        @CurrentWeekStart
    );


/* =========================================================
   KPI-03 RESULT
   ========================================================= */

SELECT

    @ReferenceDate AS Reference_Date,

    /* Current Year YTD */
    SUM(
        CASE
            WHEN admit_date >= @CurrentYearStart
             AND admit_date <= @ReferenceDate
            THEN total_paid_amount
            ELSE 0
        END
    ) AS Current_Year_YTD_Claim_Amount,

    /* Previous Year YTD */
    SUM(
        CASE
            WHEN admit_date >= @PreviousYearStart
             AND admit_date <= DATEADD(YEAR, -1, @ReferenceDate)
            THEN total_paid_amount
            ELSE 0
        END
    ) AS Previous_Year_YTD_Claim_Amount,

    /* Current Quarter */
    SUM(
        CASE
            WHEN admit_date >= @CurrentQuarterStart
             AND admit_date <= @ReferenceDate
            THEN total_paid_amount
            ELSE 0
        END
    ) AS Current_Quarter_Claim_Amount,

    /* Previous Quarter */
    SUM(
        CASE
            WHEN admit_date >= @PreviousQuarterStart
             AND admit_date < @CurrentQuarterStart
            THEN total_paid_amount
            ELSE 0
        END
    ) AS Previous_Quarter_Claim_Amount,

    /* Current Month */
    SUM(
        CASE
            WHEN admit_date >= @CurrentMonthStart
             AND admit_date <= @ReferenceDate
            THEN total_paid_amount
            ELSE 0
        END
    ) AS Current_Month_Claim_Amount,

    /* Previous Month */
    SUM(
        CASE
            WHEN admit_date >= @PreviousMonthStart
             AND admit_date < @CurrentMonthStart
            THEN total_paid_amount
            ELSE 0
        END
    ) AS Previous_Month_Claim_Amount,

    /* Current Week */
    SUM(
        CASE
            WHEN admit_date >= @CurrentWeekStart
             AND admit_date <= @ReferenceDate
            THEN total_paid_amount
            ELSE 0
        END
    ) AS Current_Week_Claim_Amount,

    /* Previous Week */
    SUM(
        CASE
            WHEN admit_date >= @PreviousWeekStart
             AND admit_date < @CurrentWeekStart
            THEN total_paid_amount
            ELSE 0
        END
    ) AS Previous_Week_Claim_Amount

FROM refined_dw.refined_claims;
GO
USE dev_HealthConnect_refined;
GO

/* =========================================================
   KPI-03
   CURRENT / PREVIOUS YEAR
   YTD / QTD / MTD / WTD CLAIM AMOUNT

   Reference Date:
   Latest available claim admit_date
   ========================================================= */

DECLARE @ReferenceDate DATE;

SELECT
    @ReferenceDate = MAX(admit_date)
FROM refined_dw.refined_claims;

DECLARE @CurrentYear INT = YEAR(@ReferenceDate);
DECLARE @PreviousYear INT = @CurrentYear - 1;

DECLARE @CurrentQuarter INT =
    DATEPART(QUARTER, @ReferenceDate);

DECLARE @CurrentMonth INT =
    MONTH(@ReferenceDate);

DECLARE @CurrentWeek INT =
    DATEPART(WEEK, @ReferenceDate);


/* =========================================================
   PERIOD START DATES
   ========================================================= */

DECLARE @CurrentYearStart DATE =
    DATEFROMPARTS(@CurrentYear, 1, 1);

DECLARE @PreviousYearStart DATE =
    DATEFROMPARTS(@PreviousYear, 1, 1);

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
        @CurrentYear,
        @CurrentMonth,
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
   KPI RESULT
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
             AND admit_date < DATEFROMPARTS(@PreviousYear, MONTH(@ReferenceDate), DAY(@ReferenceDate) + 1)
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
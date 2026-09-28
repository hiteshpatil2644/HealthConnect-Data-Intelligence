/* =========================================================
   HEALTHCONNECT - FINAL DATA QUALITY & PIPELINE VERIFICATION
   ========================================================= */

USE dev_HealthConnect_raw;
GO

SELECT 'RAW' AS Layer_Name, SUM(Row_Count) AS Total_Rows,
       CASE WHEN SUM(Row_Count) = 40 THEN 'PASS' ELSE 'CHECK' END AS Status
FROM
(
    SELECT COUNT(*) AS Row_Count FROM dbo.raw_patients
    UNION ALL SELECT COUNT(*) FROM dbo.raw_providers
    UNION ALL SELECT COUNT(*) FROM dbo.raw_payers
    UNION ALL SELECT COUNT(*) FROM dbo.raw_encounters
    UNION ALL SELECT COUNT(*) FROM dbo.raw_diagnoses
    UNION ALL SELECT COUNT(*) FROM dbo.raw_procedures
    UNION ALL SELECT COUNT(*) FROM dbo.raw_medications
    UNION ALL SELECT COUNT(*) FROM dbo.raw_claims
) x;
GO

USE dev_HealthConnect_cleansed;
GO

SELECT 'CLEANSED' AS Layer_Name, SUM(Row_Count) AS Total_Rows,
       CASE WHEN SUM(Row_Count) = 40 THEN 'PASS' ELSE 'CHECK' END AS Status
FROM
(
    SELECT COUNT(*) AS Row_Count FROM dbo.cleansed_patients
    UNION ALL SELECT COUNT(*) FROM dbo.cleansed_providers
    UNION ALL SELECT COUNT(*) FROM dbo.cleansed_payers
    UNION ALL SELECT COUNT(*) FROM dbo.cleansed_encounters
    UNION ALL SELECT COUNT(*) FROM dbo.cleansed_diagnoses
    UNION ALL SELECT COUNT(*) FROM dbo.cleansed_procedures
    UNION ALL SELECT COUNT(*) FROM dbo.cleansed_medications
    UNION ALL SELECT COUNT(*) FROM dbo.cleansed_claims
) x;
GO

USE dev_HealthConnect_refined;
GO

SELECT 'REFINED' AS Layer_Name, SUM(Row_Count) AS Total_Rows,
       CASE WHEN SUM(Row_Count) = 40 THEN 'PASS' ELSE 'CHECK' END AS Status
FROM
(
    SELECT COUNT(*) AS Row_Count FROM refined_dw.refined_patients
    UNION ALL SELECT COUNT(*) FROM refined_dw.refined_providers
    UNION ALL SELECT COUNT(*) FROM refined_dw.refined_payers
    UNION ALL SELECT COUNT(*) FROM refined_dw.refined_encounters
    UNION ALL SELECT COUNT(*) FROM refined_dw.refined_diagnoses
    UNION ALL SELECT COUNT(*) FROM refined_dw.refined_procedures
    UNION ALL SELECT COUNT(*) FROM refined_dw.refined_medications
    UNION ALL SELECT COUNT(*) FROM refined_dw.refined_claims
) x;
GO

SELECT
    patient_id,
    first_name,
    last_name,
    city,
    phone,
    load_date,
    last_updated_date
FROM refined_dw.refined_patients
WHERE patient_id = 1001;
GO

SELECT
    COUNT(*) AS Total_Claims,
    SUM(total_paid_amount) AS Total_Paid_Amount,
    CASE
        WHEN COUNT(*) = 5 AND SUM(total_paid_amount) = 177800
        THEN 'PASS' ELSE 'CHECK'
    END AS Status
FROM refined_dw.refined_claims;
GO

USE dev_HealthConnect_raw;
GO

SELECT TOP 1
    Run_ID,
    Process_Name,
    Start_Time,
    End_Time,
    Status,
    Row_Count,
    Error_Message,
    CASE
        WHEN Status = 'SUCCESS' AND Row_Count > 0 AND Error_Message IS NULL
        THEN 'PASS' ELSE 'CHECK'
    END AS Verification_Status
FROM dbo.HealthConnect_ETL_Log
ORDER BY Run_ID DESC;
GO

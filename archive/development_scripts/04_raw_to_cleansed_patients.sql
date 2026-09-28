/* =========================================================
   HEALTHCONNECT
   RAW -> CLEANSED
   PATIENT LOAD
   ========================================================= */

USE dev_HealthConnect_cleansed;
GO


/* =========================================================
   STEP 1 - CLEAR PREVIOUS CLEANSED DATA
   ========================================================= */

DELETE FROM dbo.cleansed_patients;
GO


/* =========================================================
   STEP 2 - LOAD RAW -> CLEANSED
   ========================================================= */

INSERT INTO dbo.cleansed_patients
(
    patient_id,
    first_name,
    last_name,
    gender,
    date_of_birth,
    state_code,
    city,
    phone,
    load_date
)
SELECT
    patient_id,
    UPPER(TRIM(first_name)),
    UPPER(TRIM(last_name)),
    UPPER(TRIM(gender)),
    date_of_birth,
    UPPER(TRIM(state_code)),
    UPPER(TRIM(city)),
    UPPER(TRIM(phone)),
    CAST(GETDATE() AS DATE)
FROM dev_HealthConnect_raw.dbo.raw_patients;
GO


/* =========================================================
   STEP 3 - VERIFY ROW COUNT
   ========================================================= */

SELECT
    COUNT(*) AS Rows_Loaded
FROM dbo.cleansed_patients;
GO


/* =========================================================
   STEP 4 - VERIFY CLEANSED DATA
   ========================================================= */

SELECT
    patient_id,
    first_name,
    last_name,
    gender,
    date_of_birth,
    state_code,
    city,
    phone,
    load_date
FROM dbo.cleansed_patients
ORDER BY patient_id;
GO
/* =========================================================
   HEALTHCONNECT - REFINED LAYER TABLES
   Database: dev_HealthConnect_refined
   Schema: refined_dw

   NOTE: Source-to-RAW loading is handled by the dedicated
   Source_To_Raw stored procedures. This file only creates
   the REFINED schema and tables.
   ========================================================= */

USE dev_HealthConnect_refined;
GO


/* Create Refined Schema */

IF NOT EXISTS
(
    SELECT 1
    FROM sys.schemas
    WHERE name = 'refined_dw'
)
BEGIN
    EXEC('CREATE SCHEMA refined_dw');
END;
GO


/* =========================================================
   1. REFINED PATIENTS
   ========================================================= */

CREATE TABLE refined_dw.refined_patients
(
    patient_id         INT PRIMARY KEY,
    first_name         VARCHAR(50),
    last_name          VARCHAR(50),
    gender             CHAR(1),
    date_of_birth      DATE,
    state_code         CHAR(2),
    city               VARCHAR(50),
    phone              VARCHAR(15),
    load_date          DATE,
    last_updated_date  DATE
);
GO


/* =========================================================
   2. REFINED PROVIDERS
   ========================================================= */

CREATE TABLE refined_dw.refined_providers
(
    provider_id        INT PRIMARY KEY,
    first_name         VARCHAR(50),
    last_name          VARCHAR(50),
    specialty          VARCHAR(50),
    npi                VARCHAR(20),
    load_date          DATE,
    last_updated_date  DATE
);
GO


/* =========================================================
   3. REFINED PAYERS
   ========================================================= */

CREATE TABLE refined_dw.refined_payers
(
    payer_id           INT PRIMARY KEY,
    payer_name         VARCHAR(100),
    load_date          DATE,
    last_updated_date  DATE
);
GO


/* =========================================================
   4. REFINED ENCOUNTERS
   ========================================================= */

CREATE TABLE refined_dw.refined_encounters
(
    encounter_id       INT PRIMARY KEY,
    patient_id         INT,
    provider_id        INT,
    encounter_type     VARCHAR(10),
    encounter_start    DATETIME,
    encounter_end      DATETIME,
    height_cm          INT,
    weight_kg          FLOAT,
    systolic_bp        INT,
    diastolic_bp       INT,
    load_date          DATE,
    last_updated_date  DATE
);
GO


/* =========================================================
   5. REFINED DIAGNOSES
   ========================================================= */

CREATE TABLE refined_dw.refined_diagnoses
(
    diagnosis_id          INT PRIMARY KEY,
    encounter_id          INT,
    diagnosis_description VARCHAR(100),
    is_primary            VARCHAR(10),
    load_date             DATE,
    last_updated_date     DATE
);
GO


/* =========================================================
   6. REFINED PROCEDURES
   ========================================================= */

CREATE TABLE refined_dw.refined_procedures
(
    procedure_id          INT PRIMARY KEY,
    encounter_id          INT,
    procedure_description VARCHAR(100),
    load_date             DATE,
    last_updated_date     DATE
);
GO


/* =========================================================
   7. REFINED MEDICATIONS
   ========================================================= */

CREATE TABLE refined_dw.refined_medications
(
    medication_id      INT PRIMARY KEY,
    encounter_id       INT,
    drug_name          VARCHAR(50),
    route              VARCHAR(20),
    dose               VARCHAR(20),
    frequency          VARCHAR(10),
    days_supply        INT,
    load_date          DATE,
    last_updated_date  DATE
);
GO


/* =========================================================
   8. REFINED CLAIMS
   ========================================================= */

CREATE TABLE refined_dw.refined_claims
(
    claim_id              INT PRIMARY KEY,
    encounter_id          INT,
    payer_id              INT,
    admit_date            DATE,
    discharge_date        DATE,
    total_billed_amount   FLOAT,
    total_allowed_amount  FLOAT,
    total_paid_amount     FLOAT,
    claim_status          VARCHAR(20),
    load_date             DATE,
    last_updated_date     DATE
);
GO


/* =========================================================
   VERIFY REFINED TABLES
   ========================================================= */

SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'refined_dw'
ORDER BY TABLE_NAME;
GO
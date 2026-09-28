USE dev_HealthConnect_cleansed;
GO

/* =========================================================
   HEALTHCONNECT - CLEANSED LAYER TABLES
   ========================================================= */

CREATE TABLE dbo.cleansed_patients
(
    patient_id      INT PRIMARY KEY,
    first_name      VARCHAR(50),
    last_name       VARCHAR(50),
    gender          CHAR(1),
    date_of_birth   DATE,
    state_code      CHAR(2),
    city            VARCHAR(50),
    phone           VARCHAR(15),
    load_date       DATE
);
GO

CREATE TABLE dbo.cleansed_providers
(
    provider_id     INT PRIMARY KEY,
    first_name      VARCHAR(50),
    last_name       VARCHAR(50),
    specialty       VARCHAR(50),
    npi             VARCHAR(20),
    load_date       DATE
);
GO

CREATE TABLE dbo.cleansed_payers
(
    payer_id        INT PRIMARY KEY,
    payer_name      VARCHAR(100),
    load_date       DATE
);
GO

CREATE TABLE dbo.cleansed_encounters
(
    encounter_id    INT PRIMARY KEY,
    patient_id      INT,
    provider_id     INT,
    encounter_type  VARCHAR(10),
    encounter_start DATETIME,
    encounter_end   DATETIME,
    height_cm       INT,
    weight_kg       FLOAT,
    systolic_bp     INT,
    diastolic_bp    INT,
    load_date       DATE
);
GO

CREATE TABLE dbo.cleansed_diagnoses
(
    diagnosis_id          INT PRIMARY KEY,
    encounter_id          INT,
    diagnosis_description VARCHAR(100),
    is_primary            VARCHAR(10),
    load_date             DATE
);
GO

CREATE TABLE dbo.cleansed_procedures
(
    procedure_id          INT PRIMARY KEY,
    encounter_id          INT,
    procedure_description VARCHAR(100),
    load_date             DATE
);
GO

CREATE TABLE dbo.cleansed_medications
(
    medication_id INT PRIMARY KEY,
    encounter_id  INT,
    drug_name     VARCHAR(50),
    route         VARCHAR(20),
    dose          VARCHAR(20),
    frequency     VARCHAR(10),
    days_supply   INT,
    load_date     DATE
);
GO

CREATE TABLE dbo.cleansed_claims
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
    load_date             DATE
);
GO

/* VERIFY */

SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo'
ORDER BY TABLE_NAME;
GO
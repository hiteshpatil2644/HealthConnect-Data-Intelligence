USE dev_HealthConnect_refined;
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

USE dev_HealthConnect_refined;
GO

UPDATE dev_HealthConnect_cleansed.dbo.cleansed_patients
SET
    city = 'MUMBAI',
    phone = '9999999999'
WHERE patient_id = 1001;
GO

USE dev_HealthConnect_refined;
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

EXEC dbo.Proc_HealthConnect_Cleansed_To_Refined_Patients_Load;
GO
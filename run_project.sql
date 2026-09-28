/* HealthConnect - one-click end-to-end execution
   Use this in VS Code MSSQL after connecting to Hitesh\SQLEXPRESS.
*/

USE dev_HealthConnect_raw;
GO

EXEC dbo.Proc_HealthConnect_End_To_End_Master_Load_With_Logging
    @PatientsFilePath = N'D:\HelthConnect\InboundFiles\patients_20260927.csv',
    @ProvidersFilePath = N'D:\HelthConnect\InboundFiles\providers_20260927.csv',
    @PayersFilePath = N'D:\HelthConnect\InboundFiles\payers_20260927.csv',
    @EncountersFilePath = N'D:\HelthConnect\InboundFiles\encounters_20260927.csv',
    @DiagnosesFilePath = N'D:\HelthConnect\InboundFiles\diagnoses_20260927.csv',
    @ProceduresFilePath = N'D:\HelthConnect\InboundFiles\procedures_20260927.csv',
    @MedicationsFilePath = N'D:\HelthConnect\InboundFiles\medications_20260927.csv',
    @ClaimsFilePath = N'D:\HelthConnect\InboundFiles\claims_20260927.csv';
GO

:r sql\08_Verification\91_Final_HealthConnect_Data_Quality_Verification.sql

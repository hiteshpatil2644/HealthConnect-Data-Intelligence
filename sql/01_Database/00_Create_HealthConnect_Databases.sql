/* =========================================================
   HEALTHCONNECT - DATABASE CREATION
   Run this file once while connected to master.
   ========================================================= */

USE master;
GO

IF DB_ID(N'dev_HealthConnect_raw') IS NULL
BEGIN
    CREATE DATABASE dev_HealthConnect_raw;
END;
GO

IF DB_ID(N'dev_HealthConnect_cleansed') IS NULL
BEGIN
    CREATE DATABASE dev_HealthConnect_cleansed;
END;
GO

IF DB_ID(N'dev_HealthConnect_refined') IS NULL
BEGIN
    CREATE DATABASE dev_HealthConnect_refined;
END;
GO

SELECT name
FROM sys.databases
WHERE name IN
(
    N'dev_HealthConnect_raw',
    N'dev_HealthConnect_cleansed',
    N'dev_HealthConnect_refined'
)
ORDER BY name;
GO

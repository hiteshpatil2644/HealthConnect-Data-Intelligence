# HealthConnect Data Intelligence

SQL Server healthcare ETL and data warehouse project using CSV source data, RAW/CLEANSED/REFINED layers, SCD Type 1, KPI reporting, and ETL logging.

## Architecture

CSV Source -> RAW -> CLEANSED -> REFINED -> KPI / Reporting

## Databases

- `dev_HealthConnect_raw`
- `dev_HealthConnect_cleansed`
- `dev_HealthConnect_refined`

## Source Data

The sample CSV files are included under:

`source_data/InboundFiles/`

## One-command run

From PowerShell:

```powershell
cd C:\Users\Legion\Downloads\HealthConnect
.\run_healthconnect.ps1
```

The launcher:

1. checks `sqlcmd.exe`
2. checks all 8 CSV files
3. copies the CSV files to `D:\HelthConnect\InboundFiles` when the D: drive is available
4. connects to local `SQLEXPRESS` using shared memory (`lpc`)
5. executes the logged end-to-end procedure
6. reports success/failure

Microsoft documents `lpc` as the shared-memory protocol for local `sqlcmd` connections. This avoids the SQL Server Browser/TCP discovery issue on this machine.

## VS Code fallback

Open `run_project.sql` in VS Code with the MSSQL extension and execute it after connecting to the HealthConnect SQL Server instance.

## SQL execution order for a fresh database

1. Run `sql/01_Database/00_Create_HealthConnect_Databases.sql` from the `master` database.
2. Run the remaining files in `sql/01_Database/`.
3. Continue with the numbered ETL folders.

The supplied package is already organized so that master procedure files only create/alter procedures; they do not unexpectedly execute the pipeline when opened.

### Recommended order

1. `sql/01_Database/`
2. `sql/02_Source_To_Raw/`
3. `sql/03_Raw_To_Cleansed/`
4. `sql/04_Cleansed_To_Refined/`
5. `sql/05_KPI_Reporting/`
6. `sql/06_Master_ETL/`
7. `sql/07_Logging/`
8. `sql/08_Verification/`

## Important

The project already contains working database objects from development. The PowerShell runner assumes the databases and end-to-end procedures have been created.

## Expected sample result

The supplied sample data contains 5 rows in each of the 8 entities, giving 40 rows per layer. The sample claims have a total paid amount of `177800`.

## SCD Type 1

Existing business keys are updated in place; no historical version row is retained. `load_date` records the initial load and `last_updated_date` records the latest update.

## Project deliverables

- ETL stored procedures
- RAW/CLEANSED/REFINED database layers
- SCD Type 1 implementation
- 11 KPI reporting views/queries
- End-to-End master procedure
- ETL execution log
- Final data-quality verification
- Sample source data
- Technical and data-model documentation

$ErrorActionPreference = 'Stop'

# =========================================================
# HealthConnect - One Command ETL Runner
# =========================================================

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SqlCmd = "C:\Program Files\SqlCmd\sqlcmd.exe"

if (!(Test-Path $SqlCmd)) {
    $cmd = Get-Command sqlcmd.exe -ErrorAction SilentlyContinue
    if ($cmd) { $SqlCmd = $cmd.Source }
}

$ServerCandidates = @(
    "lpc:localhost\SQLEXPRESS",
    "lpc:Hitesh\SQLEXPRESS",
    "lpc:.\SQLEXPRESS"
)

$LocalInbound = Join-Path $ProjectRoot "source_data\InboundFiles"
$SqlServerInbound = "D:\HelthConnect\InboundFiles"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " HealthConnect ETL Pipeline" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------
# 1. SQLCMD
# ---------------------------------------------------------
if (!(Test-Path $SqlCmd)) {
    Write-Host "FAILED: sqlcmd.exe was not found." -ForegroundColor Red
    Write-Host "Expected: C:\Program Files\SqlCmd\sqlcmd.exe"
    exit 1
}

Write-Host "SQLCMD: $SqlCmd" -ForegroundColor Green

# ---------------------------------------------------------
# 2. SOURCE FILES
# ---------------------------------------------------------
$Names = @(
    "patients_20260927.csv",
    "providers_20260927.csv",
    "payers_20260927.csv",
    "encounters_20260927.csv",
    "diagnoses_20260927.csv",
    "procedures_20260927.csv",
    "medications_20260927.csv",
    "claims_20260927.csv"
)

Write-Host ""
Write-Host "Checking project source files..."

foreach ($Name in $Names) {
    $Path = Join-Path $LocalInbound $Name
    if (!(Test-Path $Path)) {
        Write-Host "FAILED: Missing source file: $Path" -ForegroundColor Red
        exit 1
    }
    Write-Host "FOUND: $Name" -ForegroundColor Green
}

# ---------------------------------------------------------
# 3. PUT FILES IN THE WORKING SQL SERVER INBOUND FOLDER
#    The existing BULK INSERT procedures are already tested
#    against D:\HelthConnect\InboundFiles on this machine.
# ---------------------------------------------------------
$Inbound = $LocalInbound

if (Test-Path "D:\") {
    try {
        if (!(Test-Path $SqlServerInbound)) {
            New-Item -ItemType Directory -Path $SqlServerInbound -Force | Out-Null
        }

        foreach ($Name in $Names) {
            Copy-Item (Join-Path $LocalInbound $Name) (Join-Path $SqlServerInbound $Name) -Force
        }

        $Inbound = $SqlServerInbound
        Write-Host ""
        Write-Host "SQL Server inbound folder: $Inbound" -ForegroundColor Green
    }
    catch {
        Write-Host "WARNING: Could not copy to $SqlServerInbound." -ForegroundColor Yellow
        Write-Host "Using project source folder instead: $LocalInbound" -ForegroundColor Yellow
        $Inbound = $LocalInbound
    }
}
else {
    Write-Host ""
    Write-Host "D: drive not found. Using project source folder:" -ForegroundColor Yellow
    Write-Host $LocalInbound -ForegroundColor Yellow
}

$Patients    = Join-Path $Inbound "patients_20260927.csv"
$Providers   = Join-Path $Inbound "providers_20260927.csv"
$Payers      = Join-Path $Inbound "payers_20260927.csv"
$Encounters  = Join-Path $Inbound "encounters_20260927.csv"
$Diagnoses   = Join-Path $Inbound "diagnoses_20260927.csv"
$Procedures  = Join-Path $Inbound "procedures_20260927.csv"
$Medications = Join-Path $Inbound "medications_20260927.csv"
$Claims      = Join-Path $Inbound "claims_20260927.csv"

# ---------------------------------------------------------
# 4. FIND A WORKING LOCAL SQL SERVER CONNECTION
# ---------------------------------------------------------
$ConnectionServer = $null

Write-Host ""
Write-Host "Checking SQL Server connection..."

foreach ($Candidate in $ServerCandidates) {
    try {
        $result = & $SqlCmd -S $Candidate -E -Q "SET NOCOUNT ON; SELECT @@SERVERNAME;" -b 2>$null
        if ($LASTEXITCODE -eq 0) {
            $ConnectionServer = $Candidate
            Write-Host "Connected: $Candidate" -ForegroundColor Green
            break
        }
    }
    catch {
        # Try the next candidate.
    }
}

if ($null -eq $ConnectionServer) {
    Write-Host "FAILED: Could not connect to SQLEXPRESS using shared memory." -ForegroundColor Red
    Write-Host ""
    Write-Host "Try this manual test:" -ForegroundColor Yellow
    Write-Host '& "C:\Program Files\SqlCmd\sqlcmd.exe" -S "lpc:localhost\SQLEXPRESS" -E -Q "SELECT @@SERVERNAME;"'
    exit 1
}

# ---------------------------------------------------------
# 5. BUILD EXECUTION SQL
# ---------------------------------------------------------
$Sql = @"
EXEC dbo.Proc_HealthConnect_End_To_End_Master_Load_With_Logging
    @PatientsFilePath = N'$Patients',
    @ProvidersFilePath = N'$Providers',
    @PayersFilePath = N'$Payers',
    @EncountersFilePath = N'$Encounters',
    @DiagnosesFilePath = N'$Diagnoses',
    @ProceduresFilePath = N'$Procedures',
    @MedicationsFilePath = N'$Medications',
    @ClaimsFilePath = N'$Claims';
"@

Write-Host ""
Write-Host "Running HealthConnect End-to-End ETL..." -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------
# 6. EXECUTE
# ---------------------------------------------------------
& $SqlCmd `
    -S $ConnectionServer `
    -E `
    -d dev_HealthConnect_raw `
    -Q $Sql `
    -b

$ExitCode = $LASTEXITCODE

Write-Host ""

if ($ExitCode -ne 0) {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host " HEALTHCONNECT PIPELINE FAILED" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "SQLCMD Exit Code: $ExitCode" -ForegroundColor Red
    exit $ExitCode
}

# ---------------------------------------------------------
# 7. FINAL STATUS
# ---------------------------------------------------------
Write-Host "========================================" -ForegroundColor Green
Write-Host " HEALTHCONNECT PIPELINE SUCCESS" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "SOURCE -> RAW        : DONE"
Write-Host "RAW -> CLEANSED      : DONE"
Write-Host "CLEANSED -> REFINED  : DONE"
Write-Host "SCD TYPE 1           : DONE"
Write-Host "ETL LOG              : DONE"
Write-Host ""
Write-Host "Project completed successfully." -ForegroundColor Green

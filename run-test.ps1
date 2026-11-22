Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Work = $PSScriptRoot
. (Join-Path $Work 'config-test.ps1')
foreach ($dir in 'out','backups','logs') {
    New-Item -ItemType Directory -Force -Path (Join-Path $Work $dir) | Out-Null
}
$Log = Join-Path $Work 'logs\run.log'
$Stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
function Write-Log([string]$Level,[string]$Message) {
    "$(Get-Date -Format o) [$Level] $Message" | Add-Content -LiteralPath $Log -Encoding UTF8
}

function Invoke-Db([string]$Query) {
    & $Client -X -w -h $DbHost -p $DbPort -U admin -d $Database -v ON_ERROR_STOP=1 -A -t -c $Query
    if ($LASTEXITCODE -ne 0) { throw "psql exit=$LASTEXITCODE" }
}
function Backup-Db([string]$File) {
    & $Dump -w -h $DbHost -p $DbPort -U admin -d $Database -Fc -f $File
    if ($LASTEXITCODE -ne 0) { throw "pg_dump exit=$LASTEXITCODE" }
}

function Invoke-Task {
    $File = Join-Path $Work "backups\$($Database)_$Stamp.dump"
    Backup-Db $File
    $Expected = (Get-FileHash -LiteralPath $File -Algorithm SHA256).Hash
    $Expected | Set-Content -LiteralPath "$File.sha256.txt"
    $Actual = (Get-FileHash -LiteralPath $File -Algorithm SHA256).Hash
    if ($Actual -ne $Expected) { throw 'SHA-256 mismatch' }
    Write-Log INFO "archive=$File sha256=$Actual"
}
try {
    Write-Log INFO "START db=$Database"
    Invoke-Task
    Write-Log INFO 'END result=OK'
    exit 0
} catch {
    Write-Log ERROR $_.Exception.Message
    exit 1
}

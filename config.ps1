$Database = 'pm07_v23'
$DbHost = '127.0.0.1'
$DbPort = '5432'
$Client = 'C:\Program Files\PostgreSQL\16\bin\psql.exe'
$Dump = 'C:\Program Files\PostgreSQL\16\bin\pg_dump.exe'
$Work = $PSScriptRoot
$env:PGPASSFILE = Join-Path $Work 'auth\pgpass.conf'

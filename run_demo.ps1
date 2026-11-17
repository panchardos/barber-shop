param(
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

Push-Location $root
try {
    $envFile = Join-Path $root "server\.env"
    if (-not (Test-Path -LiteralPath $envFile)) {
        throw "Falta server/.env. Copiá server/.env.example a server/.env y completá las credenciales."
    }

    if (-not $SkipBuild) {
        Write-Host "Compilando Flutter Web..." -ForegroundColor Cyan
        flutter build web --release
    }

    $ips = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object {
            $_.IPAddress -notlike "127.*" -and
            $_.IPAddress -notlike "169.254.*"
        } |
        Select-Object -ExpandProperty IPAddress

    Write-Host ""
    Write-Host "Iniciando servidor de demo..." -ForegroundColor Cyan
    Write-Host "Local: http://localhost:8080"
    foreach ($ip in $ips) {
        Write-Host "Celular/Wi-Fi: http://$ip`:8080"
    }
    Write-Host ""

    Push-Location (Join-Path $root "server")
    try {
        dart pub get
        dart run bin/server.dart
    } finally {
        Pop-Location
    }
} finally {
    Pop-Location
}

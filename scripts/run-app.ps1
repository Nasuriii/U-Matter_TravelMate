param([switch]$Check, [switch]$NoBrowser)

$ErrorActionPreference = 'Stop'
$browserJob = $null
$appDirectory = Join-Path (Split-Path -Parent $PSScriptRoot) 'app'
$appUrl = 'http://localhost:5173'

function Get-LocalServerState([string]$url) {
    $endpoint = [uri]$url
    try {
        $page = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 3
        if ($page.Content -match '<title>TravelMate' -and $page.Content -match '/src/main.ts') { return 'travelmate' }
    } catch { }
    # Vite can bind to IPv6 ::1; a default IPv4 TcpClient misses that listener.
    foreach ($address in [System.Net.Dns]::GetHostAddresses($endpoint.Host)) {
        $connection = New-Object -TypeName System.Net.Sockets.TcpClient -ArgumentList $address.AddressFamily
        try {
            $pending = $connection.ConnectAsync($address, $endpoint.Port)
            if ($pending.Wait(1000) -and $connection.Connected) { return 'occupied' }
        } catch { }
        finally { $connection.Dispose() }
    }
    return 'stopped'
}

try {
    if (-not (Test-Path -LiteralPath (Join-Path $appDirectory 'package.json'))) {
        throw 'The app folder is missing. Keep run-app.bat, scripts, and app together.'
    }
    $nodeCommand = Get-Command node.exe -ErrorAction SilentlyContinue
    $npmCommand = Get-Command npm.cmd -ErrorAction SilentlyContinue
    if (-not $nodeCommand -or -not $npmCommand) {
        throw 'Install Node.js 22.12 or newer from https://nodejs.org, then reopen the launcher.'
    }
    $nodeVersion = (& $nodeCommand.Source --version).Trim().TrimStart('v')
    if ($LASTEXITCODE -ne 0 -or [version]$nodeVersion -lt [version]'22.12.0') {
        throw 'TravelMate requires Node.js 22.12 or newer.'
    }
    Write-Host "TravelMate | Node $nodeVersion"
    Set-Location -LiteralPath $appDirectory

    $configuration = @{}
    foreach ($file in @('.env', '.env.local')) {
        if (Test-Path -LiteralPath $file) {
            foreach ($line in Get-Content -LiteralPath $file) {
                if ($line -match '^\s*(VITE_SUPABASE_URL|VITE_SUPABASE_PUBLISHABLE_KEY)\s*=\s*(.*?)\s*$') {
                    $configuration[$Matches[1]] = $Matches[2].Trim('"', "'")
                }
            }
        }
    }
    foreach ($name in @('VITE_SUPABASE_URL', 'VITE_SUPABASE_PUBLISHABLE_KEY')) {
        if (-not $configuration[$name] -or $configuration[$name] -match 'YOUR_PROJECT_REF|YOUR_PUBLISHABLE_KEY') {
            throw "Set $name in app/.env.local using app/.env.example as a guide."
        }
    }
    if ($configuration['VITE_SUPABASE_URL'] -notmatch '^https?://') {
        throw 'VITE_SUPABASE_URL must be an http or https URL.'
    }

    $serverState = Get-LocalServerState $appUrl
    if ($serverState -eq 'occupied') {
        throw 'Port 5173 is used by another app. Close that app or its dev server, then retry.'
    }
    if ($Check) {
        Write-Host "[READY] Runtime and configuration are valid. Server: $serverState."
        exit 0
    }
    if ($serverState -eq 'travelmate') {
        Write-Host "[READY] TravelMate is already running at $appUrl"
        if (-not $NoBrowser) { Start-Process $appUrl }
        exit 0
    }

    if (-not (Test-Path -LiteralPath 'node_modules/.bin/vite.cmd') -or -not (Test-Path -LiteralPath 'node_modules/.bin/tsc.cmd')) {
        Write-Host '[SETUP] Installing missing app dependencies.'
        # Repair an existing install without removing native files that Windows may have locked.
        $installCommand = if (Test-Path -LiteralPath 'node_modules') { 'install' } else { 'ci' }
        & $npmCommand.Source $installCommand --no-audit --no-fund
        if ($LASTEXITCODE -ne 0) { throw 'Dependency installation failed. Check the npm message and your internet connection, then retry.' }
    }

    if (-not $NoBrowser) {
        # This hidden job opens the browser only after Vite can serve the page.
        $browserJob = Start-Job -ArgumentList $appUrl -ScriptBlock {
            param($url)
            for ($attempt = 0; $attempt -lt 40; $attempt++) {
                try {
                    $page = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 1
                    if ($page.Content -match '<title>TravelMate') { Start-Process $url; return }
                } catch { }
                Start-Sleep -Milliseconds 250
            }
        }
    }
    Write-Host "[START] $appUrl | Press Ctrl+C to stop the server."
    & $npmCommand.Source run dev
    if ($LASTEXITCODE -ne 0) { throw 'The dev server stopped with an error. Review the Vite message above.' }
} catch {
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    if ($browserJob) {
        Stop-Job -Job $browserJob -ErrorAction SilentlyContinue
        Remove-Job -Job $browserJob -Force -ErrorAction SilentlyContinue
    }
}

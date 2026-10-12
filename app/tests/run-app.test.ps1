$ErrorActionPreference = 'Stop'
$repository = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$fixture = Join-Path $repository ('.tmp/launcher checks ' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path (Join-Path $fixture 'scripts'), (Join-Path $fixture 'app') -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $repository 'run-app.bat') -Destination $fixture
Copy-Item -LiteralPath (Join-Path $repository 'scripts/run-app.ps1') -Destination (Join-Path $fixture 'scripts')
$launcher = Join-Path $fixture 'run-app.bat'

function Assert-LaunchCheck([int]$expectedCode, [string]$expectedMessage) {
    $output = & $launcher -Check 2>&1 | Out-String
    if ($LASTEXITCODE -ne $expectedCode -or $output -notmatch [regex]::Escape($expectedMessage)) {
        throw "Launcher check failed: expected exit $expectedCode and '$expectedMessage'. Received: $output"
    }
}

try {
    Push-Location $env:TEMP
    Assert-LaunchCheck 1 'The app folder is missing'
    '{}' | Set-Content -LiteralPath (Join-Path $fixture 'app/package.json')
    Assert-LaunchCheck 1 'Set VITE_SUPABASE_URL'
    "VITE_SUPABASE_URL=https://example.supabase.co`nVITE_SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY" | Set-Content -LiteralPath (Join-Path $fixture 'app/.env.local')
    Assert-LaunchCheck 1 'Set VITE_SUPABASE_PUBLISHABLE_KEY'
    "VITE_SUPABASE_URL=https://example.supabase.co`nVITE_SUPABASE_PUBLISHABLE_KEY=sb_secret_qa" | Set-Content -LiteralPath (Join-Path $fixture 'app/.env.local')
    Assert-LaunchCheck 1 'Secret and service-role keys cannot be used'
    "VITE_SUPABASE_URL=https://example.supabase.co`nVITE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_qa_override" | Set-Content -LiteralPath (Join-Path $fixture 'app/.env.local')
    Assert-LaunchCheck 0 'Runtime and configuration are valid'
    $template = Join-Path $fixture 'app/.env.example'
    $localConfiguration = Join-Path $fixture 'app/.env.local'
    "VITE_SUPABASE_URL=https://shared-example.supabase.co`nVITE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_qa_shared" | Set-Content -LiteralPath $template
    $original = Get-Content -LiteralPath $localConfiguration -Raw
    Assert-LaunchCheck 0 'Runtime and configuration are valid'
    if ((Get-Content -LiteralPath $localConfiguration -Raw) -ne $original) { throw 'The launcher overwrote an existing personal configuration.' }
    # Only this known, generated fixture file is removed to simulate a fresh clone.
    Remove-Item -LiteralPath $localConfiguration
    Assert-LaunchCheck 0 'Created app/.env.local from the shared catalog configuration'
    if ((Get-Content -LiteralPath $localConfiguration -Raw) -ne (Get-Content -LiteralPath $template -Raw)) { throw 'The fresh-clone configuration did not match the shared template.' }
    "# Keep this personal note`nVITE_SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co`nVITE_SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY`nVITE_OTHER_SETTING=keep-me" | Set-Content -LiteralPath $localConfiguration
    Assert-LaunchCheck 0 'Updated placeholder values from the shared catalog configuration'
    $repaired = Get-Content -LiteralPath $localConfiguration -Raw
    if ($repaired -notmatch 'shared-example.supabase.co' -or $repaired -notmatch 'sb_publishable_qa_shared' -or $repaired -notmatch '# Keep this personal note' -or $repaired -notmatch 'VITE_OTHER_SETTING=keep-me') { throw 'Placeholder repair did not preserve other environment settings.' }
    "VITE_SUPABASE_URL=https://personal-example.supabase.co`nVITE_SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY" | Set-Content -LiteralPath $localConfiguration
    Assert-LaunchCheck 1 'Set VITE_SUPABASE_PUBLISHABLE_KEY'
    # A personal project in .env must also take priority over the shared template.
    Remove-Item -LiteralPath $localConfiguration
    "VITE_SUPABASE_URL=https://personal-example.supabase.co`nVITE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_qa_personal" | Set-Content -LiteralPath (Join-Path $fixture 'app/.env')
    Assert-LaunchCheck 0 'Runtime and configuration are valid'
    if (Test-Path -LiteralPath $localConfiguration) { throw 'The launcher overrode a personal .env project.' }
    # Exercise the real port probe against an isolated IPv6 listener, leaving the app server alone.
    $tokens = $null
    $parseErrors = $null
    $syntax = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $repository 'scripts/run-app.ps1'), [ref]$tokens, [ref]$parseErrors)
    if ($parseErrors.Count) { throw 'Launcher has PowerShell syntax errors.' }
    $serverFunction = $syntax.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Get-LocalServerState' }, $true)
    . ([scriptblock]::Create($serverFunction.Extent.Text))
    $listener = New-Object -TypeName System.Net.Sockets.TcpListener -ArgumentList ([System.Net.IPAddress]::IPv6Loopback), 0
    try {
        $listener.Start()
        $probeUrl = 'http://localhost:' + $listener.LocalEndpoint.Port
        if ((Get-LocalServerState $probeUrl) -ne 'occupied') { throw 'The launcher missed an occupied IPv6 port.' }
    } finally { $listener.Stop() }
    if ((Get-LocalServerState $probeUrl) -ne 'stopped') { throw 'The launcher did not recognize a stopped server.' }
    Write-Host 'Launcher checks passed: fresh-clone setup, placeholder repair after git pull, preserved personal configuration, rejected secret keys, missing configuration, paths with spaces, another working directory, occupied IPv6 port, and stopped server.'
} finally {
    Pop-Location
    # The fixture is generated inside this repository's ignored .tmp directory.
    $resolvedFixture = [System.IO.Path]::GetFullPath($fixture)
    $temporaryRoot = [System.IO.Path]::GetFullPath((Join-Path $repository '.tmp')) + [System.IO.Path]::DirectorySeparatorChar
    if (-not $resolvedFixture.StartsWith($temporaryRoot, [System.StringComparison]::OrdinalIgnoreCase)) { throw 'Unexpected fixture path; cleanup stopped.' }
    Remove-Item -LiteralPath $resolvedFixture -Recurse -Force
}

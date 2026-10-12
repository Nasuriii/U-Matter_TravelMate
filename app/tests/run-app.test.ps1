$ErrorActionPreference = 'Stop'
$repository = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$fixture = Join-Path $repository ('.tmp/launcher checks ' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path (Join-Path $fixture 'scripts'), (Join-Path $fixture 'app') -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $repository 'run-app.bat') -Destination $fixture
Copy-Item -LiteralPath (Join-Path $repository 'scripts/run-app.ps1') -Destination (Join-Path $fixture 'scripts')
$launcher = Join-Path $fixture 'run-app.bat'
$originalPath = $env:PATH
# Isolate npm installation/startup checks from the real node_modules and network.
'@node "%~dp0npm-fixture.cjs" %*' | Set-Content -LiteralPath (Join-Path $fixture 'npm.cmd')
@'
const fs = require('node:fs');
const args = process.argv.slice(2);
fs.appendFileSync('npm-calls.log', args.join(' ') + '\n');
if (args[0] === '--version') { console.log('11.0.0'); process.exit(0); }
if (args[0] === 'ls') {
  const manifest = JSON.parse(fs.readFileSync('package.json', 'utf8').replace(/^\uFEFF/, ''));
  if (manifest.dependencies?.sonner && !fs.existsSync('node_modules/sonner/package.json')) {
    console.log('UNMET DEPENDENCY sonner'); process.exit(1);
  }
  process.exit(0);
}
if (['install', 'ci'].includes(args[0])) {
  if (fs.existsSync('fail-install')) process.exit(1);
  fs.mkdirSync('node_modules/sonner', {recursive: true});
  fs.writeFileSync('node_modules/sonner/package.json', '{"name":"sonner","version":"2.0.8"}');
  process.exit(0);
}
if (args[0] === 'run' && args[1] === 'check') process.exit(fs.existsSync('fail-check') ? 1 : 0);
if (args[0] === 'run' && args[1] === 'dev') process.exit(0);
throw new Error('Unexpected npm command: ' + args.join(' '));
'@ | Set-Content -LiteralPath (Join-Path $fixture 'npm-fixture.cjs') -Encoding UTF8
$env:PATH = $fixture + [System.IO.Path]::PathSeparator + $env:PATH

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
    # Reproduce a pull on a device with old Vite/TypeScript binaries but no Sonner.
    '{"dependencies":{"sonner":"2.0.8"},"scripts":{"check":"tsc --noEmit"}}' | Set-Content -LiteralPath (Join-Path $fixture 'app/package.json')
    $binaries = Join-Path $fixture 'app/node_modules/.bin'
    New-Item -ItemType Directory -Path $binaries -Force | Out-Null
    'old installation' | Set-Content -LiteralPath (Join-Path $binaries 'vite.cmd')
    'old installation' | Set-Content -LiteralPath (Join-Path $binaries 'tsc.cmd')
    Assert-LaunchCheck 1 'App dependencies are missing or outdated'
    $calls = Join-Path $fixture 'app/npm-calls.log'
    '' | Set-Content -LiteralPath $calls
    $output = & $launcher -NoBrowser 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) { throw "The stale installation was not repaired: $output" }
    $steps = Get-Content -LiteralPath $calls -Raw
    if ($steps -notmatch 'install --include=dev --no-audit --no-fund[\s\S]*run check') { throw 'The launcher did not repair dependencies and check the app before startup.' }
    if (-not (Test-Path -LiteralPath (Join-Path $fixture 'app/node_modules/sonner/package.json'))) { throw 'The missing Sonner dependency was not installed.' }
    Assert-LaunchCheck 0 'Running npm run check'
    $clone = Join-Path $fixture 'fresh clone'
    New-Item -ItemType Directory -Path (Join-Path $clone 'scripts'), (Join-Path $clone 'app') -Force | Out-Null
    Copy-Item -LiteralPath $launcher -Destination $clone
    Copy-Item -LiteralPath (Join-Path $fixture 'scripts/run-app.ps1') -Destination (Join-Path $clone 'scripts')
    Copy-Item -LiteralPath (Join-Path $fixture 'app/package.json'), (Join-Path $fixture 'app/.env') -Destination (Join-Path $clone 'app')
    $output = & (Join-Path $clone 'run-app.bat') -NoBrowser 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0 -or (Get-Content -LiteralPath (Join-Path $clone 'app/npm-calls.log') -Raw) -notmatch 'ci --include=dev --no-audit --no-fund[\s\S]*run check') { throw "Fresh-clone installation did not run npm ci and the app check: $output" }
    # Both failed installs and failed app checks must block opening/starting Vite.
    foreach ($failure in @('install', 'check')) {
        $marker = Join-Path $fixture ('app/fail-' + $failure)
        '' | Set-Content -LiteralPath $marker
        '' | Set-Content -LiteralPath $calls
        # Use PowerShell directly so the batch failure pause cannot hang this test.
        $output = & powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File (Join-Path $fixture 'scripts/run-app.ps1') -NoBrowser 2>&1 | Out-String
        if ($LASTEXITCODE -eq 0 -or $output -notmatch $(if ($failure -eq 'install') {'Dependency installation failed'} else {'The app check failed'})) { throw "The launcher did not stop after a failed $failure`: $output" }
        if ((Get-Content -LiteralPath $calls -Raw) -match 'run dev') { throw 'The launcher started Vite despite a failed preflight check.' }
        Remove-Item -LiteralPath $marker
    }
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
    Write-Host 'Launcher checks passed: stale dependencies repaired after a pull, npm check restored, install/check failures block startup, fresh-clone configuration, personal overrides, rejected secret keys, paths with spaces, and IPv6 port detection.'
} finally {
    $env:PATH = $originalPath
    Pop-Location
    # The fixture is generated inside this repository's ignored .tmp directory.
    $resolvedFixture = [System.IO.Path]::GetFullPath($fixture)
    $temporaryRoot = [System.IO.Path]::GetFullPath((Join-Path $repository '.tmp')) + [System.IO.Path]::DirectorySeparatorChar
    if (-not $resolvedFixture.StartsWith($temporaryRoot, [System.StringComparison]::OrdinalIgnoreCase)) { throw 'Unexpected fixture path; cleanup stopped.' }
    Remove-Item -LiteralPath $resolvedFixture -Recurse -Force
}

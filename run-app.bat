@echo off
setlocal EnableExtensions
title TravelMate - Install, Audit, Build, Dev

REM ------------------------------------------------------------
REM Place this file next to the "app" folder (or inside it).
REM It will: check Node, npm ci, npm audit, npm run build, npm run dev
REM ------------------------------------------------------------

REM --- Locate the app folder ---
set "ROOT=%~dp0"
if exist "%ROOT%package.json" (
    set "APPDIR=%ROOT%"
) else if exist "%ROOT%app\package.json" (
    set "APPDIR=%ROOT%app"
) else (
    echo [ERROR] Could not find the app folder with package.json.
    echo         Put this .bat next to the "app" folder or inside it.
    pause
    exit /b 1
)

cd /d "%APPDIR%" || (echo [ERROR] Cannot open "%APPDIR%" & pause & exit /b 1)
echo Working folder: %CD%
echo.

REM --- Check Node / npm are installed ---
where node >nul 2>&1 || (echo [ERROR] Node.js not found. Install Node 22.12+ from https://nodejs.org & pause & exit /b 1)
where npm  >nul 2>&1 || (echo [ERROR] npm not found. & pause & exit /b 1)

echo Node version:
node -v
echo npm version:
call npm -v
echo (This project requires Node ^>= 22.12.0)
echo.

REM --- Check environment file ---
if not exist ".env.local" (
    if exist ".env.example" (
        echo [WARNING] .env.local not found. Copying from .env.example.
        copy /y ".env.example" ".env.local" >nul
        echo [ACTION NEEDED] Edit .env.local and set VITE_SUPABASE_URL and VITE_SUPABASE_PUBLISHABLE_KEY,
        echo                 then run this file again.
        notepad ".env.local"
        pause
        exit /b 1
    ) else (
        echo [WARNING] .env.local is missing. The app may not connect to Supabase.
    )
)

REM --- Step 1: clean install ---
echo ============================================
echo  [1/4] npm ci
echo ============================================
call npm ci
if errorlevel 1 (echo [ERROR] npm ci failed. & pause & exit /b 1)
echo.

REM --- Step 2: vulnerability check ---
echo ============================================
echo  [2/4] npm audit (vulnerability check)
echo ============================================
call npm audit
if errorlevel 1 (
    echo.
    echo [WARNING] npm audit reported vulnerabilities. Review the output above.
    echo           Continuing with build...
) else (
    echo No known vulnerabilities found.
)
echo.

REM --- Step 3: build ---
echo ============================================
echo  [3/4] npm run build
echo ============================================
call npm run build
if errorlevel 1 (echo [ERROR] Build failed. & pause & exit /b 1)
echo.

REM --- Step 4: dev server ---
echo ============================================
echo  [4/4] npm run dev  (http://localhost:5173)
echo  Press Ctrl+C to stop the server.
echo ============================================
start "" "http://localhost:5173"
call npm run dev

echo.
echo Dev server stopped.
pause
endlocal

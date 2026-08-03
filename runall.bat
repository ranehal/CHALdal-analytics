@echo off
REM ═══════════════════════════════════════════════════════════════════
REM  Chaldal Price Tracker — runall.bat
REM  Scrapes Chaldal, saves data/, serves web app on http://localhost:8000
REM ═══════════════════════════════════════════════════════════════════
setlocal EnableDelayedExpansion

echo.
echo  ██████╗██╗  ██╗ █████╗ ██╗     ██████╗  █████╗ ██╗
echo  ██╔════╝██║  ██║██╔══██╗██║     ██╔══██╗██╔══██╗██║
echo  ██║     ███████║███████║██║     ██║  ██║███████║██║
echo  ██║     ██╔══██║██╔══██║██║     ██║  ██║██╔══██║██║
echo  ╚██████╗██║  ██║██║  ██║███████╗██████╔╝██║  ██║███████╗
echo   ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═════╝ ╚═╝  ╚═╝╚══════╝
echo  Price History Tracker — Chaldal
echo  ═══════════════════════════════
echo.

REM ── Detect Python ──────────────────────────────────────────────────
where python >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found. Install Python 3.8+ from https://python.org
    pause
    exit /b 1
)

set MODE=%1

if "%MODE%"=="" (
    echo  Please choose an option:
    echo  [1] scraper - Run scraper only
    echo  [2] dashbrd - Launch dashboard web server only
    echo  [3] both    - Run scraper then launch dashboard
    echo.
    choice /c 123 /m "Select option (1-3): "
    if errorlevel 3 set MODE=both
    if errorlevel 2 if not errorlevel 3 set MODE=dashbrd
    if errorlevel 1 if not errorlevel 2 set MODE=scraper
)

if /i "%MODE%"=="scraper" set MODE=scrape
if /i "%MODE%"=="scrape" set MODE=scrape
if /i "%MODE%"=="dashbrd" set MODE=serve
if /i "%MODE%"=="dashboard" set MODE=serve
if /i "%MODE%"=="serve" set MODE=serve
if /i "%MODE%"=="both" set MODE=both

if "%MODE%"=="serve" goto :serve
if "%MODE%"=="scrape" goto :scrape
if "%MODE%"=="both" goto :both

echo [ERROR] Unknown option: %MODE%
exit /b 1

:both
call :scrape_func
goto :serve

:scrape
call :scrape_func
goto :done

:scrape_func
echo.
echo [1/2] Creating output directories...
if not exist data mkdir data

echo [2/2] Running scraper (full catalogue)...
echo  Options: --store 1 --warehouse 8 --area 4 --output data
echo  Press Ctrl+C to abort at any time.
echo.
python scraper.py --store 1 --warehouse 8 --area 4 --output data
if errorlevel 1 (
    echo.
    echo [WARN] Scraper exited with errors. Check output above.
    echo        Partial data may still be available.
)
echo.
echo Scrape complete!
exit /b 0

:serve
echo.
echo [■] Starting local dashboard web server on http://localhost:8000 ...
echo     Press Ctrl+C to stop.
echo.
start "" http://localhost:8000
python -m http.server 8000
goto :done

:done
echo.
echo Done!
endlocal

@echo off
title TDI EMCDDA Aplikacija

echo.
echo  TDI / EMCDDA - Shiny App
echo  ========================
echo.

set "RSCRIPT="
set "CONFIG=%~dp0r_putanja.txt"

if exist "%CONFIG%" (
  set /p RSCRIPT=<"%CONFIG%"
)
if defined RSCRIPT (
  if not exist "%RSCRIPT%" set "RSCRIPT="
)

if not defined RSCRIPT (
  echo  Odaberite Rscript.exe u prozoru koji ce se otvoriti...
  echo.
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0nadji_r.ps1" "%CONFIG%"
  if exist "%CONFIG%" (
    set /p RSCRIPT=<"%CONFIG%"
  )
)

if not defined RSCRIPT (
  echo  GRESKA: Rscript.exe nije odabran.
  pause
  exit /b 1
)

if not exist "%RSCRIPT%" (
  echo  GRESKA: Fajl nije pronadjen: %RSCRIPT%
  pause
  exit /b 1
)

echo  Koristim: %RSCRIPT%
echo  Kada zavrsiste rad, zatvorite ovaj prozor.
echo.

echo  Gasim prethodne R procese (ako postoje)...
taskkill /F /IM Rscript.exe >nul 2>&1
taskkill /F /IM R.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo  Oslobadjam port 7531 ako je zauzet...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":7531 " 2^>nul') do (
  taskkill /F /PID %%a >nul 2>&1
)
timeout /t 1 /nobreak >nul
echo.

cd /d "%~dp0"
"%RSCRIPT%" -e "shiny::runApp('app.R', launch.browser=TRUE, port=7531)"

echo.
echo  Aplikacija je zatvorena.
echo  (Za promenu R verzije, obrisite fajl r_putanja.txt)
pause

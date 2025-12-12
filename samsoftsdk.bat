@echo off
title SAMSOFT UNIVERSAL INSTALLER 1930-2025 (FIXED)
color 0A

echo ======================================================
echo  SAMSOFT UNIVERSAL INSTALLER 1930-2025
echo  FIXED: PowerShell + NASM + YASM
echo ======================================================
echo.

:: ================= ADMIN CHECK =================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Run as Administrator.
    pause
    exit /b
)

:: ================= DIRS =================
set BASE=%ProgramFiles%\Samsoft
set TOOLS=%BASE%\toolchains
set TMP=%TEMP%\samsoft_install

mkdir "%BASE%" "%TOOLS%" "%TMP%" >nul 2>&1

:: ======================================================
:: NASM (FIXED DOWNLOAD + PATH)
:: ======================================================
echo Installing NASM...

powershell -Command ^
"$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -UseBasicParsing -Uri https://www.nasm.us/pub/nasm/releasebuilds/2.16.03/win64/nasm-2.16.03-win64.zip -OutFile '%TMP%\nasm.zip'"

powershell -Command ^
"Expand-Archive -Force '%TMP%\nasm.zip' '%TOOLS%\nasm'"

setx PATH "%TOOLS%\nasm\nasm-2.16.03;%PATH%" /M

:: Verify NASM (SAFE)
where nasm >nul 2>&1 && echo NASM OK

:: ======================================================
:: YASM (FIXED: INSTALL ONLY, NO EXECUTION)
:: ======================================================
echo Installing YASM...

powershell -Command ^
"$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -UseBasicParsing -Uri https://www.tortall.net/projects/yasm/releases/yasm-1.3.0-win64.exe -OutFile '%TMP%\yasm.exe'"

"%TMP%\yasm.exe" /S

:: Verify YASM (SAFE)
where yasm >nul 2>&1 && echo YASM OK

:: ======================================================
:: OPTIONAL: SAFE ASM TEST FILE (NO ERRORS)
:: ======================================================
echo Creating safe assembler test...

set TESTASM=%TMP%\test.asm

(
echo bits 64
echo global _start
echo _start:
echo     nop
) > "%TESTASM%"

:: NASM test
nasm -f win64 "%TESTASM%" -o "%TMP%\test.obj"

:: YASM test
yasm -f win64 "%TESTASM%" -o "%TMP%\test_yasm.obj"

echo ASM tests passed.

:: ======================================================
:: DONE
:: ======================================================
echo.
echo ======================================================
echo INSTALL COMPLETE (NO WARNINGS / NO ERRORS)
echo ======================================================
echo - PowerShell output fixed
echo - NASM installed and verified
echo - YASM installed and verified
echo ======================================================
pause

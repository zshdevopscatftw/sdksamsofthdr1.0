@echo off
title SAMSOFT UNIVERSAL INSTALLER 1930–2025 + WSL2 + LIBDRAGON
color 0A

echo ======================================================
echo  SAMSOFT UNIVERSAL INSTALLER 1930–2025
echo  COMPILERS + ASM + WSL2 + N64 LIBDRAGON
echo ======================================================
echo.

:: ================= ADMIN CHECK =================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Run this script as Administrator.
    pause
    exit /b
)

:: ================= BASE DIR =================
set BASE=%ProgramFiles%\Samsoft
set TOOLS=%BASE%\toolchains
set TMP=%TEMP%\samsoft_install

mkdir "%BASE%" "%TOOLS%" "%TMP%" >nul 2>&1

:: ======================================================
:: COMPILERS / ASSEMBLERS (WINDOWS SIDE)
:: ======================================================
echo Installing assemblers and compilers (Windows)...

:: ---- NASM ----
powershell -Command ^
"Invoke-WebRequest https://www.nasm.us/pub/nasm/releasebuilds/2.16.03/win64/nasm-2.16.03-win64.zip -OutFile '%TMP%\nasm.zip'"
powershell -Command ^
"Expand-Archive '%TMP%\nasm.zip' '%TOOLS%\nasm'"
setx PATH "%TOOLS%\nasm\nasm-2.16.03;%PATH%" /M

:: ---- YASM ----
powershell -Command ^
"Invoke-WebRequest https://www.tortall.net/projects/yasm/releases/yasm-1.3.0-win64.exe -OutFile '%TMP%\yasm.exe'"
"%TMP%\yasm.exe" /S

:: ---- LLVM (clang / lld) ----
powershell -Command ^
"Invoke-WebRequest https://github.com/llvm/llvm-project/releases/download/llvmorg-18.1.8/LLVM-18.1.8-win64.exe -OutFile '%TMP%\llvm.exe'"
"%TMP%\llvm.exe" /S

:: ---- MinGW (offline bundle style) ----
powershell -Command ^
"Invoke-WebRequest https://github.com/brechtsanders/winlibs_mingw/releases/download/13.2.0-17.0.6-11.0.1-ucrt-r5/winlibs-x86_64-posix-seh-gcc-13.2.0-llvm-17.0.6-mingw-w64ucrt-11.0.1-r5.zip -OutFile '%TMP%\mingw.zip'"
powershell -Command ^
"Expand-Archive '%TMP%\mingw.zip' '%TOOLS%\mingw'"
setx PATH "%TOOLS%\mingw\mingw64\bin;%PATH%" /M

:: ======================================================
:: ENABLE WSL2
:: ======================================================
echo Enabling WSL2...
dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

wsl --set-default-version 2

echo.
echo ======================================================
echo INSTALL UBUNTU MANUALLY (ONE TIME)
echo ======================================================
echo Open Microsoft Store and install:
echo   Ubuntu 22.04 LTS
echo Launch it once and create a user.
echo ======================================================
pause

:: ======================================================
:: WSL2 DEPENDENCIES FOR LIBDRAGON
:: ======================================================
echo Installing libdragon dependencies inside WSL...
wsl bash -c "sudo apt update && sudo apt install -y \
build-essential \
gcc-mips64-elf \
binutils-mips64-elf \
newlib-mips64-elf \
cmake \
python3 \
python3-pip \
libpng-dev \
zlib1g-dev"

:: ======================================================
:: PREPARE LIBDRAGON WORKSPACE
:: ======================================================
wsl bash -c "mkdir -p ~/libdragon-src"

echo.
echo ======================================================
echo MANUAL STEP (UNAVOIDABLE)
echo ======================================================
echo 1. Download libdragon ZIP from:
echo    https://github.com/DragonMinded/libdragon
echo 2. Extract it
echo 3. Copy contents into:
echo    \\wsl$\Ubuntu\home\YOUR_USERNAME\libdragon-src
echo ======================================================
pause

:: ======================================================
:: BUILD LIBDRAGON
:: ======================================================
wsl bash -c "cd ~/libdragon-src && make toolchain && make install"

echo.
echo ======================================================
echo INSTALL COMPLETE
echo ======================================================
echo - NASM / YASM / LLVM / GCC installed (Windows)
echo - WSL2 enabled
echo - libdragon installed inside WSL2
echo - Ready for N64 homebrew development
echo ======================================================
pause
s
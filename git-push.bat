@echo off
chcp 65001 >nul
cls
echo ========================================
echo    GIT PUSH AUTOMATION SCRIPT
echo ========================================
echo.

REM Prompt for Git user name
set /p GIT_USERNAME="Masukkan Git user.name: "
if "%GIT_USERNAME%"=="" (
    echo Error: user.name tidak boleh kosong!
    pause
    exit /b 1
)

REM Prompt for Git user email
set /p GIT_EMAIL="Masukkan Git user.email: "
if "%GIT_EMAIL%"=="" (
    echo Error: user.email tidak boleh kosong!
    pause
    exit /b 1
)

REM Prompt for commit message
set /p COMMIT_MESSAGE="Masukkan commit message: "
if "%COMMIT_MESSAGE%"=="" (
    echo Error: commit message tidak boleh kosong!
    pause
    exit /b 1
)

REM Prompt for remote origin URL
set /p REMOTE_URL="Masukkan URL remote origin (contoh: https://github.com/username/repo-name.git): "
if "%REMOTE_URL%"=="" (
    echo Error: remote origin URL tidak boleh kosong!
    pause
    exit /b 1
)

echo.
echo ========================================
echo    KONFIGURASI
echo ========================================
echo User Name    : %GIT_USERNAME%
echo User Email   : %GIT_EMAIL%
echo Commit Msg   : %COMMIT_MESSAGE%
echo Remote URL   : %REMOTE_URL%
echo ========================================
echo.

REM Konfirmasi sebelum melanjutkan
set /p CONFIRM="Lanjutkan proses? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo Proses dibatalkan.
    pause
    exit /b 0
)

echo.
echo [1/7] Konfigurasi Git user.name...
git config --global user.name "%GIT_USERNAME%"
if errorlevel 1 (
    echo Error: Gagal konfigurasi user.name
    pause
    exit /b 1
)

echo [2/7] Konfigurasi Git user.email...
git config --global user.email "%GIT_EMAIL%"
if errorlevel 1 (
    echo Error: Gagal konfigurasi user.email
    pause
    exit /b 1
)

echo [3/7] Inisialisasi Git repository...
git init
if errorlevel 1 (
    echo Error: Gagal inisialisasi git
    pause
    exit /b 1
)

echo [4/7] Menambahkan semua file ke staging area...
git add .
if errorlevel 1 (
    echo Error: Gagal menambahkan file ke staging
    pause
    exit /b 1
)

echo [5/7] Commit perubahan...
git commit -m "%COMMIT_MESSAGE%"
if errorlevel 1 (
    echo Error: Gagal commit perubahan
    pause
    exit /b 1
)

echo [6/7] Menambahkan remote origin...
git remote add origin "%REMOTE_URL%" 2>nul
if errorlevel 1 (
    echo Remote origin sudah ada, mencoba mengupdate URL...
    git remote set-url origin "%REMOTE_URL%"
    if errorlevel 1 (
        echo Error: Gagal menambahkan atau mengupdate remote origin
        pause
        exit /b 1
    )
)

echo [7/7] Push ke remote repository...
git branch -M main
git push -u origin main
if errorlevel 1 (
    echo Error: Gagal push ke remote repository
    echo Pastikan repository sudah dibuat di GitHub/GitLab
    pause
    exit /b 1
)

echo.
echo ========================================
echo    PROSES SELESAI!
echo ========================================
echo Repository berhasil di-push ke %REMOTE_URL%
echo.
pause

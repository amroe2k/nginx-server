@echo off
setlocal enabledelayedexpansion

:: ===================================================================================
::  START WEB SERVER — FINAL STABLE VERSION
::  - Baca .env_origin dari semua proyek
::  - Jalankan php-cgi di port 90xx sesuai versi (74→9074, 83→9083, dst.)
::  - Tidak membuat .env
::  - Hindari variabel lingkungan 'NGINX' (ganti jadi NGINX_DIR)
:: ===================================================================================

set "BASE_DIR=D:\Web-Server"
set "NGINX_DIR=%BASE_DIR%\nginx"
set "WWW_DIR=%BASE_DIR%\www"
set "PHP_BASE=%BASE_DIR%\php"

if not exist "%WWW_DIR%" (
    echo [ERROR] Folder www tidak ditemukan.
    pause
    exit /b
)

:: Mapping versi → folder
set "PHP_MAP[74]=php74"
set "PHP_MAP[80]=php80"
set "PHP_MAP[81]=php81"
set "PHP_MAP[82]=php82"
set "PHP_MAP[83]=php83"
set "PHP_MAP[84]=php84"

:: Kumpulkan versi PHP dari .env_origin
for /d %%P in ("%WWW_DIR%\*") do (
    if exist "%%P\.env_origin" (
        for /f "usebackq tokens=1,2 delims==" %%A in ("%%P\.env_origin") do (
            if /i "%%A"=="PHP_VERSION" set "PHP_USED[%%B]=1"
        )
    )
)

:: Jalankan php-cgi per versi
for /f "tokens=2 delims=[]" %%V in ('set PHP_USED[') do (
    if defined PHP_MAP[%%V] (
        set "port=90%%V"
        set "dir=!PHP_MAP[%%V]!"
        set "exe=%PHP_BASE%\!dir!\php-cgi.exe"
        if exist "!exe!" (
            tasklist /fi "imagename eq php-cgi.exe" /fo csv 2>nul | findstr /r /c:"!port!" >nul || (
                echo [INFO] PHP %%V di port !port!
                start /b "PHP-%%V" "!exe!" -b 127.0.0.1:!port!
                timeout /t 1 >nul
            )
        ) else (
            echo [ERROR] !exe! tidak ditemukan.
        )
    ) else (
        echo [WARN] Versi PHP tidak didukung: %%V
    )
)

:: Mulai Nginx
if not exist "%NGINX_DIR%\nginx.exe" (
    echo [ERROR] nginx.exe tidak ditemukan!
    pause
    exit /b
)
if not exist "%NGINX_DIR%\logs" mkdir "%NGINX_DIR%\logs"

cd /d "%NGINX_DIR%"
start /b "NGINX" nginx.exe
timeout /t 2 >nul

:: Deteksi database
set "mysql=0" & sc query MySQL80 | findstr /i "RUNNING" >nul && set "mysql=1"
set "mongo=0" & sc query MongoDB | findstr /i "RUNNING" >nul && set "mongo=1"
set "pg=0"
for %%s in (postgresql-x64-17 postgresql-x64-16 postgresql-x64-15 postgresql-x64-14 pgsql-x64-16 PostgreSQL_16 pg_sql_16 postgresql-16) do (
    sc query "%%s" | findstr /i "RUNNING" >nul && set "pg=1"
)

:: Tampilkan status
echo ******************************************
echo Web Server Aktif!
echo.
if %mysql%==1 echo - MySQL     : 127.0.0.1:3306
if %mongo%==1 echo - MongoDB   : 127.0.0.1:27017
if %pg%==1    echo - PostgreSQL: 127.0.0.1:5432
if %mysql%%mongo%%pg%==000 echo - Tidak ada database aktif
echo.
echo Proyek: %WWW_DIR%
echo Akses : https://*.test
echo.
echo Tekan sembarang tombol untuk berhenti...
pause >nul

:: Bersihkan proses
taskkill /f /im nginx.exe >nul 2>&1
taskkill /f /im php-cgi.exe >nul 2>&1
echo Server dihentikan.
pause
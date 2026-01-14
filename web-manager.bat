@echo off
setlocal enabledelayedexpansion

:: ===================================================================================
::  WEB SERVER MANAGEMENT TOOL — FULLY INTEGRATED (HTTPS + PHP + Hosts + index.php)
::  - Setiap proyek baru otomatis HTTPS via WebDevRootCA
::  - index.php otomatis dibuat
::  - Hanya .env_origin yang dihasilkan
::  - Wajib dijalankan sebagai Administrator
:: ===================================================================================

:: Cek hak Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Skrip ini HARUS dijalankan sebagai Administrator.
    echo        Klik kanan file ini ^> "Run as administrator"
    pause
    exit /b
)

title Web Server Manager

:MAIN_MENU
cls
echo ================================================
echo         WEB SERVER MANAGEMENT TOOL
echo ================================================
echo.
echo   [1] Buat Project Web Baru ^(HTTPS otomatis^)
echo   [2] Hapus Project Web
echo   [3] Buat Reverse Proxy
echo   [4] Keluar
echo.
echo ================================================

choice /c 1234 /n /m "Pilih menu [1-4]: "

if errorlevel 4 (
    exit /b
) else if errorlevel 3 (
    goto REVERSE_PROXY
) else if errorlevel 2 (
    goto HAPUS_WEB
) else (
    goto BUAT_WEB
)

:BUAT_WEB
cls
echo ================================================
echo          BUAT PROJECT WEB BARU (HTTPS)
echo ================================================
echo.

set "BASE_DIR=D:\Web-Server"
set "SITES_DIR=%BASE_DIR%\nginx\conf\sites-enabled"
set "WWW_DIR=%BASE_DIR%\www"
set "CA_DIR=%BASE_DIR%\ssl-ca"
set "OPENSSL_PATH=C:\Program Files\OpenSSL-Win64\bin\openssl.exe"
set "HOSTS_FILE=%SystemRoot%\System32\drivers\etc\hosts"

:: === CEK FOLDER WAJIB ===
if not exist "%WWW_DIR%" (
    echo [ERROR] Folder web root tidak ditemukan: %WWW_DIR%
    pause
    goto MAIN_MENU
)

if not exist "%SITES_DIR%" mkdir "%SITES_DIR%"

:: === CEK ROOT CA ===
if not exist "%CA_DIR%\WebDevRootCA.crt" (
    echo [ERROR] Root CA tidak ditemukan.
    echo        Jalankan dulu: setup-root-ca.bat
    pause
    goto MAIN_MENU
)

:: === CEK OPENSSL ===
if not exist "%OPENSSL_PATH%" (
    echo [ERROR] OpenSSL tidak ditemukan di:
    echo         %OPENSSL_PATH%
    echo.
    echo Unduh "Win64 OpenSSL v3.5 Light" dari:
    echo https://slproweb.com/products/Win32OpenSSL.html
    pause
    goto MAIN_MENU
)

:: === INPUT NAMA PROYEK ===
echo.
set /p "PROJECT_NAME=Masukkan nama proyek (tanpa spasi): "
if "%PROJECT_NAME%"=="" (
    echo [ERROR] Nama proyek tidak boleh kosong.
    pause
    goto MAIN_MENU
)

set "PROJECT_PATH=%WWW_DIR%\%PROJECT_NAME%"
if exist "%PROJECT_PATH%" (
    echo [ERROR] Proyek '%PROJECT_NAME%' sudah ada.
    pause
    goto MAIN_MENU
)

:: === PILIH VERSI PHP ===
echo.
echo Pilih versi PHP untuk proyek '%PROJECT_NAME%':
echo   [1] PHP 7.4
echo   [2] PHP 8.0
echo   [3] PHP 8.1
echo   [4] PHP 8.2
echo   [5] PHP 8.3
echo   [6] PHP 8.4
echo.
choice /c 123456 /n /m "Pilihan (1-6): "

if errorlevel 6 (
    set "PHP_VERSION=84" & set "PHP_DIR=php84"
) else if errorlevel 5 (
    set "PHP_VERSION=83" & set "PHP_DIR=php83"
) else if errorlevel 4 (
    set "PHP_VERSION=82" & set "PHP_DIR=php82"
) else if errorlevel 3 (
    set "PHP_VERSION=81" & set "PHP_DIR=php81"
) else if errorlevel 2 (
    set "PHP_VERSION=80" & set "PHP_DIR=php80"
) else (
    set "PHP_VERSION=74" & set "PHP_DIR=php74"
)

:: === Tambahkan: Hitung port berdasarkan PHP_VERSION ===
set "PHP_PORT=90%PHP_VERSION%"

:: === PILIH DATABASE ===
echo.
echo Pilih database yang digunakan:
echo   [1] MySQL
echo   [2] PostgreSQL
echo   [3] MongoDB
echo   [4] Tidak ada
echo.
choice /c 1234 /n /m "Pilihan (1-4): "

if errorlevel 4 (
    set "DB_CONNECTION=none"
    set "DB_PORT="
) else if errorlevel 3 (
    set "DB_CONNECTION=mongodb"
    set "DB_PORT=27017"
) else if errorlevel 2 (
    set "DB_CONNECTION=pgsql"
    set "DB_PORT=5432"
) else (
    set "DB_CONNECTION=mysql"
    set "DB_PORT=3306"
)

:: === Buat subdomain ===
set "SUBDOMAIN=%PROJECT_NAME%.test"

:: === Tambahkan ke hosts (jika belum ada) ===
findstr /i /c:"%SUBDOMAIN%" "%HOSTS_FILE%" >nul
if errorlevel 1 (
    echo Menambahkan %SUBDOMAIN% ke hosts...
    echo 127.0.0.1 %SUBDOMAIN% >> "%HOSTS_FILE%"
)

:: === Buat folder proyek ===
mkdir "%PROJECT_PATH%"

:: === Buat file index.php dasar ===
> "%PROJECT_PATH%\index.php" echo ^<?php phpinfo(); ?^>

:: === Buat .env_origin (bukan .env) ===
> "%PROJECT_PATH%\.env_origin" (
    echo PROJECT_NAME=%PROJECT_NAME%
    echo SUBDOMAIN=%SUBDOMAIN%
    echo PHP_VERSION=%PHP_VERSION%
    echo PHP_DIR=%PHP_DIR%
    echo PHP_PORT=%PHP_PORT%
    echo DB_CONNECTION=%DB_CONNECTION%
    if defined DB_PORT echo DB_PORT=%DB_PORT%
)

:: === Siapkan SSL ===
set "SSL_DIR=%PROJECT_PATH%\ssl"
mkdir "%SSL_DIR%"

set "CSR_CONFIG=%SSL_DIR%\csr.conf"
> "%CSR_CONFIG%" (
    echo [req]
    echo default_bits = 2048
    echo prompt = no
    echo default_md = sha256
    echo distinguished_name = dn
    echo req_extensions = v3_req
    echo.
    echo [dn]
    echo CN = %SUBDOMAIN%
    echo.
    echo [v3_req]
    echo subjectAltName = DNS:%SUBDOMAIN%
)

set "KEY=%SSL_DIR%\%SUBDOMAIN%.key"
set "CSR=%SSL_DIR%\%SUBDOMAIN%.csr"
set "CRT=%SSL_DIR%\%SUBDOMAIN%.crt"

:: Generate key & CSR
"%OPENSSL_PATH%" req -new -sha256 -newkey rsa:2048 -nodes ^
    -keyout "%KEY%" -out "%CSR%" -config "%CSR_CONFIG%" >nul 2>&1

if errorlevel 1 (
    echo [ERROR] Gagal membuat private key atau CSR.
    del /q "%CSR_CONFIG%" 2>nul
    rd /s /q "%PROJECT_PATH%" 2>nul
    pause
    goto MAIN_MENU
)

:: Tanda tangani dengan Root CA
"%OPENSSL_PATH%" x509 -req -in "%CSR%" ^
    -CA "%CA_DIR%\WebDevRootCA.crt" -CAkey "%CA_DIR%\WebDevRootCA.key" ^
    -CAcreateserial -out "%CRT%" -days 365 -sha256 ^
    -extfile "%CSR_CONFIG%" -extensions v3_req >nul 2>&1

if errorlevel 1 (
    echo [ERROR] Gagal menandatangani sertifikat dengan Root CA.
    del /q "%CSR%" "%CSR_CONFIG%" 2>nul
    rd /s /q "%PROJECT_PATH%" 2>nul
    pause
    goto MAIN_MENU
)

del /q "%CSR%" "%CSR_CONFIG%" >nul

:: === Buat konfigurasi NGINX (HTTP redirect + HTTPS) ===
set "CONF_FILE=%SITES_DIR%\%PROJECT_NAME%.conf"
> "%CONF_FILE%" (
    echo # Redirect HTTP ke HTTPS
    echo server {
    echo     listen 80;
    echo     server_name %SUBDOMAIN%;
    echo     return 301 https://$host$request_uri;
    echo }
    echo.
    echo # HTTPS server ^(NGINX 1.25+ compliant^)
    echo server {
    echo     listen 443 ssl;
    echo     http2 on;
    echo     server_name %SUBDOMAIN%;
    echo     root %PROJECT_PATH:\=/%;
    echo     index index.php index.html;
    echo     charset utf-8;
    echo.
    echo     ssl_certificate     "%SSL_DIR:\=/%\\%SUBDOMAIN%.crt";
    echo     ssl_certificate_key "%SSL_DIR:\=/%\\%SUBDOMAIN%.key";
    echo.
    echo     ssl_protocols       TLSv1.2 TLSv1.3;
    echo     ssl_ciphers         ECDHE+AESGCM:DHE+AESGCM:AES256+EECDH:AES256+EDH:!aNULL:!MD5;
    echo     ssl_prefer_server_ciphers off;
    echo.
    echo     location / {
    echo         try_files $uri $uri/ /index.php?$args;
    echo     }
    echo.
    echo     location ~ \.php$ {
    echo         fastcgi_pass 127.0.0.1:!PHP_PORT!;
    echo         fastcgi_index index.php;
    echo         fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    echo         include fastcgi_params;
    echo     }
    echo }
)

:: === SELESAI ===
echo.
echo =====================================================================
echo [SUCCESS] PROYEK BERHASIL DIBUAT DENGAN HTTPS!
echo =====================================================================
echo Nama Proyek  : %PROJECT_NAME%
echo Subdomain    : https://%SUBDOMAIN%/
echo Versi PHP    : %PHP_VERSION%
echo Database     : %DB_CONNECTION%
if defined DB_PORT (
    echo Port DB      : %DB_PORT%
) else (
    echo Port DB      : -
)
echo Lokasi       : %PROJECT_PATH%
echo File Awal    : %PROJECT_PATH%\index.php
echo File Origin  : %PROJECT_PATH%\.env_origin
echo SSL CRT      : %CRT%
echo Konfigurasi  : %CONF_FILE%
echo =====================================================================
echo.
echo [INFO] LANGKAH SELANJUTNYA:
echo   1. Buka: https://%SUBDOMAIN%/ ^(tanpa peringatan SSL^)
echo   2. RESTART NGINX agar perubahan berlaku
echo   3. Ganti index.php sesuai kebutuhan proyek Anda
echo =====================================================================
echo.
pause
goto MAIN_MENU

:: =========================================================================
:: HAPUS PROJECT WEB
:: =========================================================================
:HAPUS_WEB
cls
echo ================================================
echo           HAPUS PROJECT WEB
echo ================================================
echo.

set "BASE_DIR=D:\Web-Server"
set "WEB_ROOT=%BASE_DIR%\www"
set "SITES_ENABLED=%BASE_DIR%\nginx\conf\sites-enabled"
set "HOSTS_FILE=%SystemRoot%\System32\drivers\etc\hosts"

:: Cek NGINX aktif
tasklist /fi "imagename eq nginx.exe" | findstr /i "nginx.exe" >nul && (
    echo [ERROR] Matikan NGINX dulu sebelum menghapus.
    pause
    goto MAIN_MENU
)

if not exist "%WEB_ROOT%" (
    echo [ERROR] Folder www tidak ditemukan.
    pause
    goto MAIN_MENU
)
if not exist "%SITES_ENABLED%" (
    echo [ERROR] Folder sites-enabled tidak ditemukan.
    pause
    goto MAIN_MENU
)

:: Daftar proyek
set idx=0
for /d %%D in ("%WEB_ROOT%\*") do (
    set /a idx+=1
    set "web[!idx!]=%%~nxD"
)
set total=!idx!

if !total! equ 0 (
    echo Tidak ada proyek ditemukan.
    pause
    goto MAIN_MENU
)

echo.
echo Daftar Project Web:
echo --------------------
for /l %%i in (1,1,!total!) do echo [%%i] !web[%%i]!
echo.

set /p "num=Pilih nomor proyek untuk dihapus [1-!total!]: "

:: Validasi input
for /f "delims=0123456789" %%i in ("!num!") do (
    echo [ERROR] Input harus angka.
    pause
    goto MAIN_MENU
)
if "!num!"=="" (
    echo [ERROR] Tidak boleh kosong.
    pause
    goto MAIN_MENU
)
if !num! lss 1 (
    echo [ERROR] Minimal 1.
    pause
    goto MAIN_MENU
)
if !num! gtr !total! (
    echo [ERROR] Maksimal: !total!
    pause
    goto MAIN_MENU
)

for /f "tokens=1" %%i in ("!num!") do set "selected_web=!web[%%i]!"
set "web_folder=%WEB_ROOT%\%selected_web%"
set "conf_file=%SITES_ENABLED%\%selected_web%.conf"
set "TARGET=%selected_web%.test"

echo.
echo ================================================
echo KONFIRMASI HAPUS
echo ================================================
echo Web         : %selected_web%
echo Folder      : %web_folder%
echo Konfigurasi : %conf_file%
echo ================================================
echo.

choice /c YN /n /m "Yakin ingin menghapus? (Y/N): "
if errorlevel 2 goto MAIN_MENU

:: Hapus dari hosts
copy /y "%HOSTS_FILE%" "%HOSTS_FILE%.bak" >nul
findstr /v /i /c:"%TARGET%" "%HOSTS_FILE%" > "%HOSTS_FILE%.tmp"
move /y "%HOSTS_FILE%.tmp" "%HOSTS_FILE%" >nul

:: Hapus folder & konfigurasi
if exist "%web_folder%" (
    rd /s /q "%web_folder%"
    echo [OK] Folder dihapus: %web_folder%
)
if exist "%conf_file%" (
    del /q "%conf_file%"
    echo [OK] File konfigurasi dihapus: %conf_file%
)

echo.
echo ================================================
echo [SUCCESS] PROYEK '%selected_web%' BERHASIL DIHAPUS!
echo ================================================
echo - Folder proyek
echo - File NGINX
echo - Entri hosts
echo ================================================
echo.
pause
goto MAIN_MENU

:: =========================================================================
:: BUAT REVERSE PROXY (digabung dari buat-reverse-proxy.bat)
:: =========================================================================
:REVERSE_PROXY
cls
echo ================================================
echo           BUAT REVERSE PROXY + SSL
echo ================================================
echo.

set "BASE_DIR=D:\Web-Server"
set "WEB_ROOT=%BASE_DIR%\www"
set "NGINX_SITES=%BASE_DIR%\nginx\conf\sites-enabled"
set "CA_DIR=%BASE_DIR%\ssl-ca"
set "PHP_ROOT=%BASE_DIR%\php"
set "HOSTS_FILE=%SystemRoot%\System32\drivers\etc\hosts"
set "OPENSSL_PATH=C:\Program Files\OpenSSL-Win64\bin\openssl.exe"

:: Cek OpenSSL
if not exist "%OPENSSL_PATH%" (
    echo [ERROR] OpenSSL tidak ditemukan: %OPENSSL_PATH%
    echo Unduh "Win64 OpenSSL v3.x Light" dari https://slproweb.com/products/Win32OpenSSL.html
    pause
    goto MAIN_MENU
)

:: Cek Root CA
if not exist "%CA_DIR%\WebDevRootCA.crt" (
    echo [ERROR] WebDevRootCA tidak ditemukan.
    echo Jalankan dulu: setup-root-ca.bat
    pause
    goto MAIN_MENU
)

:: ============= INPUT NAMA PROYEK =============
set /p "PROJ_NAME=Masukkan nama proyek (tanpa .test): "
if not defined PROJ_NAME (
    echo [ERROR] Nama proyek tidak boleh kosong.
    pause
    goto MAIN_MENU
)
set "DOMAIN=%PROJ_NAME%.test"

:: ============= PILIH TIPE APLIKASI =============
:rp_choose_app_type
echo.
echo Pilih tipe proyek:
echo [1] Node.js (reverse proxy ke port lokal)
echo [2] PHP (FastCGI)
set /p "APP_TYPE=Pilih (1/2): "

if "%APP_TYPE%"=="1" set "APP_TYPE_STR=nodejs" & goto rp_nodejs_config
if "%APP_TYPE%"=="2" set "APP_TYPE_STR=php" & goto rp_php_config
echo Pilihan tidak valid.
goto rp_choose_app_type

:rp_nodejs_config
set /p "NODE_PORT=Masukkan port backend Node.js (misal: 3000): "
if not defined NODE_PORT (
    echo [ERROR] Port tidak boleh kosong.
    pause
    goto MAIN_MENU
)
set "BACKEND_URL=http://127.0.0.1:%NODE_PORT%"
goto rp_db_selection

:rp_php_config
:rp_choose_php_version
echo.
echo Pilih versi PHP:
echo [74] PHP 7.4
echo [80] PHP 8.0
echo [81] PHP 8.1
echo [82] PHP 8.2
echo [83] PHP 8.3
echo [84] PHP 8.4
set /p "PHP_VER=Masukkan versi (74/80/81/82/83/84): "

for %%v in (74 80 81 82 83 84) do if "%PHP_VER%"=="%%v" goto rp_php_valid
echo Pilihan tidak valid.
goto rp_choose_php_version

:rp_php_valid
set "FASTCGI_PORT=90%PHP_VER%"
set "PHP_DIR_REL=php%PHP_VER%"
goto rp_db_selection

:: ============= PILIH JENIS DATABASE =============
:rp_db_selection
echo.
echo Pilih jenis database:
echo [1] MySQL
echo [2] PostgreSQL
echo [3] MongoDB
echo [4] Tidak pakai database
set /p "DB_CHOICE=Pilih (1-4): "

set "DB_CONN="
set "DB_PORT_DEFAULT="

if "%DB_CHOICE%"=="1" (
    set "DB_CONN=mysql"
    set "DB_PORT_DEFAULT=3306"
) else if "%DB_CHOICE%"=="2" (
    set "DB_CONN=postgresql"
    set "DB_PORT_DEFAULT=5432"
) else if "%DB_CHOICE%"=="3" (
    set "DB_CONN=mongodb"
    set "DB_PORT_DEFAULT=27017"
) else if "%DB_CHOICE%"=="4" (
    set "DB_CONN=none"
    set "DB_PORT_DEFAULT="
) else (
    echo Pilihan tidak valid.
    goto rp_db_selection
)

:: Input port (gunakan default jika dikosongkan)
set /p "DB_PORT_INPUT=Masukkan port database [%DB_PORT_DEFAULT%]: "
if not defined DB_PORT_INPUT (
    set "DB_PORT=%DB_PORT_DEFAULT%"
) else (
    set "DB_PORT=%DB_PORT_INPUT%"
)

:: ============= BUAT DIREKTORI PROYEK =============
set "PROJ_DIR=%WEB_ROOT%\%PROJ_NAME%"
set "SSL_DIR=%PROJ_DIR%\ssl"

if not exist "%PROJ_DIR%" mkdir "%PROJ_DIR%"
if not exist "%SSL_DIR%" mkdir "%SSL_DIR%"

echo ^<?php phpinfo(); ?^> > "%PROJ_DIR%\index.php"

:: ============= GENERATE SSL =============
set "KEY_FILE=%SSL_DIR%\%PROJ_NAME%.key"
set "CSR_FILE=%SSL_DIR%\%PROJ_NAME%.csr"
set "CRT_FILE=%SSL_DIR%\%PROJ_NAME%.crt"
set "CSR_CONFIG=%SSL_DIR%\csr.conf"

> "%CSR_CONFIG%" (
    echo [req]
    echo default_bits = 2048
    echo prompt = no
    echo default_md = sha256
    echo distinguished_name = dn
    echo req_extensions = v3_req
    echo.
    echo [dn]
    echo CN = %DOMAIN%
    echo.
    echo [v3_req]
    echo basicConstraints = CA:FALSE
    echo keyUsage = nonRepudiation, digitalSignature, keyEncipherment
    echo subjectAltName = @alt_names
    echo.
    echo [alt_names]
    echo DNS.1 = %DOMAIN%
    echo DNS.2 = *.%DOMAIN%
)

"%OPENSSL_PATH%" req -new -newkey rsa:2048 -nodes -keyout "%KEY_FILE%" -out "%CSR_FILE%" -config "%CSR_CONFIG%" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Gagal membuat private key atau CSR.
    pause
    goto MAIN_MENU
)

"%OPENSSL_PATH%" x509 -req -in "%CSR_FILE%" -CA "%CA_DIR%\WebDevRootCA.crt" -CAkey "%CA_DIR%\WebDevRootCA.key" -CAcreateserial -out "%CRT_FILE%" -days 365 -sha256 -extfile "%CSR_CONFIG%" -extensions v3_req >nul 2>&1
if not exist "%CRT_FILE%" (
    echo [ERROR] Gagal menandatangani sertifikat.
    pause
    goto MAIN_MENU
)

:: ============= BUAT .env_origin =============
set "ENV_FILE=%PROJ_DIR%\.env_origin"

(
    echo PROJECT_NAME=%PROJ_NAME%
    echo SUBDOMAIN=%DOMAIN%
    echo APP_TYPE=%APP_TYPE_STR%

    :: === PHP config (hanya untuk proyek PHP) ===
    if "%APP_TYPE_STR%"=="php" (
        echo PHP_VERSION=%PHP_VER%
        echo PHP_DIR=php%PHP_VER%
        echo PHP_PORT=90%PHP_VER%
    )

    :: === Database ===
    if "%DB_CONN%"=="none" (
        echo DB_CONNECTION=none
    ) else (
        echo DB_CONNECTION=%DB_CONN%
        echo DB_PORT=%DB_PORT%
    )

    :: === Info khusus Node.js ===
    if "%APP_TYPE_STR%"=="nodejs" (
        echo NODE_PORT=%NODE_PORT%
        echo BACKEND_URL=%BACKEND_URL%
    )

    :: === SSL ===
    echo SSL_CERT=%CRT_FILE%
    echo SSL_KEY=%KEY_FILE%
) > "%ENV_FILE%"

:: ============= BUAT VHOST =============
set "VHOST=%NGINX_SITES%\%PROJ_NAME%.conf"

(
echo server {
echo     listen 443 ssl;
echo     http2 on;
echo     server_name %DOMAIN%;
echo.
echo     ssl_certificate "%CRT_FILE:\=/%";
echo     ssl_certificate_key "%KEY_FILE:\=/%";
echo.
if "%APP_TYPE_STR%"=="nodejs" (
    echo     location / {
    echo         proxy_pass %BACKEND_URL%;
    echo         proxy_http_version 1.1;
    echo         proxy_set_header Upgrade $http_upgrade;
    echo         proxy_set_header Connection 'upgrade';
    echo         proxy_set_header Host $host;
    echo         proxy_set_header X-Real-IP $remote_addr;
    echo         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    echo         proxy_set_header X-Forwarded-Proto $scheme;
    echo         proxy_cache_bypass $http_upgrade;
    echo     }
) else (
    echo     root "%PROJ_DIR:\=/%";
    echo     index index.php;
    echo.
    echo     location / {
    echo         try_files $uri $uri/ =404;
    echo     }
    echo.
    echo     location ~ \.php$ {
    echo         fastcgi_pass 127.0.0.1:%FASTCGI_PORT%;
    echo         fastcgi_index index.php;
    echo         fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    echo         include fastcgi_params;
    echo     }
)
echo }
) > "%VHOST%"

:: ============= TAMBAHKAN KE HOSTS =============
findstr /i /c:"%DOMAIN%" "%HOSTS_FILE%" >nul
if errorlevel 1 (
    echo 127.0.0.1 %DOMAIN% >> "%HOSTS_FILE%"
    echo [INFO] Menambahkan %DOMAIN% ke hosts.
) else (
    echo [INFO] %DOMAIN% sudah ada di hosts.
)

:: ============= SELESAI =============
echo.
echo [SUCCESS] Proyek '%PROJ_NAME%' berhasil dibuat!
echo     - Akses: https://%DOMAIN%/
echo     - Database: %DB_CONN% (%DB_PORT%)
echo     - .env_origin: %ENV_FILE%
echo     - SSL: %CRT_FILE%
echo.
echo Pastikan:
echo   - WebDevRootCA.crt sudah di-trust di sistem
echo   - Backend (PHP/Node.js) dan DB sudah berjalan
pause

goto MAIN_MENU
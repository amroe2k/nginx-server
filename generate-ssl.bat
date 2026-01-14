@echo off
setlocal enabledelayedexpansion

:: ===================================================================================
::  GENERATE SSL untuk proyek menggunakan WebDevRootCA
::  - Domain: nama-proyek.test
::  - Sertifikat ditandatangani oleh Root CA yang sudah diimpor ke Windows
::  - Tidak ada peringatan SSL di browser setelah restart NGINX
:: ===================================================================================

:: Cek hak Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Skrip ini harus dijalankan sebagai Administrator.
    echo        Klik kanan file ini ^> "Run as administrator"
    pause
    exit /b
)

set "BASE_DIR=D:\Web-Server"
set "WWW_DIR=%BASE_DIR%\www"
set "SITES_DIR=%BASE_DIR%\nginx\conf\sites-enabled"
set "CA_DIR=%BASE_DIR%\ssl-ca"
set "OPENSSL_PATH=C:\Program Files\OpenSSL-Win64\bin\openssl.exe"
set "HOSTS_FILE=%SystemRoot%\System32\drivers\etc\hosts"

:: Cek OpenSSL
if not exist "%OPENSSL_PATH%" (
    echo [ERROR] OpenSSL tidak ditemukan di:
    echo         %OPENSSL_PATH%
    echo.
    echo Unduh dari: https://slproweb.com/products/Win32OpenSSL.html    
    pause
    exit /b
)

:: Cek keberadaan Root CA
if not exist "%CA_DIR%\WebDevRootCA.crt" (
    echo [ERROR] Root CA tidak ditemukan.
    echo        Jalankan dulu: setup-root-ca.bat
    pause
    exit /b
)

:: Buat folder sites-enabled jika belum ada
if not exist "%SITES_DIR%" mkdir "%SITES_DIR%"

:MAIN_MENU
:: Deteksi semua folder proyek di www\
set idx=0
for /d %%D in ("%WWW_DIR%\*") do (
    set /a idx+=1
    set "proj[!idx!]=%%~nxD"
)

if %idx% equ 0 (
    echo [INFO] Tidak ada proyek ditemukan di %WWW_DIR%
    pause
    exit /b
)

cls
echo ==================================================
echo    GENERATE SSL dengan Root CA untuk .test
echo ==================================================
echo.
echo Pilih proyek:
for /l %%i in (1,1,%idx%) do (
    echo [%%i] !proj[%%i]!
)
echo [0] Keluar
echo.

set /p "choice=Nomor proyek [0-%idx%]: "

:: Cek pilihan Keluar
if "%choice%"=="0" (
    echo [INFO] Keluar dari program...
    exit /b
)

:: Validasi input
for /f "delims=0123456789" %%i in ("%choice%") do (
    echo [ERROR] Input harus angka.
    pause
    goto MAIN_MENU
)
if "%choice%"=="" (
    echo [ERROR] Input tidak boleh kosong.
    pause
    goto MAIN_MENU
)
if %choice% lss 1 (
    echo [ERROR] Nomor minimal 1.
    pause
    goto MAIN_MENU
)
if %choice% gtr %idx% (
    echo [ERROR] Nomor maksimal %idx%.
    pause
    goto MAIN_MENU
)

for /f "tokens=1" %%i in ("%choice%") do set "PROJECT_NAME=!proj[%%i]!"
set "PROJECT_PATH=%WWW_DIR%\%PROJECT_NAME%"
set "SUBDOMAIN=%PROJECT_NAME%.test"
set "SSL_DIR=%PROJECT_PATH%\ssl"
set "CONF_FILE=%SITES_DIR%\%PROJECT_NAME%.conf"

:: Buat folder ssl
if not exist "%SSL_DIR%" mkdir "%SSL_DIR%"

:: Tambahkan ke hosts jika belum ada
findstr /i /c:"%SUBDOMAIN%" "%HOSTS_FILE%" >nul
if errorlevel 1 (
    echo [INFO] Menambahkan %SUBDOMAIN% ke hosts...
    echo 127.0.0.1	%SUBDOMAIN% >> "%HOSTS_FILE%"
)

:: === Baca PHP_PORT dan PHP_VERSION dari .env_origin ===
set "PHP_PORT=9000"
set "PHP_VERSION=(tidak ditemukan)"
if exist "%PROJECT_PATH%\.env_origin" (
    for /f "tokens=1,2 delims==" %%a in ('findstr /b /c:"PHP_PORT=" "%PROJECT_PATH%\.env_origin"') do (
        set "PHP_PORT=%%b"
    )
    for /f "tokens=1,2 delims==" %%a in ('findstr /b /c:"PHP_VERSION=" "%PROJECT_PATH%\.env_origin"') do (
        set "PHP_VERSION=%%b"
    )
)

:: === Buat sertifikat menggunakan Root CA ===
echo.
echo [INFO] Membuat sertifikat untuk %SUBDOMAIN%...

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

:: Generate private key dan CSR
"%OPENSSL_PATH%" req -new -sha256 -newkey rsa:2048 -nodes ^
    -keyout "%KEY%" ^
    -out "%CSR%" ^
    -config "%CSR_CONFIG%" >nul 2>&1

if errorlevel 1 (
    echo [ERROR] Gagal membuat private key atau CSR.
    del /q "%CSR_CONFIG%" 2>nul
    pause
    goto MAIN_MENU
)

:: Tanda tangani dengan Root CA
"%OPENSSL_PATH%" x509 -req -in "%CSR%" ^
    -CA "%CA_DIR%\WebDevRootCA.crt" ^
    -CAkey "%CA_DIR%\WebDevRootCA.key" ^
    -CAcreateserial ^
    -out "%CRT%" ^
    -days 365 ^
    -sha256 ^
    -extfile "%CSR_CONFIG%" ^
    -extensions v3_req >nul 2>&1

if errorlevel 1 (
    echo [ERROR] Gagal menandatangani sertifikat dengan Root CA.
    del /q "%CSR%" "%CSR_CONFIG%" 2>nul
    pause
    goto MAIN_MENU
)

:: Bersihkan file sementara
del /q "%CSR%" "%CSR_CONFIG%" >nul 2>&1

:: === Tulis konfigurasi NGINX lengkap: HTTP→HTTPS + PHP_PORT dinamis ===
echo [INFO] Membuat konfigurasi NGINX dengan HTTP-HTTPS...

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
    echo         fastcgi_pass 127.0.0.1:%PHP_PORT%;
    echo         fastcgi_index index.php;
    echo         fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    echo         include fastcgi_params;
    echo     }
    echo }
)

:: === Selesai ===
echo.
echo ==================================================
echo [SUCCESS] SSL untuk %SUBDOMAIN% BERHASIL DIBUAT!
echo ==================================================
echo Domain: %SUBDOMAIN%
echo Akses:
echo   HTTP  : http://%SUBDOMAIN%/
echo   HTTPS : https://%SUBDOMAIN%/   ^(tanpa peringatan SSL^)
echo.
echo Konfigurasi PHP:
echo   Versi PHP : %PHP_VERSION%
echo   Port PHP  : %PHP_PORT%
echo.
echo File:
echo   CRT : %CRT%
echo   KEY : %KEY%
echo   NGINX Config : %CONF_FILE%
echo.
echo [INFO] JANGAN LUPA: Restart NGINX agar HTTPS aktif
echo ==================================================
echo.
pause

:: Kembali ke menu utama
goto MAIN_MENU
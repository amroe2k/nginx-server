@echo off
setlocal

:: ===================================================================================
::  Buat Root CA untuk *.test — Impor ke Windows Trust Store
::  Setelah ini, semua sertifikat yang ditandatangani oleh CA ini akan dipercaya
:: ===================================================================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Jalankan sebagai Administrator.
    pause
    exit /b
)

set "CA_DIR=D:\Web-Server\ssl-ca"
set "OPENSSL_PATH=C:\Program Files\OpenSSL-Win64\bin\openssl.exe"

if not exist "%OPENSSL_PATH%" (
    echo [ERROR] OpenSSL tidak ditemukan.
    pause
    exit /b
)

if not exist "%CA_DIR%" mkdir "%CA_DIR%"

echo [INFO] Membuat Root CA untuk *.test...

:: Buat file konfigurasi CA
> "%CA_DIR%\openssl-ca.cnf" (
    echo [ req ]
    echo default_bits = 4096
    echo prompt = no
    echo default_md = sha256
    echo distinguished_name = dn
    echo x509_extensions = v3_ca
    echo.
    echo [ dn ]
    echo CN = WebDev Local Root CA
    echo.
    echo [ v3_ca ]
    echo subjectKeyIdentifier = hash
    echo authorityKeyIdentifier = keyid:always,issuer
    echo basicConstraints = critical, CA:true
    echo keyUsage = critical, digitalSignature, cRLSign, keyCertSign
    echo.
    echo [ server_cert ]
    echo subjectAltName = @alt_names
    echo keyUsage = critical, digitalSignature, keyEncipherment
    echo extendedKeyUsage = serverAuth
    echo basicConstraints = CA:false
    echo.
    echo [ alt_names ]
    echo DNS.1 = *.test
    echo DNS.2 = localhost
)

:: Generate private key dan self-signed root certificate
"%OPENSSL_PATH%" req -x509 -newkey rsa:4096 -sha256 -nodes ^
    -keyout "%CA_DIR%\WebDevRootCA.key" ^
    -out "%CA_DIR%\WebDevRootCA.crt" ^
    -config "%CA_DIR%\openssl-ca.cnf" ^
    -days 3650 ^
    -extensions v3_ca

if errorlevel 1 (
    echo [ERROR] Gagal membuat Root CA.
    pause
    exit /b
)

:: Impor ke Windows Trusted Root Certification Authorities
echo.
echo [INFO] Mengimpor Root CA ke Windows Trust Store...
certutil -addstore -f "Root" "%CA_DIR%\WebDevRootCA.crt" >nul

if errorlevel 1 (
    echo [WARN] Gagal impor ke Trust Store.
) else (
    echo [OK] Root CA berhasil diimpor! Semua *.test yang ditandatangani akan dipercaya.
)

:: Buat skrip helper untuk generate sertifikat proyek
> "%CA_DIR%\create-site-cert.bat" (
    echo @echo off
    echo setlocal enabledelayedexpansion
    echo if "%%~1"=="" (
    echo     echo Usage: create-site-cert.bat ^<project-name^>
    echo     exit /b
    echo )
    echo set "PROJECT=%%~1"
    echo set "SUBDOMAIN=%%PROJECT%%.test"
    echo set "SSL_DIR=D:\Web-Server\www\%%PROJECT%%\ssl"
    echo if not exist "%%SSL_DIR%%" mkdir "%%SSL_DIR%%"
    echo.
    echo echo [INFO] Membuat sertifikat untuk %%SUBDOMAIN%%...
    echo.
    echo :: Buat config sementara
    echo ^> "%%SSL_DIR%%\openssl-site.cnf" ^(
    echo     echo [ req ]
    echo     echo default_bits = 2048
    echo     echo prompt = no
    echo     echo default_md = sha256
    echo     echo distinguished_name = dn
    echo     echo req_extensions = v3_req
    echo     echo.
    echo     echo [ dn ]
    echo     echo CN = %%SUBDOMAIN%%
    echo     echo.
    echo     echo [ v3_req ]
    echo     echo subjectAltName = @alt_names
    echo     echo.
    echo     echo [ alt_names ]
    echo     echo DNS.1 = %%SUBDOMAIN%%
    echo ^)
    echo.
    echo :: Generate CSR
    echo "C:\Program Files\OpenSSL-Win64\bin\openssl.exe" req -new -sha256 -newkey rsa:2048 -nodes ^
    echo     -keyout "%%SSL_DIR%%\%%SUBDOMAIN%%.key" ^
    echo     -out "%%SSL_DIR%%\%%SUBDOMAIN%%.csr" ^
    echo     -config "%%SSL_DIR%%\openssl-site.cnf"
    echo.
    echo :: Tanda tangani dengan Root CA
    echo "C:\Program Files\OpenSSL-Win64\bin\openssl.exe" x509 -req -in "%%SSL_DIR%%\%%SUBDOMAIN%%.csr" ^
    echo     -CA "D:\Web-Server\ssl-ca\WebDevRootCA.crt" ^
    echo     -CAkey "D:\Web-Server\ssl-ca\WebDevRootCA.key" ^
    echo     -CAcreateserial ^
    echo     -out "%%SSL_DIR%%\%%SUBDOMAIN%%.crt" ^
    echo     -days 365 ^
    echo     -sha256 ^
    echo     -extfile "%%SSL_DIR%%\openssl-site.cnf" ^
    echo     -extensions v3_req
    echo.
    echo del "%%SSL_DIR%%\%%SUBDOMAIN%%.csr" "%%SSL_DIR%%\openssl-site.cnf"
    echo echo [SUCCESS] Sertifikat untuk %%SUBDOMAIN%% siap!
    echo echo File: %%SSL_DIR%%\%%SUBDOMAIN%%.crt dan .key
)

echo.
echo ==================================================
echo [SUCCESS] Root CA untuk *.test berhasil dibuat!
echo ==================================================
echo File Root CA:
echo   CRT: %CA_DIR%\WebDevRootCA.crt   ^(sudah diimpor^)
echo   KEY: %CA_DIR%\WebDevRootCA.key   ^(simpan rahasia!^)
echo.
echo Untuk buat sertifikat proyek:
echo   D:\Web-Server\ssl-ca\create-site-cert.bat nama-proyek
echo.
echo Setelah itu, konfigurasikan NGINX untuk pakai .crt dan .key tersebut.
echo ==================================================
echo.
pause
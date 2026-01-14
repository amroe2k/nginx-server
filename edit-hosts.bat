@echo off
title Editor File Hosts dengan IP Default
setlocal enabledelayedexpansion

:: Cek administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Script harus dijalankan sebagai Administrator!
    echo Silakan klik kanan dan pilih "Run as administrator"
    pause
    goto :cmd_prompt
)

:menu
cls
echo ========================================
echo         EDITOR FILE HOSTS
echo ========================================
echo.
echo 1. Tambah Entry Baru (IP Default: 127.0.0.1)
echo 2. Lihat File Hosts
echo 3. Backup File Hosts
echo 4. Restore Backup
echo 5. Buka dengan Notepad
echo 6. Flush DNS Cache
echo 7. Kembali ke CMD Prompt
echo.
set /p "choice=Pilih menu [1-7]: "

if "!choice!"=="1" goto add_single
if "!choice!"=="2" goto view_hosts
if "!choice!"=="3" goto backup_hosts
if "!choice!"=="4" goto restore_backup
if "!choice!"=="5" goto open_notepad
if "!choice!"=="6" goto flush_dns
if "!choice!"=="7" goto :cmd_prompt

:: Jika pilihan tidak valid
echo Pilihan tidak valid!
pause
goto :menu

:add_single
cls
echo ========================================
echo         TAMBAH ENTRY BARU
echo ========================================
echo.
echo IP akan diisi otomatis 127.0.0.1 jika dikosongkan
echo Format: IP [TAB] Domain
echo.
echo Contoh:
echo [Enter untuk 127.0.0.1][TAB]localhost
echo 192.168.1.100[TAB]server.dev
echo.

:: Input IP dengan default value
set "ip=127.0.0.1"
set /p "input_ip=Masukkan IP (default 127.0.0.1): "
if not "!input_ip!"=="" set "ip=!input_ip!"

:: Input domain (wajib diisi)
:input_domain
set /p "domain=Masukkan Domain (wajib): "
if "!domain!"=="" (
    echo Domain tidak boleh kosong!
    goto :input_domain
)

:: Konfirmasi
echo.
echo ========================================
echo KONFIRMASI ENTRY:
echo IP: !ip!
echo Domain: !domain!
echo ========================================
echo.
set /p "confirm=Tambahkan ke file hosts? (Y/N): "
if /i not "!confirm!"=="Y" (
    echo Entry dibatalkan.
    pause
    goto :menu
)

:: Backup otomatis
set "backup_file=C:\Windows\System32\drivers\etc\hosts.backup_%date:~-4,4%%date:~-7,2%%date:~-10,2%_%time:~0,2%%time:~3,2%"
set "backup_file=!backup_file: =0!"
copy "C:\Windows\System32\drivers\etc\hosts" "!backup_file!" >nul 2>&1

:: Tambah entry dengan tab
echo !ip!	!domain! >> C:\Windows\System32\drivers\etc\hosts

echo.
echo ========================================
echo ENTRY BERHASIL DITAMBAHKAN:
echo !ip! [TAB] !domain!
echo ========================================
echo.

:: Tampilkan 5 entry terakhir
echo 5 entry terakhir file hosts:
echo ------------------------------
for /f "tokens=*" %%a in ('type "C:\Windows\System32\drivers\etc\hosts" ^| tail -5 2^>nul') do echo %%a
echo ------------------------------

:: Flush DNS
ipconfig /flushdns >nul
echo DNS Cache telah di-flush!

echo.
set /p "lagi=Tambah entry lagi? (Y/N): "
if /i "!lagi!"=="Y" goto :add_single

pause
goto :menu

:view_hosts
cls
echo ========================================
echo        ISI FILE HOSTS
echo ========================================
echo.
if exist "C:\Windows\System32\drivers\etc\hosts" (
    type "C:\Windows\System32\drivers\etc\hosts"
) else (
    echo File hosts tidak ditemukan!
)
echo.
pause
goto :menu

:backup_hosts
cls
echo ========================================
echo        BACKUP FILE HOSTS
echo ========================================
echo.
set "backup_dir=%USERPROFILE%\Desktop\Hosts_Backups"
if not exist "!backup_dir!" mkdir "!backup_dir!"

set "timestamp=%date:~-4%%date:~-7,2%%date:~-10,2%_%time:~0,2%%time:~3,2%"
set "timestamp=!timestamp: =0!"
set "backup_file=!backup_dir!\hosts_!timestamp!.txt"

copy "C:\Windows\System32\drivers\etc\hosts" "!backup_file!" >nul

if exist "!backup_file!" (
    echo Backup berhasil dibuat:
    echo !backup_file!
) else (
    echo Gagal membuat backup!
)

echo.
pause
goto :menu

:restore_backup
cls
echo ========================================
echo        RESTORE BACKUP
echo ========================================
echo.
set "backup_dir=%USERPROFILE%\Desktop\Hosts_Backups"
if not exist "!backup_dir!" (
    echo Directory backup tidak ditemukan: !backup_dir!
    pause
    goto :menu
)

echo Daftar backup yang tersedia:
echo ------------------------------
dir "!backup_dir!\hosts_*.txt" /b /o:-n 2>nul
echo ------------------------------
echo.

set /p "backup_file=Masukkan nama file backup: "
if "!backup_file!"=="" (
    echo Tidak ada file yang dipilih.
    pause
    goto :menu
)

set "full_path=!backup_dir!\!backup_file!"
if not exist "!full_path!" (
    echo File backup tidak ditemukan: !full_path!
    pause
    goto :menu
)

:: Konfirmasi restore
echo.
echo Anda akan me-restore file:
echo !full_path!
echo ke: C:\Windows\System32\drivers\etc\hosts
echo.
set /p "confirm=Lanjutkan? (Y/N): "
if /i not "!confirm!"=="Y" (
    echo Restore dibatalkan.
    pause
    goto :menu
)

:: Backup file hosts saat ini dulu
set "current_backup=C:\Windows\System32\drivers\etc\hosts.pre_restore_%time:~0,2%%time:~3,2%"
copy "C:\Windows\System32\drivers\etc\hosts" "!current_backup!" >nul 2>&1

:: Restore
copy "!full_path!" "C:\Windows\System32\drivers\etc\hosts" >nul

echo Restore berhasil!
ipconfig /flushdns >nul
echo DNS Cache telah di-flush!

echo.
pause
goto :menu

:open_notepad
cls
echo ========================================
echo        BUKA DENGAN NOTEPAD
echo ========================================
echo.
echo Membuka file hosts dengan Notepad...
notepad "C:\Windows\System32\drivers\etc\hosts"
echo.
pause
goto :menu

:flush_dns
cls
echo ========================================
echo        FLUSH DNS CACHE
echo ========================================
echo.
echo Membersihkan DNS cache...
ipconfig /flushdns
echo.
echo DNS cache telah di-flush!
echo.
pause
goto :menu

:cmd_prompt
echo.
echo Kembali ke Command Prompt...
echo Script selesai. Anda bisa mengetik perintah lain.
echo.
endlocal
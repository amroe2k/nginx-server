# Web Server Manager

## Deskripsi

Web Server Manager adalah alat manajemen lokal untuk pengembangan web di Windows. Script utama `web-manager.bat` menyediakan pembuatan dan penghapusan proyek web dengan HTTPS otomatis (sertifikat ditandatangani oleh WebDevRootCA), pembuatan `index.php` dasar, penambahan entri `hosts`, dan pembuatan konfigurasi NGINX di `nginx\conf\sites-enabled`.

Fitur utama:

- Buat proyek baru dengan HTTPS otomatis menggunakan Root CA lokal
- Hasilkan file `index.php` dan `.env_origin`
- Tambah/hapus entri di `C:\Windows\System32\drivers\etc\hosts`
- Buat dan hapus konfigurasi NGINX untuk tiap proyek

## Persyaratan

- Windows (jalankan sebagai Administrator)
- OpenSSL (disarankan: Win64 OpenSSL) terinstal. Default path di script: `C:\Program Files\OpenSSL-Win64\bin\openssl.exe`.
- NGINX tersedia di folder `nginx/` pada root proyek
- PHP (beberapa versi) tersedia di folder `php/` pada root proyek

## Instalasi & Persiapan

1. Salin seluruh folder `D:\Web-Server` ke mesin pengembangan.
2. Jika belum ada Root CA lokal, jalankan `setup-root-ca.bat` sekali untuk membuat `ssl-ca\WebDevRootCA.crt` dan `WebDevRootCA.key`.
3. Pastikan path OpenSSL pada baris atas `web-manager.bat` sesuai dengan lokasi OpenSSL Anda. Jika berbeda, update variabel `OPENSSL_PATH`.
4. (Opsional) Impor `ssl-ca\WebDevRootCA.crt` ke "Trusted Root Certification Authorities" di Windows agar browser lokal menerima sertifikat tanpa peringatan.

### Cara Install Root CA (WebDevRootCA.crt) ke Windows

Untuk menghindari peringatan keamanan pada browser saat mengakses situs HTTPS lokal, Anda perlu menginstall Root CA ke Windows:

**Metode 1: Menggunakan GUI Windows**

1. Buka File Explorer dan navigasi ke folder `D:\Web-Server\ssl-ca\`
2. Klik kanan pada file `WebDevRootCA.crt` dan pilih **"Install Certificate"**
3. Pilih **"Local Machine"** → klik **"Next"** (memerlukan hak Administrator)
4. Pilih **"Place all certificates in the following store"** → klik **"Browse"**
5. Pilih **"Trusted Root Certification Authorities"** → klik **"OK"**
6. Klik **"Next"** → klik **"Finish"**
7. Klik **"Yes"** pada dialog konfirmasi keamanan
8. Anda akan melihat pesan "The import was successful"

**Metode 2: Menggunakan Command Line (certutil)**

Jalankan Command Prompt atau PowerShell **sebagai Administrator**, lalu jalankan:

```cmd
certutil -addstore -f "ROOT" "D:\Web-Server\ssl-ca\WebDevRootCA.crt"
```

Output yang berhasil akan menampilkan:

```
ROOT "Trusted Root Certification Authorities"
Certificate "WebDevRootCA" added to store.
CertUtil: -addstore command completed successfully.
```

**Verifikasi Instalasi:**

1. Tekan `Win + R`, ketik `certmgr.msc`, dan tekan Enter
2. Buka **"Trusted Root Certification Authorities"** → **"Certificates"**
3. Cari sertifikat bernama **"WebDevRootCA"** dalam daftar
4. Restart browser Anda (Chrome, Firefox, Edge) untuk memastikan sertifikat terbaca

**Catatan Penting:**

- Root CA hanya perlu diinstall **satu kali** per mesin
- Setelah Root CA terinstall, semua sertifikat yang ditandatangani olehnya (seperti `project.test`) akan otomatis dipercaya oleh browser
- Untuk menghapus Root CA, buka `certmgr.msc`, cari "WebDevRootCA", klik kanan, dan pilih "Delete"

## Cara Menggunakan

- Jalankan `web-manager.bat` sebagai Administrator.
- Pilih [1] untuk membuat proyek baru. Script akan:
  - Membuat folder proyek di `www\<nama_proyek>`
  - Menambahkan entri pada file `hosts` seperti `127.0.0.1 <nama_proyek>.test`
  - Menghasilkan private key, sertifikat (ditandatangani oleh WebDevRootCA), dan menaruhnya di `www\<nama_proyek>\ssl`
  - Membuat konfigurasi NGINX di `nginx\conf\sites-enabled\<nama_proyek>.conf`
  - Membuat `index.php` dan `.env_origin`
- Pilih [2] untuk menghapus proyek (script akan menghapus folder proyek, file konfigurasi NGINX, dan entri hosts terkait). Pastikan NGINX dimatikan sebelum menghapus.
- Setelah membuat atau menghapus proyek, restart NGINX agar konfigurasi baru berlaku.

## Urutan Perintah yang harus dijalankan :

1. `setup-root-ca.bat` (generate SSL untuk di Import ke Windows pada folder ssl-ca)
2. `generate-ssl.bat` (generate ulang ssl key dashboard dan phpmyadmin)
3. `edit-hosts.bat` (edit file hosts windows)
4. `web-manager.bat` (Tambah/Hapus proyek)
5. `start-webserver.bat` (aktifkan Nginx Web Server)

## Tools Web

Beberapa alat web yang umum tersedia di lingkungan pengembangan ini:

- https://dashboard.test/ (Monitoring)
- https://phpmyadmin.test/ (MySQL Management)
  Catatan : Monitoring PostgreSQL, MongoDB dapat gunakan DBeaver, Navicat dll.

## Database yang didukung (Install sebagai service di Windows)

Database berikut didukung dan biasanya dijalankan sebagai service pada mesin pengembang lokal:

- MySQL : 127.0.0.1:3306
- MongoDB : 127.0.0.1:27017
- PostgreSQL: 127.0.0.1:5432

## Lokasi penting

- Root proyek: `D:\Web-Server\www`
- Konfigurasi NGINX per proyek: `D:\Web-Server\nginx\conf\sites-enabled\<project>.conf`
- Root CA: `D:\Web-Server\ssl-ca\WebDevRootCA.crt`
- File proyek baru: `d:\Web-Server\www\<project>\` (termasuk `index.php`, `.env_origin`, `ssl\`)

## Struktur Direktori

```
D:\Web-Server\
│
├── www\                          # Root web (document root)
│   └── <nama_proyek>\            # Contoh: web-tester\
│       ├── index.php             # Otomatis dibuat: <?php phpinfo(); ?>
│       └── .env_origin           # Konfigurasi proyek (bukan .env)
│
├── nginx\
│   └── conf\
│       ├── nginx.conf            # Konfigurasi utama (harus include sites-enabled)
│       └── sites-enabled\        # ⚠️ HANYA di sini tempat file vhost
│           └── <nama_proyek>.conf
│
├── php\                          # Build PHP multi-versi
│   ├── php74\
│   ├── php80\
│   ├── php81\
│   ├── php82\
│   ├── php83\
│   └── php84\
│
├── ssl-ca\                       # WebDevRootCA (wajib untuk HTTPS)
│   ├── WebDevRootCA.crt
│   └── WebDevRootCA.key
│
└── *.bat                         # Semua skrip: web-manager.bat, start-webserver.bat, dll
```

## Panduan Kontribusi

Terima kasih atas minat melakukan kontribusi. Silakan ikuti panduan singkat ini:

1. Fork repositori dan buat branch fitur/bugfix bernama `feat/<deskripsi>` atau `fix/<deskripsi>`.
2. Ikuti gaya penulisan batch script yang jelas: komentar singkat, variabel di bagian atas, dan pengecekan error.
3. Uji perubahan pada mesin Windows nyata (jalankan sebagai Administrator). Verifikasi pembuatan sertifikat, entri hosts, dan file konfigurasi NGINX.
4. Jika mengubah path default (mis. lokasi OpenSSL), tambahkan dokumentasi di README dan cek error handling.
5. Buat Pull Request ke branch utama, sertakan deskripsi perubahan dan langkah uji yang dilakukan.

## Melaporkan Masalah

Buat issue baru dengan:

- Deskripsi masalah yang jelas
- Langkah reproduksi
- Output error (jika ada)
- Versi Windows dan lokasi OpenSSL

## Catatan Keamanan

- Root CA yang dibuat oleh `setup-root-ca.bat` sebaiknya hanya digunakan untuk pengembangan lokal.
- Jangan gunakan sertifikat CA lokal untuk layanan publik.


## Kontak

Untuk pertanyaan atau bantuan lebih lanjut, buat issue pada repository atau hubungi maintainer proyek.
WA : 0851 8846 8880

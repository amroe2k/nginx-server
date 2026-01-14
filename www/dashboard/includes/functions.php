<?php
function getGlobalServerStatus()
{
    $globalEnv = 'D:/Web-Server/www/.env';
    $status = [
        'php_version' => null,
        'php_versions' => [],
        // Compatibility: 'active' flags reflect actual running state
        'mysql_active' => false,
        'mysql_configured' => false,
        'mysql_running' => false,
        'mongo_active' => false,
        'mongo_configured' => false,
        'mongo_running' => false,
        'pg_active' => false,
        'pg_configured' => false,
        'pg_running' => false
    ];

    if (!file_exists($globalEnv)) {
        // masih lanjut untuk mendeteksi proses php aktif walau .env tidak ada
        // return $status;
    }

    if (file_exists($globalEnv)) {
        $lines = @file($globalEnv, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        if ($lines) {
            foreach ($lines as $line) {
                $line = trim($line);
                if ($line === '' || strpos($line, '#') === 0) continue;

                if (strpos($line, '=') !== false) {
                    [$key, $value] = explode('=', $line, 2);
                    $key = trim($key);
                    // ✅ Perbaikan: hapus kutipan dengan benar
                    $value = trim($value, "\"' \t\n\r\0\x0B");
                    $value = trim($value); // extra safety

                    if ($key === 'PHP_VERSION') {
                        $status['php_version'] = $value;
                    } elseif ($key === 'MYSQL_ACTIVE' && $value === '1') {
                        $status['mysql_configured'] = true;
                    } elseif ($key === 'MONGO_ACTIVE' && $value === '1') {
                        $status['mongo_configured'] = true;
                    } elseif ($key === 'PG_ACTIVE' && $value === '1') {
                        $status['pg_configured'] = true;
                    }
                }
            }
        }
    }

    // Verifikasi status service database secara real-time (Windows sc / netstat)
    // Prioritaskan pengecekan runtime tetapi simpan juga informasi konfigurasi (.env)
    $checkServiceRunning = function (array $serviceNames, int $port = null) {
        // cek service name via sc
        foreach ($serviceNames as $s) {
            $out = @shell_exec('sc query "' . $s . '" 2>&1');
            if ($out !== null && stripos($out, 'RUNNING') !== false) {
                return true;
            }
        }
        // fallback: cek port LISTENING via netstat jika port diberikan
        if ($port !== null) {
            $net = @shell_exec('netstat -ano 2>&1');
            if ($net !== null) {
                $lines = preg_split('/\r?\n/', $net);
                foreach ($lines as $l) {
                    if (stripos($l, ':' . $port) !== false && (stripos($l, 'LISTENING') !== false || stripos($l, 'LISTEN') !== false)) {
                        return true;
                    }
                }
            }
        }
        return false;
    };

    // MySQL - simpan apakah dikonfigurasi di .env, dan cek apakah sebenarnya berjalan
    $status['mysql_running'] = $checkServiceRunning(['MySQL80', 'MySQL', 'MySQL57'], 3306);
    if (isset($status['mysql_configured']) === false) {
        $status['mysql_configured'] = false;
    }
    // jaga kompatibilitas: mysql_active menunjukkan running
    $status['mysql_active'] = $status['mysql_running'];

    // MongoDB
    $status['mongo_running'] = $checkServiceRunning(['MongoDB', 'mongodb'], 27017);
    if (isset($status['mongo_configured']) === false) {
        $status['mongo_configured'] = false;
    }
    $status['mongo_active'] = $status['mongo_running'];

    // PostgreSQL - cek beberapa nama service umum
    $pgServiceNames = ['postgresql-x64-17', 'postgresql-x64-16', 'postgresql-x64-15', 'postgresql-x64-14', 'pgsql-x64-16', 'PostgreSQL_16', 'pg_sql_16', 'postgresql-16'];
    $status['pg_running'] = $checkServiceRunning($pgServiceNames, 5432);
    if (isset($status['pg_configured']) === false) {
        $status['pg_configured'] = false;
    }
    $status['pg_active'] = $status['pg_running'];

    // Deteksi versi PHP yang aktif saat ini berdasarkan struktur folder php dan port 90xx yang dipakai
    $phpBase = 'D:/Web-Server/php';
    $all = [];

    if (is_dir($phpBase)) {
        $dirs = @scandir($phpBase);
        if ($dirs !== false) {
            $map = []; // portString => version label
            foreach ($dirs as $d) {
                // cari folder seperti php74, php80, php81, php82, dll.
                if (preg_match('/^php(\d)(\d+)$/', $d, $m)) {
                    // contoh: php74 => m[1]=7 m[2]=4 => 7.4
                    $major = $m[1];
                    $minor = $m[2];
                    $code = $major . $minor; // e.g. '74' or '80' or '83'
                    $label = $major . '.' . $minor;
                    $port = '90' . $code; // sesuai start-webserver.bat
                    $map[$port] = $label;
                    // tambahkan ke daftar semua (default inactive)
                    $all[$port] = ['version' => $label, 'port' => (int)$port, 'active' => false];
                }
            }

            if (!empty($map)) {
                // jalankan netstat dan tandai port yang LISTENING
                $netstat = @shell_exec('netstat -ano 2>&1');
                if ($netstat !== null) {
                    $lines = preg_split('/\r?\n/', $netstat);
                    foreach ($lines as $line) {
                        $line = trim($line);
                        if ($line === '') continue;
                        foreach ($map as $port => $label) {
                            // cari pola ':<port>' pada kolom Local Address
                            if (stripos($line, ':' . $port) !== false && (stripos($line, 'LISTENING') !== false || stripos($line, 'LISTEN') !== false)) {
                                if (isset($all[$port])) {
                                    $all[$port]['active'] = true;
                                } else {
                                    // fallback: tambahkan jika belum ada
                                    $all[$port] = ['version' => $label, 'port' => (int)$port, 'active' => true];
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    if (!empty($all)) {
        // urutkan secara versi
        uasort($all, function ($a, $b) {
            return version_compare($a['version'], $b['version']);
        });
        // reset index
        $status['php_versions'] = array_values($all);
        // ringkasan kompatibilitas: tandai aktif dengan '*' (opsional)
        $parts = [];
        foreach ($status['php_versions'] as $a) {
            $parts[] = $a['version'] . ' (' . $a['port'] . ')' . ($a['active'] ? '' : '');
        }
        $status['php_version'] = implode(', ', $parts);
    } else {
        if (empty($status['php_version'])) {
            $status['php_version'] = null;
        }
    }

    return $status;
}

function getUniquePhpVersions($projects)
{
    $versions = [];
    foreach ($projects as $info) {
        if ($info['php_version'] && !in_array($info['php_version'], $versions)) {
            $versions[] = $info['php_version'];
        }
    }
    sort($versions);
    return $versions;
}

function scanProjects()
{
    $wwwDir = 'D:/Web-Server/www';
    $projects = [];

    if (!is_dir($wwwDir)) return $projects;

    $items = scandir($wwwDir);
    foreach ($items as $item) {
        // Exclude folder sistem dan dashboard
        if ($item === '.' || $item === '..' || $item === 'dashboard' || !is_dir("$wwwDir/$item")) {
            continue;
        }

        $projectName = $item;
        $projectPath = "$wwwDir/$item";
        $envPath = "$projectPath/.env_origin";
        $subdomain = "$projectName.test";

        $info = [
            'path' => $projectPath,
            'subdomain' => $subdomain,
            'php_version' => null,
            'db' => []
        ];

        if (file_exists($envPath)) {
            $lines = @file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
            if ($lines) {
                foreach ($lines as $line) {
                    $line = trim($line);
                    if ($line === '' || strpos($line, '#') === 0) continue;

                    if (strpos($line, '=') !== false) {
                        [$key, $value] = explode('=', $line, 2);
                        $key = trim($key);
                        // ✅ Perbaikan utama: hapus kutipan dengan benar
                        $value = trim($value, "\"' \t\n\r\0\x0B");
                        $value = trim($value);

                        if ($key === 'PHP_VERSION') {
                            $info['php_version'] = $value;
                        }

                        if ($key === 'DB_CONNECTION') {
                            $conn = strtolower($value);
                            if (in_array($conn, ['mysql', 'mariadb'])) {
                                $info['db'][] = 'MySQL';
                            } elseif (in_array($conn, ['pgsql', 'postgres', 'postgresql'])) {
                                $info['db'][] = 'PostgreSQL';
                            } elseif (in_array($conn, ['mongodb', 'mongo'])) {
                                $info['db'][] = 'MongoDB';
                            }
                        }
                    }
                }
            }
        }

        $projects[$projectName] = $info;
    }

    ksort($projects);
    return $projects;
}

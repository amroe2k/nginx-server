<?php
require_once __DIR__ . '/includes/functions.php';

// Fungsi untuk menghasilkan gradasi pastel lembut yang TERLIHAT jelas
function getSoftGradient($str)
{
    // Daftar warna pastel yang lembut tapi cukup jelas
    $pastelColors = [
        [230, 240, 255], // biru muda
        [255, 240, 245], // pink lembut
        [240, 255, 245], // hijau mint
        [255, 250, 230], // peach
        [245, 240, 255], // ungu pastel
        [235, 250, 255], // cyan lembut
    ];

    // Pilih warna berdasarkan hash nama proyek
    $hash = crc32($str);
    $index = abs($hash) % count($pastelColors);
    $color = $pastelColors[$index];

    $r = $color[0];
    $g = $color[1];
    $b = $color[2];

    // Gradasi sedikit lebih tegas untuk kontras lebih baik
    $color1 = "rgba($r, $g, $b, 0.36)"; // lebih pekat
    $color2 = "rgba($b, $r, $g, 0.22)"; // sedikit lebih pekat

    // fallback solid color (untuk browser yang tidak mendukung gradient) gunakan nilai rata-rata
    $avg = (int)(($r + $g + $b) / 3);
    $fallback = "rgba($avg, $avg, $avg, 0.04)";

    return "linear-gradient(135deg, $color1, $color2), $fallback";
}

$projects = scanProjects();
$globalStatus = getGlobalServerStatus();
?>

<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Dev Server</title>

    <!-- Favicon -->
    <link rel="icon" href="favicon.ico" type="image/x-icon">
    <link rel="icon" href="favicon.svg" type="image/svg+xml">
    <link rel="shortcut icon" href="favicon.ico">

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- Custom CSS -->
    <link rel="stylesheet" href="assets/style.css">
</head>

<body>

    <div class="container py-4">
        <!-- ✨ Header Elegan -->
        <div class="text-center mb-5">
            <div class="d-inline-flex align-items-center justify-content-center mb-3">
                <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 60px; height: 60px; font-size: 28px; font-weight: 600; box-shadow: 0 4px 12px rgba(67, 97, 238, 0.25);">
                    D
                </div>
            </div>
            <h1 class="fw-bold text-dark" style="font-size: 2.25rem; letter-spacing: -0.5px;">Dashboard Web Server Lokal</h1>
            <p class="text-muted mt-2">Monitoring Proyek dan Status Server Nginx + Multi PHP</p>
        </div>

        <!-- Status Server Global -->
        <div class="card mb-4 shadow-sm border-0 rounded-3">
            <div class="card-body">
                <h5 class="mb-3 d-flex align-items-center gap-2 fw-semibold text-dark">
                    <i class="bi bi-server text-primary"></i> Status Server Global
                </h5>
                <div class="row g-2 g-md-3 align-items-center">
                    <div class="col-6 col-md-6 col-lg-3">
                        <div class="d-flex align-items-center gap-1">
                            <i class="bi bi-code-slash fs-4 text-info"></i>
                            <div>
                                <?php if (!empty($globalStatus['php_versions'])): ?>
                                    <div class="row row-cols-2 row-cols-md-3 row-cols-lg-3 g-2 g-md-3 g-lg-4 w-100">
                                        <?php foreach ($globalStatus['php_versions'] as $pv): ?>
                                            <div class="col mb-1">
                                                <div class="d-grid">
                                                    <?php $isActive = !empty($pv['active']); ?>
                                                    <span class="badge bg-white text-dark border py-1 px-2 d-flex justify-content-between align-items-center w-100" style="gap:6px;">
                                                        <span class="fw-semibold small text-truncate" style="max-width:70%;"><?= htmlspecialchars($pv['version']) ?></span>
                                                        <div class="d-flex align-items-center" style="gap:6px;">
                                                            <?php $portClass = $isActive ? 'bg-success text-white' : 'bg-secondary text-white'; ?>
                                                            <span class="badge <?= $portClass ?> small" style="font-weight:600; padding:0.25rem 0.45rem;"><?= htmlspecialchars($pv['port']) ?></span>
                                                        </div>
                                                    </span>
                                                </div>
                                            </div>
                                        <?php endforeach; ?>
                                    </div>
                                <?php else: ?>
                                    <div class="fw-bold text-dark">
                                        <?= htmlspecialchars($globalStatus['php_version'] ?: '–') ?>
                                    </div>
                                <?php endif; ?>
                            </div>
                        </div>
                    </div>

                    <div class="col-6 col-md-6 col-lg-3 align-self-start">
                        <div class="d-flex align-items-center gap-1 justify-content-center">
                            <?php if (!empty($globalStatus['mysql_running'])): ?>
                                <i class="bi bi-check-circle-fill fs-4 text-success"></i>
                            <?php else: ?>
                                <i class="bi bi-x-circle fs-4 text-secondary"></i>
                            <?php endif; ?>
                            <div class="text-center">
                                <div class="small text-muted">MySQL</div>
                                <div>
                                    <?php if (!empty($globalStatus['mysql_running'])): ?>
                                        <span class="text-success fw-medium">Aktif</span>
                                    <?php else: ?>
                                        <span class="text-muted">Tidak aktif</span>
                                    <?php endif; ?>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-6 col-md-6 col-lg-3 align-self-start">
                        <div class="d-flex align-items-center gap-1 justify-content-center">
                            <?php if (!empty($globalStatus['pg_running'])): ?>
                                <i class="bi bi-check-circle-fill fs-4 text-success"></i>
                            <?php else: ?>
                                <i class="bi bi-x-circle fs-4 text-secondary"></i>
                            <?php endif; ?>
                            <div class="text-center">
                                <div class="small text-muted">PostgreSQL</div>
                                <div>
                                    <?php if (!empty($globalStatus['pg_running'])): ?>
                                        <span class="text-success fw-medium">Aktif</span>
                                    <?php else: ?>
                                        <span class="text-muted">Tidak aktif</span>
                                    <?php endif; ?>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-6 col-md-6 col-lg-3 align-self-start">
                        <div class="d-flex align-items-center gap-1 justify-content-center">
                            <?php if (!empty($globalStatus['mongo_running'])): ?>
                                <i class="bi bi-check-circle-fill fs-4 text-success"></i>
                            <?php else: ?>
                                <i class="bi bi-x-circle fs-4 text-secondary"></i>
                            <?php endif; ?>
                            <div class="text-center">
                                <div class="small text-muted">MongoDB</div>
                                <div>
                                    <?php if (!empty($globalStatus['mongo_running'])): ?>
                                        <span class="text-success fw-medium">Aktif</span>
                                    <?php else: ?>
                                        <span class="text-muted">Tidak aktif</span>
                                    <?php endif; ?>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Filter Controls - Versi Rapi & Intuitif -->
        <div class="row g-4 mb-4">
            <!-- Filter PHP -->
            <div class="col-md-6 col-xl-4">
                <div class="card h-100 shadow-sm rounded-3 border-0">
                    <div class="card-body">
                        <div class="d-flex align-items-center gap-2 mb-3">
                            <i class="bi bi-code-slash text-info fs-5"></i>
                            <h6 class="mb-0 fw-semibold">Versi PHP</h6>
                        </div>
                        <select id="filter-php" class="form-select">
                            <option value="">Semua Versi</option>
                            <?php foreach (getUniquePhpVersions($projects) as $v): ?>
                                <option value="<?= htmlspecialchars($v) ?>"><?= htmlspecialchars($v) ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                </div>
            </div>

            <!-- Filter Database -->
            <div class="col-md-6 col-xl-6">
                <div class="card h-100 shadow-sm rounded-3 border-0">
                    <div class="card-body">
                        <div class="d-flex align-items-center gap-2 mb-3">
                            <i class="bi bi-database-fill text-success fs-5"></i>
                            <h6 class="mb-0 fw-semibold">Jenis Database</h6>
                        </div>
                        <div class="d-flex flex-wrap gap-2">
                            <?php foreach (['MySQL', 'PostgreSQL', 'MongoDB'] as $db): ?>
                                <div class="form-check">
                                    <input class="form-check-input filter-db" type="checkbox" value="<?= htmlspecialchars($db) ?>" id="db-<?= strtolower($db) ?>">
                                    <label class="form-check-label small" for="db-<?= strtolower($db) ?>">
                                        <?= htmlspecialchars($db) ?>
                                    </label>
                                </div>
                            <?php endforeach; ?>
                            <div class="form-check">
                                <input class="form-check-input filter-db" type="checkbox" value="none" id="db-none">
                                <label class="form-check-label small" for="db-none">Tanpa DB</label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tombol Reset -->
            <div class="col-md-12 col-xl-2 d-flex align-items-center">
                <div class="w-100">
                    <button id="btn-clear" class="btn btn-outline-secondary w-100 py-2">
                        <i class="bi bi-arrow-clockwise me-1"></i> Reset
                    </button>
                </div>
            </div>
        </div>

        <!-- Daftar Proyek -->
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h2 class="h5 mb-0 text-dark">Daftar Proyek (<span id="project-count"><?= count($projects) ?></span>)</h2>
        </div>

        <?php if (empty($projects)): ?>
            <div class="text-center py-5">
                <p class="text-muted">Tidak ada proyek di <code>E:\Web-Server\www</code></p>
                <p>Pastikan setiap proyek memiliki <code>.env_origin</code>.</p>
            </div>
        <?php else: ?>
            <div class="row g-4" id="projects-container">
                <?php foreach ($projects as $name => $info): ?>
                    <div
                        class="col-md-6 col-lg-4 project-item"
                        data-php="<?= htmlspecialchars($info['php_version'] ?: '') ?>"
                        data-db="<?= htmlspecialchars(implode(',', $info['db']) ?: 'none') ?>">
                        <!-- ✅ Card dengan background gradasi lembut -->
                        <div class="card project-card shadow-sm h-100" style="background: <?= getSoftGradient($name) ?>; backdrop-filter: blur(1px); border:1px solid rgba(11,23,38,0.06);">
                            <div class="card-body">
                                <h5 class="card-title d-flex align-items-center gap-2">
                                    <?= htmlspecialchars($name) ?>
                                    <?php if (!empty($info['db'])): ?>
                                        <span class="text-success" title="Database terkonfigurasi">
                                            <i class="bi bi-check-circle-fill"></i>
                                        </span>
                                    <?php else: ?>
                                        <span class="text-muted" title="Tidak ada database">
                                            <i class="bi bi-circle"></i>
                                        </span>
                                    <?php endif; ?>
                                </h5>

                                <!-- ✅ Badge elegan untuk subdomain -->
                                <span class="d-block mb-3">
                                    <a href="https://<?= htmlspecialchars($info['subdomain']) ?>" target="_blank" class="badge subdomain-badge">
                                        <i class="bi bi-box-arrow-up-right me-1"></i>
                                        <?= htmlspecialchars($info['subdomain']) ?>
                                    </a>
                                </span>

                                <p class="mb-2">
                                    <i class="bi bi-code-slash me-1 text-info"></i>
                                    <strong>PHP:</strong>
                                    <span class="badge badge-php"><?= htmlspecialchars($info['php_version'] ?: '–') ?></span>
                                </p>

                                <p class="mb-2"><strong>Database:</strong></p>
                                <?php if (!empty($info['db'])): ?>
                                    <div class="d-flex flex-wrap gap-1 mb-2">
                                        <?php foreach ($info['db'] as $db): ?>
                                            <span class="badge badge-db d-flex align-items-center gap-1">
                                                <?php if ($db === 'MySQL'): ?>
                                                    <i class="bi bi-database"></i>
                                                <?php elseif ($db === 'PostgreSQL'): ?>
                                                    <i class="bi bi-database-fill"></i>
                                                <?php elseif ($db === 'MongoDB'): ?>
                                                    <i class="bi bi-bezier"></i>
                                                <?php endif; ?>
                                                <?= htmlspecialchars($db) ?>
                                            </span>
                                        <?php endforeach; ?>
                                    </div>
                                <?php else: ?>
                                    <p class="text-muted small mb-2">–</p>
                                <?php endif; ?>

                                <p class="small text-muted mb-0">
                                    <code><?= htmlspecialchars(str_replace('/', '\\', substr($info['path'], 0, 45)) . (strlen($info['path']) > 45 ? '…' : '')) ?></code>
                                </p>
                            </div>
                        </div>
                    </div>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>

        <footer class="mt-5 pt-3 border-top text-center small text-muted">
            Global: dari <code>.env</code> • Proyek: dari <code>.env_origin</code> • Dev lokal
        </footer>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const phpSelect = document.getElementById('filter-php');
            const dbChecks = document.querySelectorAll('.filter-db');
            const clearBtn = document.getElementById('btn-clear');
            const projectItems = document.querySelectorAll('.project-item');
            const countEl = document.getElementById('project-count');

            function filterProjects() {
                const selectedPhp = phpSelect.value;
                const selectedDbs = Array.from(dbChecks)
                    .filter(cb => cb.checked)
                    .map(cb => cb.value);

                let visibleCount = 0;

                projectItems.forEach(item => {
                    const php = item.dataset.php;
                    const dbs = item.dataset.db.split(',').filter(d => d);

                    let show = true;

                    if (selectedPhp && php !== selectedPhp) {
                        show = false;
                    }

                    if (selectedDbs.length > 0) {
                        if (selectedDbs.includes('none')) {
                            if (dbs.length > 0) show = false;
                        } else {
                            const hasMatch = selectedDbs.some(db => dbs.includes(db));
                            if (!hasMatch && dbs.length > 0) show = false;
                            if (dbs.length === 0) show = false;
                        }
                    }

                    item.style.display = show ? '' : 'none';
                    if (show) visibleCount++;
                });

                countEl.textContent = visibleCount;
            }

            phpSelect.addEventListener('change', filterProjects);
            dbChecks.forEach(cb => cb.addEventListener('change', filterProjects));
            clearBtn.addEventListener('click', () => {
                phpSelect.value = '';
                dbChecks.forEach(cb => cb.checked = false);
                filterProjects();
            });
        });
    </script>
</body>

</html>
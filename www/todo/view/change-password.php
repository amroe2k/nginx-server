<?php
require_once 'includes/functions.php';
require_once 'includes/auth.php';
require_once 'config/database.php';

if (!isLoggedIn()) {
    redirect('../index.php?page=login');
}

$auth = new Auth();
$db = new Database();
$conn = $db->getConnection();
$userId = getCurrentUserId();

$error = '';
$success = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $currentPassword = trim($_POST['current_password'] ?? '');
    $newPassword = trim($_POST['new_password'] ?? '');
    $confirmPassword = trim($_POST['confirm_password'] ?? '');

    if (!$currentPassword || !$newPassword || !$confirmPassword) {
        $error = 'Semua kolom wajib diisi.';
    } elseif ($newPassword !== $confirmPassword) {
        $error = 'Password baru dan konfirmasi tidak sama.';
    } elseif (!$auth->validatePasswordStrength($newPassword)) {
        $error = 'Password harus minimal 6 karakter.';
    } else {
        try {
            $stmt = $conn->prepare('SELECT password FROM users WHERE id = :id');
            $stmt->bindParam(':id', $userId, PDO::PARAM_INT);
            $stmt->execute();
            $row = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$row) {
                $error = 'Data pengguna tidak ditemukan.';
            } elseif (!password_verify($currentPassword, $row['password'])) {
                $error = 'Password saat ini tidak sesuai.';
            } else {
                if ($auth->changePassword($userId, $newPassword)) {
                    setToast('success', 'Password berhasil diperbarui.');
                    redirect('../index.php?page=dashboard');
                } else {
                    $error = 'Gagal memperbarui password. Coba lagi.';
                }
            }
        } catch (Exception $ex) {
            $error = 'Gagal memperbarui password: ' . $ex->getMessage();
        }
    }
}
?>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ganti Password - Todo Talenta Digital</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@sweetalert2/theme-dark@4/dark.css">
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <?php include 'navbar.php'; ?>

    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card card-soft-blue shadow-sm">
                    <div class="card-body p-4">
                        <h4 class="card-title mb-3"><i class="bi bi-key me-2"></i>Ganti Password</h4>
                        <p class="text-muted mb-4">Gunakan password kuat agar akun tetap aman.</p>

                        <form method="POST" id="changePasswordForm">
                            <div class="mb-3">
                                <label class="form-label"><i class="bi bi-lock-fill me-1"></i>Password Saat Ini</label>
                                <div class="password-input-group">
                                    <input type="password" class="form-control" name="current_password" id="current_password" required>
                                    <span class="password-toggle" data-target="current_password"><i class="fas fa-eye"></i></span>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label"><i class="bi bi-shield-lock-fill me-1"></i>Password Baru</label>
                                <div class="password-input-group">
                                    <input type="password" class="form-control" name="new_password" id="new_password" required>
                                    <span class="password-toggle" data-target="new_password"><i class="fas fa-eye"></i></span>
                                </div>
                                <div class="mt-2">
                                    <div id="passwordStrength" class="password-strength-meter"></div>
                                    <div id="passwordStrengthText" class="password-strength-text"></div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label"><i class="bi bi-check2-circle me-1"></i>Konfirmasi Password Baru</label>
                                <div class="password-input-group">
                                    <input type="password" class="form-control" name="confirm_password" id="confirm_password" required>
                                    <span class="password-toggle" data-target="confirm_password"><i class="fas fa-eye"></i></span>
                                </div>
                                <div id="passwordMatch" class="mt-2"></div>
                            </div>
                            <div class="d-flex justify-content-between">
                                <a href="?page=dashboard" class="btn btn-outline-secondary"><i class="bi bi-arrow-left me-1"></i>Kembali</a>
                                <button type="submit" class="btn btn-primary"><i class="bi bi-save me-1"></i>Simpan</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="../js/utils.js"></script>
    <script src="../js/change-password.js"></script>
    <?php echo displayToast(); ?>
    <?php if ($error): ?>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            showPasswordMessage('error', 'Gagal', <?php echo json_encode($error); ?>);
        });
    </script>
    <?php endif; ?>
    <?php if ($success): ?>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            showPasswordMessage('success', 'Berhasil', <?php echo json_encode($success); ?>);
        });
    </script>
    <?php endif; ?>
    
    <?php include 'footer.php'; ?>
</body>
</html>
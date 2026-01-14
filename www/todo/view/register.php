<?php
require_once 'includes/functions.php';
require_once 'includes/auth.php';

if(isLoggedIn()) {
    redirect('../index.php?page=dashboard');
}

$auth = new Auth();
$error = '';
$success = '';

if($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = sanitize($_POST['username']);
    $email = sanitize($_POST['email']);
    $password = $_POST['password'];
    $confirm_password = $_POST['confirm_password'];
    
    if($password !== $confirm_password) {
        $error = 'Passwords do not match!';
    } elseif(!$auth->validatePasswordStrength($password)) {
        $error = 'Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, and one number.';
    } else {
        if($auth->register($username, $email, $password, 'user', 0, 1)) {
            $success = 'Registration successful! Your account is pending admin approval. You will receive an email once approved.';
        } else {
            $error = 'Registration failed. Username or email already exists.';
        }
    }
}
?>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Todo Talenta Digital</title>
    <link rel="icon" type="image/svg+xml" href="../favicon.svg">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@sweetalert2/theme-dark@4/dark.css">
    <link rel="stylesheet" href="../css/style.css">
</head>
<body class="bg-light">
    <div class="container">
        <div class="row justify-content-center mt-5">
            <div class="col-md-6 col-lg-4">
                <div class="card shadow">
                    <div class="card-body p-5">
                        <h2 class="text-center mb-4">
                            <i class="fas fa-user-plus text-primary"></i> Register
                        </h2>
                        
                        <?php /* Alerts moved to SweetAlert toast; see script below */ ?>
                        
                        <form method="POST" action="" id="registerForm">
                            <div class="mb-3">
                                <label for="username" class="form-label">
                                    <i class="fas fa-user me-1"></i> Username
                                </label>
                                <input type="text" class="form-control" id="username" name="username" required>
                            </div>
                            <div class="mb-3">
                                <label for="email" class="form-label">
                                    <i class="fas fa-envelope me-1"></i> Email
                                </label>
                                <input type="email" class="form-control" id="email" name="email" required>
                            </div>
                            <div class="mb-3">
                                <label for="password" class="form-label">
                                    <i class="fas fa-lock me-1"></i> Password
                                </label>
                                <div class="password-input-group">
                                    <input type="password" class="form-control" id="password" name="password" required>
                                    <span class="password-toggle" data-target="password">
                                        <i class="fas fa-eye"></i>
                                    </span>
                                </div>
                                <div class="mt-2">
                                    <div id="passwordStrength" class="password-strength-meter"></div>
                                    <div id="passwordStrengthText" class="password-strength-text"></div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label for="confirm_password" class="form-label">
                                    <i class="fas fa-lock me-1"></i> Confirm Password
                                </label>
                                <div class="password-input-group">
                                    <input type="password" class="form-control" id="confirm_password" name="confirm_password" required>
                                    <span class="password-toggle" data-target="confirm_password">
                                        <i class="fas fa-eye"></i>
                                    </span>
                                </div>
                                <div id="passwordMatch" class="mt-2"></div>
                            </div>
                            <div class="d-grid gap-2 mt-4">
                                <button type="submit" class="btn btn-primary btn-lg">
                                    <i class="fas fa-user-plus me-2"></i> Register
                                </button>
                                <a href="../index.php?page=login" class="btn btn-outline-secondary">
                                    <i class="fas fa-sign-in-alt me-2"></i> Back to Login
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.js"></script>
    <script src="../js/utils.js"></script>
    <script src="../js/register.js"></script>
    <?php if($error || $success): ?>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            <?php if($error): ?>
            showServerMessage('error', <?php echo json_encode($error); ?>);
            <?php endif; ?>
            <?php if($success): ?>
            showServerMessage('success', <?php echo json_encode($success); ?>);
            <?php endif; ?>
        });
    </script>
    <?php endif; ?>
    
    <?php include 'footer.php'; ?>
</body>
</html>
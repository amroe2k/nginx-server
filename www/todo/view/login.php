<?php
require_once 'includes/functions.php';
require_once 'includes/auth.php';

if(isLoggedIn()) {
    redirect('../index.php?page=dashboard');
}

$auth = new Auth();
$error = '';

if($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = sanitize($_POST['username']);
    $password = $_POST['password'];
    
    $login_result = $auth->login($username, $password);
    if($login_result === true) {
        redirect('../index.php?page=dashboard&welcome=1');
    } elseif($login_result === 'not_approved') {
        $error = 'Your account is pending admin approval. Please wait for approval before logging in.';
    } else {
        $error = 'Username/email or password is incorrect!';
    }
}
?>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Todo Talenta Digital</title>
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
                            <i class="fas fa-tasks text-primary"></i> Todo Talenta Digital
                        </h2>
                        <p class="text-center text-muted mb-4">Sign in to your account</p>
                        
                        <form method="POST" action="" id="loginForm">
                            <div class="mb-3">
                                <label for="username" class="form-label">
                                    <i class="fas fa-user me-1"></i> Username or Email
                                </label>
                                <input type="text" class="form-control" id="username" name="username" required>
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
                            </div>
                            <div class="d-grid gap-2 mt-4">
                                <button type="submit" class="btn btn-primary btn-lg">
                                    <i class="fas fa-sign-in-alt me-2"></i> Login
                                </button>
                                <a href="../index.php?page=register" class="btn btn-outline-secondary">
                                    <i class="fas fa-user-plus me-2"></i> Register
                                </a>
                            </div>
                        </form>
                        
                        <div class="text-center mt-4">
                            <small class="text-muted">
                                <i class="fas fa-info-circle me-1"></i>
                                Demo credentials: admin/password or user/password
                            </small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.js"></script>
    <script src="../js/utils.js"></script>
    <script>
        // Ensure password toggle works (re-initialize after utils.js)
        window.addEventListener('load', function() {
            const passwordToggle = document.querySelector('.password-toggle');
            if (passwordToggle) {
                // Remove any existing listeners
                const newToggle = passwordToggle.cloneNode(true);
                passwordToggle.parentNode.replaceChild(newToggle, passwordToggle);
                
                // Add new listener
                newToggle.addEventListener('click', function() {
                    const inputId = this.getAttribute('data-target');
                    const input = document.getElementById(inputId);
                    const icon = this.querySelector('i');
                    
                    if (input && icon) {
                        if (input.type === 'password') {
                            input.type = 'text';
                            icon.classList.remove('fa-eye');
                            icon.classList.add('fa-eye-slash');
                        } else {
                            input.type = 'password';
                            icon.classList.remove('fa-eye-slash');
                            icon.classList.add('fa-eye');
                        }
                    }
                });
            }
        });
    </script>
    <?php if($error): ?>
    <script>
        Swal.fire({
            icon: 'error',
            title: 'Login gagal',
            text: <?php echo json_encode($error); ?>,
            confirmButtonText: 'OK',
            background: '#ffffff',
            color: '#1a1a1a'
        });
    </script>
    <?php endif; ?>
    
    <?php include 'footer.php'; ?>
</body>
</html>
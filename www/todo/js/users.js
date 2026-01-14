// Users Page JavaScript
$(function () {
  initPasswordToggles();

  // Fallback delegation for show/hide password toggles
  $(document).on("click", ".password-toggle", function (e) {
    e.preventDefault();
    const inputId = $(this).data("target");
    if (typeof togglePasswordVisibility === "function") {
      togglePasswordVisibility(inputId, this);
    }
  });

  const toast = Swal.mixin({
    toast: true,
    position: "top-end",
    showConfirmButton: false,
    timer: 3000,
    timerProgressBar: true,
    background: "#ffffff",
    color: "#1a1a1a",
  });

  function showResult(response) {
    toast.fire({
      icon: response && response.success ? "success" : "error",
      title: (response && response.message) || "Operation failed",
    });
  }

  // Match backend rule: minimum 6 chars
  function isPasswordStrong(pwd) {
    return pwd && pwd.length >= 6;
  }

  function checkPasswordMatch() {
    const password = $("#new_password").val();
    const confirm = $("#confirm_password").val();
    const matchEl = $("#passwordMatch");
    if (!confirm) {
      matchEl.html("");
      return false;
    }
    if (password === confirm) {
      matchEl.html(
        '<span class="text-success"><i class="fas fa-check-circle me-1"></i>Passwords match</span>'
      );
      return true;
    }
    matchEl.html(
      '<span class="text-danger"><i class="fas fa-times-circle me-1"></i>Passwords do not match</span>'
    );
    return false;
  }

  function checkAddPasswordMatch() {
    const password = $("#add_password").val();
    const confirm = $("#add_confirm_password").val();
    const matchEl = $("#addPasswordMatch");
    if (!confirm) {
      matchEl.html("");
      return false;
    }
    if (password === confirm) {
      matchEl.html(
        '<span class="text-success"><i class="fas fa-check-circle me-1"></i>Passwords match</span>'
      );
      return true;
    }
    matchEl.html(
      '<span class="text-danger"><i class="fas fa-times-circle me-1"></i>Passwords do not match</span>'
    );
    return false;
  }

  $("#new_password").on("input", function () {
    const result = checkPasswordStrength(this.value);
    $("#passwordStrength")
      .attr("class", "password-strength-meter " + result.level)
      .css("width", result.width)
      .css("background-color", result.color);
    $("#passwordStrengthText")
      .attr("class", "password-strength-text " + result.level)
      .text(
        result.level.charAt(0).toUpperCase() +
          result.level.slice(1) +
          " password"
      );
    checkPasswordMatch();
  });

  $("#confirm_password").on("input", checkPasswordMatch);

  $("#add_password").on("input", checkAddPasswordMatch);
  $("#add_confirm_password").on("input", checkAddPasswordMatch);

  $(document).on("click", ".edit-user", function () {
    const btn = $(this);
    $("#edit_id").val(btn.data("id"));
    $("#edit_username").val(btn.data("username"));
    $("#edit_email").val(btn.data("email"));
    $("#edit_role").val(btn.data("role"));
    $("#edit_status").val(btn.data("status"));
    $("#editUserModal").modal("show");
  });

  $("#addUserBtn").on("click", function () {
    $("#addUserForm")[0].reset();
    $("#addPasswordMatch").html("");
    $("#addUserModal").modal("show");
  });

  $("#importXlsxBtn").on("click", function () {
    $("#importXlsxForm")[0].reset();
    $("#importXlsxModal").modal("show");
  });

  $("#importXlsxForm").on("submit", function (e) {
    e.preventDefault();

    const fileInput = $("#xlsx_file")[0];
    if (!fileInput.files || !fileInput.files[0]) {
      toast.fire({ icon: "error", title: "Please select an Excel file" });
      return;
    }

    Swal.fire({
      title: "Importing...",
      text: "Please wait while we import users",
      allowOutsideClick: false,
      showConfirmButton: false,
      willOpen: () => {
        Swal.showLoading();
      },
    });

    const formData = new FormData(this);
    formData.append("action", "import_xlsx");

    $.ajax({
      url: window.location.href,
      method: "POST",
      data: formData,
      processData: false,
      contentType: false,
      dataType: "json",
    })
      .done(function (res) {
        Swal.close();
        if (res && res.success) {
          Swal.fire({
            icon: "success",
            title: "Import Successful!",
            html: `<p>${res.imported} users imported successfully</p>${
              res.errors > 0
                ? '<p class="text-warning">' +
                  res.errors +
                  " errors occurred</p>"
                : ""
            }`,
            background: "#ffffff",
            color: "#1a1a1a",
          }).then(() => {
            $("#importXlsxModal").modal("hide");
            location.reload();
          });
        } else {
          Swal.fire({
            icon: "error",
            title: "Import Failed",
            text: res.message || "Failed to import users",
            background: "#ffffff",
            color: "#1a1a1a",
          });
        }
      })
      .fail(function () {
        Swal.close();
        toast.fire({ icon: "error", title: "Network error" });
      });
  });

  $("#addUserForm").on("submit", function (e) {
    e.preventDefault();
    const password = $("#add_password").val();
    if (!isPasswordStrong(password) || !checkAddPasswordMatch()) {
      toast.fire({
        icon: "error",
        title: "Password minimal 6 karakter dan harus sama",
      });
      return;
    }
    const formData = $(this).serialize() + "&action=create";
    $.ajax({
      url: window.location.href,
      method: "POST",
      data: formData,
      dataType: "json",
    })
      .done(function (res) {
        showResult(res);
        if (res && res.success) {
          $("#addUserModal").modal("hide");
          setTimeout(() => location.reload(), 800);
        }
      })
      .fail(function () {
        showResult({ success: false, message: "Network error" });
      });
  });

  $("#editUserForm").on("submit", function (e) {
    e.preventDefault();
    const formData = $(this).serialize() + "&action=update";
    $.ajax({
      url: window.location.href,
      method: "POST",
      data: formData,
      dataType: "json",
    })
      .done(function (res) {
        showResult(res);
        if (res && res.success) {
          $("#editUserModal").modal("hide");
          setTimeout(() => location.reload(), 800);
        }
      })
      .fail(function () {
        showResult({ success: false, message: "Network error" });
      });
  });

  $(document).on("click", ".change-password", function () {
    const btn = $(this);
    $("#password_user_id").val(btn.data("id"));
    $("#passwordUsername").text(btn.data("username"));
    $("#changePasswordForm")[0].reset();
    $("#passwordStrength")
      .attr("class", "password-strength-meter")
      .css("width", "0");
    $("#passwordStrengthText").text("");
    $("#passwordMatch").html("");
    $("#changePasswordModal").modal("show");
  });

  $("#changePasswordForm").on("submit", function (e) {
    e.preventDefault();
    const password = $("#new_password").val();
    if (!isPasswordStrong(password) || !checkPasswordMatch()) {
      toast.fire({
        icon: "error",
        title: "Password minimal 6 karakter dan harus sama",
      });
      return;
    }
    const formData = $(this).serialize() + "&action=change_password";
    $.ajax({
      url: window.location.href,
      method: "POST",
      data: formData,
      dataType: "json",
    })
      .done(function (res) {
        showResult(res);
        if (res && res.success) {
          $("#changePasswordModal").modal("hide");
        }
      })
      .fail(function () {
        showResult({ success: false, message: "Network error" });
      });
  });

  $(document).on("click", ".generate-password", function () {
    const btn = $(this);
    const id = btn.data("id");
    const username = btn.data("username");
    Swal.fire({
      title: "Generate password?",
      text: "Password baru akan dibuat untuk " + username,
      icon: "question",
      showCancelButton: true,
      confirmButtonText: "Generate",
      cancelButtonText: "Cancel",
      background: "#ffffff",
      color: "#1a1a1a",
    }).then((result) => {
      if (result.isConfirmed) {
        $.ajax({
          url: window.location.href,
          method: "POST",
          data: { id, action: "generate_password" },
          dataType: "json",
        })
          .done(function (res) {
            if (res && res.success) {
              Swal.fire({
                title: "Password Generated",
                html: `<p><code>${res.password}</code></p><p class="text-muted">Copy and share securely.</p>`,
                icon: "success",
                confirmButtonText: "Copy",
                background: "#ffffff",
                color: "#1a1a1a",
              }).then(() => {
                copyToClipboard(res.password);
              });
            } else {
              showResult(res);
            }
          })
          .fail(function () {
            showResult({ success: false, message: "Network error" });
          });
      }
    });
  });

  $(document).on("click", ".delete-user", function () {
    const btn = $(this);
    const id = btn.data("id");
    const username = btn.data("username");
    Swal.fire({
      title: "Delete user?",
      html: `<p class="text-dark">Are you sure you want to delete <strong>${username}</strong>?</p><p class="text-danger fw-semibold">This action cannot be undone.</p>`,
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#dc3545",
      cancelButtonColor: "#6c757d",
      confirmButtonText: "Delete",
      background: "#ffffff",
      color: "#1b1f23",
    }).then((result) => {
      if (result.isConfirmed) {
        $.ajax({
          url: window.location.href,
          method: "POST",
          data: { id, action: "delete" },
          dataType: "json",
        })
          .done(function (res) {
            showResult(res);
            if (res && res.success) {
              setTimeout(() => location.reload(), 800);
            }
          })
          .fail(function () {
            showResult({ success: false, message: "Network error" });
          });
      }
    });
  });

  // Approve user from table or pending tab
  $(document).on("click", ".approve-user-btn, .approve-btn", function () {
    const btn = $(this);
    const id = btn.data("id");
    const username = btn.data("username");

    Swal.fire({
      title: "Approve User?",
      text: `Are you sure you want to approve "${username}"?`,
      icon: "question",
      showCancelButton: true,
      confirmButtonColor: "#28a745",
      cancelButtonColor: "#6c757d",
      confirmButtonText: '<i class="fas fa-check me-2"></i>Yes, Approve!',
      cancelButtonText: '<i class="fas fa-times me-2"></i>Cancel',
      background: "#ffffff",
      color: "#1a1a1a",
      buttonsStyling: false,
      customClass: {
        confirmButton: "btn btn-success",
        cancelButton: "btn btn-secondary ms-2",
      },
    }).then((result) => {
      if (result.isConfirmed) {
        $.ajax({
          url: window.location.href,
          method: "POST",
          data: { id, action: "approve" },
          dataType: "json",
        })
          .done(function (res) {
            if (res && res.success) {
              showSuccessToast("User Approved!");
              setTimeout(() => location.reload(), 1000);
            } else {
              showErrorToast(res.message || "Failed to approve user");
            }
          })
          .fail(function () {
            showErrorToast("Network error");
          });
      }
    });
  });

  // Reject user
  $(document).on("click", ".reject-btn", function () {
    const btn = $(this);
    const id = btn.data("id");
    const username = btn.data("username");

    Swal.fire({
      title: "Reject User?",
      text: `Are you sure you want to reject "${username}"? This will delete their registration.`,
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#dc3545",
      cancelButtonColor: "#6c757d",
      confirmButtonText: '<i class="fas fa-check me-2"></i>Yes, Reject!',
      cancelButtonText: '<i class="fas fa-times me-2"></i>Cancel',
      background: "#ffffff",
      color: "#1a1a1a",
      buttonsStyling: false,
      customClass: {
        confirmButton: "btn btn-danger",
        cancelButton: "btn btn-secondary ms-2",
      },
    }).then((result) => {
      if (result.isConfirmed) {
        $.ajax({
          url: window.location.href,
          method: "POST",
          data: { id, action: "reject" },
          dataType: "json",
        })
          .done(function (res) {
            if (res && res.success) {
              showSuccessToast("User Rejected");
              setTimeout(() => location.reload(), 1000);
            } else {
              showErrorToast(res.message || "Failed to reject user");
            }
          })
          .fail(function () {
            showErrorToast("Network error");
          });
      }
    });
  });

  // View as User
  $(document).on("click", ".view-as-user", function () {
    const btn = $(this);
    const id = btn.data("id");
    const username = btn.data("username");
    Swal.fire({
      title: "View as user?",
      html: `<p>You will see the dashboard from <strong>${username}</strong>'s perspective.</p><p class="text-muted">You can return to admin by clicking "Back to Admin" in the profile menu.</p>`,
      icon: "info",
      showCancelButton: true,
      confirmButtonColor: "#0d6efd",
      cancelButtonColor: "#6c757d",
      confirmButtonText: "Continue",
      background: "#ffffff",
      color: "#1a1a1a",
    }).then((result) => {
      if (result.isConfirmed) {
        $.ajax({
          url: window.location.href,
          method: "POST",
          data: { user_id: id, action: "view_as_user" },
          dataType: "json",
        })
          .done(function (res) {
            if (res && res.success) {
              showSuccessToast("Switched to user view");
              setTimeout(() => (location.href = "?page=dashboard"), 1000);
            } else {
              showErrorToast(res.message || "Failed to switch user view");
            }
          })
          .fail(function () {
            showErrorToast("Network error");
          });
      }
    });
  });
});

// Keep view at filter box on pagination and filter actions
document.addEventListener("DOMContentLoaded", function () {
  const paginationLinks = document.querySelectorAll(
    "#users-pagination-list a.page-link"
  );
  const filterForm = document.getElementById("users-filter-form");
  const clearFilterBtn = document.getElementById("clear-filter-btn");
  const filterBox = document.getElementById("users-filter-box");

  // Save filter box position on pagination click
  paginationLinks.forEach((link) => {
    link.addEventListener("click", function (e) {
      if (filterBox) {
        const filterBoxTop =
          filterBox.getBoundingClientRect().top + window.pageYOffset;
        sessionStorage.setItem("usersFilterPosition", filterBoxTop - 80); // 80px offset for navbar
      }
    });
  });

  // Save filter box position on filter submit
  if (filterForm) {
    filterForm.addEventListener("submit", function (e) {
      if (filterBox) {
        const filterBoxTop =
          filterBox.getBoundingClientRect().top + window.pageYOffset;
        sessionStorage.setItem("usersFilterPosition", filterBoxTop - 80);
      }
    });
  }

  // Save filter box position on clear filter click
  if (clearFilterBtn) {
    clearFilterBtn.addEventListener("click", function (e) {
      if (filterBox) {
        const filterBoxTop =
          filterBox.getBoundingClientRect().top + window.pageYOffset;
        sessionStorage.setItem("usersFilterPosition", filterBoxTop - 80);
      }
    });
  }

  // Restore scroll position to filter box after page load
  const savedFilterPosition = sessionStorage.getItem("usersFilterPosition");
  if (savedFilterPosition !== null) {
    setTimeout(function () {
      window.scrollTo({
        top: parseInt(savedFilterPosition),
        behavior: "instant",
      });
      sessionStorage.removeItem("usersFilterPosition");
    }, 50);
  }
});

// Disable Bootstrap autofill overlay
(function () {
  if (!window.bootstrap || !bootstrap.Autofill) return;
  try {
    if (bootstrap.Autofill._observer) {
      bootstrap.Autofill._observer.disconnect();
    }
    document
      .querySelectorAll(".bs-autofill-overlay")
      .forEach((el) => el.remove());
    bootstrap.Autofill._elements = [];
  } catch (e) {
    // swallow
  }
})();

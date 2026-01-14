// Dashboard AJAX Pagination
document.addEventListener("DOMContentLoaded", function () {
  const pagination = document.getElementById("activity-pagination");
  if (pagination) {
    pagination.addEventListener("click", function (e) {
      const link = e.target.closest("a.page-link");
      if (link && link.hasAttribute("data-page")) {
        e.preventDefault();
        const pageNum = link.getAttribute("data-page");
        const url = new URL(window.location.href);
        url.searchParams.set("p", pageNum);

        // Get position of activity section before update
        const activitySection = document.getElementById("activity-log-section");
        const sectionTop = activitySection
          ? activitySection.getBoundingClientRect().top + window.pageYOffset
          : 0;

        // Show loading indicator
        const activityLog = document.querySelector(".activity-log");
        activityLog.style.opacity = "0.5";
        activityLog.style.pointerEvents = "none";

        // Fetch new page content
        fetch(url.toString())
          .then((response) => response.text())
          .then((html) => {
            const parser = new DOMParser();
            const doc = parser.parseFromString(html, "text/html");
            const newActivityLog = doc.querySelector(".activity-log");
            const newPagination = doc.querySelector("#activity-pagination");
            const newPageInfo = doc.querySelector(".card-footer .text-center");

            if (newActivityLog) {
              activityLog.innerHTML = newActivityLog.innerHTML;
              activityLog.style.opacity = "1";
              activityLog.style.pointerEvents = "auto";
            }

            if (newPagination && pagination.parentElement) {
              pagination.parentElement.innerHTML =
                newPagination.parentElement.innerHTML;
              // Re-attach event listener
              initPagination();
            }

            // Scroll to user information section with smooth behavior
            requestAnimationFrame(() => {
              const userInfoSection =
                document.getElementById("user-info-section");
              if (userInfoSection) {
                const rect = userInfoSection.getBoundingClientRect();
                const offset = 80; // navbar height + padding
                window.scrollTo({
                  top: window.pageYOffset + rect.top - offset,
                  behavior: "smooth",
                });
              }
            });

            // Update URL without reload
            history.pushState({ page: pageNum }, "", url.toString());
          })
          .catch((error) => {
            console.error("Error loading page:", error);
            activityLog.style.opacity = "1";
            activityLog.style.pointerEvents = "auto";
            showErrorToast("Failed to load page");
          });
      }
    });
  }

  function initPagination() {
    const newPagination = document.getElementById("activity-pagination");
    if (newPagination) {
      newPagination.addEventListener("click", arguments.callee);
    }
  }

  // Handle browser back/forward buttons
  window.addEventListener("popstate", function () {
    location.reload();
  });
});

// Welcome Toast
function showWelcomeToast() {
  const welcomeToast = Swal.mixin({
    toast: true,
    position: "top-end",
    showConfirmButton: false,
    timer: 2200,
    timerProgressBar: true,
    background: "#ffffff",
    color: "#0d6efd",
  });
  welcomeToast.fire({
    icon: "success",
    title: "Welcome back!",
    text: "Anda berhasil login.",
  });
}

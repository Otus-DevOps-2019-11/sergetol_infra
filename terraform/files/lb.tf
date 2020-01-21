resource "google_compute_instance_group" "app_group" {
  name = "reddit-app-group"
  zone = var.zone

  instances = google_compute_instance.app[*].self_link

  named_port {
    name = "app-port"
    port = "9292"
  }
}

resource "google_compute_health_check" "app_health_check" {
  name                = "reddit-app-health-check"
  check_interval_sec  = 3
  timeout_sec         = 3
  healthy_threshold   = 1
  unhealthy_threshold = 2

  http_health_check {
    port_name          = "app-port"
    port_specification = "USE_NAMED_PORT"
    request_path       = "/"
  }
}

resource "google_compute_backend_service" "app_backend" {
  name        = "reddit-app-backend"
  port_name   = "app-port"
  protocol    = "HTTP"
  timeout_sec = 10

  backend {
    group = google_compute_instance_group.app_group.self_link
  }

  health_checks = [google_compute_health_check.app_health_check.self_link]
}

resource "google_compute_url_map" "app_url_map" {
  name            = "reddit-app-url-map"
  default_service = google_compute_backend_service.app_backend.self_link

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.app_backend.self_link

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.app_backend.self_link
    }
  }
}

resource "google_compute_target_http_proxy" "app_proxy" {
  name    = "reddit-app-proxy"
  url_map = google_compute_url_map.app_url_map.self_link
}

resource "google_compute_global_forwarding_rule" "app_forwarding_rule" {
  name       = "reddit-app-forwarding-rule"
  target     = google_compute_target_http_proxy.app_proxy.self_link
  port_range = "8080"
}


resource "google_compute_instance_group" "instance-groups" {
  name      = "instance-group1"
  zone      = "${var.zone}"
  instances = ["${google_compute_instance.app.*.self_link}"]

  named_port {
    name = "http"
    port = "9292"
  }
}

resource "google_compute_backend_service" "default" {
  name          = "backend-service"
  health_checks = ["${google_compute_health_check.default.self_link}"]
  protocol      = "HTTP"

  backend = [
    {
      max_utilization = 0.8
      balancing_mode  = "UTILIZATION"
      capacity_scaler = 1
      group           = "${google_compute_instance_group.instance-groups.self_link}"
    },
  ]
}

resource "google_compute_health_check" "default" {
  name = "health-check"

  check_interval_sec = 10
  timeout_sec        = 5

  tcp_health_check {
    port = "9292"
  }
}

resource "google_compute_url_map" "urlmap" {
  name = "balancer"

  default_service = "${google_compute_backend_service.default.self_link}"
}

resource "google_compute_target_http_proxy" "default" {
  name    = "target-proxy"
  url_map = "${google_compute_url_map.urlmap.self_link}"
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "global-rule"
  target     = "${google_compute_target_http_proxy.default.self_link}"
  port_range = "80"
}

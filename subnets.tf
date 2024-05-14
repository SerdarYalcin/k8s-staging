resource "google_compute_subnetwork" "private" {
  name                     = "k8s-staging"
  ip_cidr_range            = "192.168.0.0/20"
  region                   = "europe-west2"
  network                  = google_compute_network.main.id
  private_ip_google_access = false

  secondary_ip_range {
    range_name    = "k8s-pod-range"
    ip_cidr_range = "192.168.16.0/22"
  }
  secondary_ip_range {
    range_name    = "k8s-service-range"
    ip_cidr_range = "192.168.20.0/23"
  }
}


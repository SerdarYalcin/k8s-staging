data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

resource "google_project_service" "file" {
  service = "file.googleapis.com"
  disable_on_destroy = false
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = "gpg-k8s-staging"
  name                       = "gke-staging"
  location                   = "europe-west2-a"  # Specify the zone
  regional                   = false             # Set to false for zonal deployment
  network                    = "k8s-staging"
  subnetwork                 = "uk-k8s-staging"
  http_load_balancing        = true
  gcs_fuse_csi_driver        = false
  network_policy             = false
  horizontal_pod_autoscaling = false
  gce_pd_csi_driver          = true
  filestore_csi_driver       = false
  ip_range_pods              = "k8s-pod-range"
  ip_range_services          = "k8s-service-range"
  release_channel            = "STABLE"
  kubernetes_version         = "1.28.7-gke.1026000"
  deletion_protection        = false
  remove_default_node_pool   = true

  database_encryption = [
    {
      state    = "ENCRYPTED"
      key_name = "projects/gpg-k8s-staging/locations/europe-west2/keyRings/k8s/cryptoKeys/k8s"
    }
  ]

  node_pools = [
    {
      name                      = "default-node-pool"
      machine_type              = "e2-medium"
      node_locations            = ["europe-west2-a"]
      local_ssd_count           = 0
      spot                      = false
      disk_size_gb              = 100
      disk_type                 = "pd-standard"
      image_type                = "COS_CONTAINERD"
      enable_gcfs               = false
      enable_gvnic              = false
      logging_variant           = "DEFAULT"
      auto_repair               = false
      auto_upgrade              = true
      service_account           = "k8s-api@gpg-k8s-staging.iam.gserviceaccount.com"
      preemptible               = false
      initial_node_count        = 1
      autoscaling               = false
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }

  maintenance_policy = {
    recurring_window = {
      recurrence = "FREQ=MONTHLY;INTERVAL=6"
      window = {
        start_time = "2023-06-01T12:00:00Z"
        end_time   = "2023-06-01T14:00:00Z"
      }
    }
  }
}

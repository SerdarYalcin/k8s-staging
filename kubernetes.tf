data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = "gpg-k8s-staging"
  name                       = "gke-staging"
  region                     = "europe-west2"
  zones                      = ["europe-west2-a"]
  network                    = "k8s-staging"
  subnetwork                 = "uk-k8s-staging"
  http_load_balancing        = true
  gcs_fuse_csi_driver	       = false
  network_policy             = false
  horizontal_pod_autoscaling = false
  gce_pd_csi_driver          = true
  filestore_csi_driver       = false
  ip_range_pods              = "k8s-pod-range"
  ip_range_services          = "k8s-service-range"
  release_channel            = "STABLE"
  kubernetes_version		     = "1.28.7-gke.1026000"

  database_encryption = [
    {
    state    = "ENCRYPTED"
    key_name = "projects/gpg-k8s-staging/locations/europe-west2/keyRings/k8s/cryptoKeys/k8s/cryptoKeyVersions/1"
  }]


  node_pools = [
    {
      name                      = "default-node-pool"
      machine_type              = "e2-medium"
      node_locations            = "europe-west2-a"
      local_ssd_count           = 0
      spot                      = false
      disk_size_gb              = 100
      disk_type                 = "pd-standard"
      image_type                = "COS_CONTAINERD"
      enable_gcfs               = false
      enable_gvnic              = false
      logging_variant           = "DEFAULT"
      auto_repair               = false
      auto_upgrade              = false
      service_account           = "k8s-api@gpg-k8s-staging.iam.gserviceaccount.com"
      preemptible               = false
      initial_node_count        = 1
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


  # node_pools_taints = {
  #   all = []

  #   default-node-pool = [
  #     {
  #       key    = "default-node-pool"
  #       value  = true
  #       effect = "PREFER_NO_SCHEDULE"
  #     },
  #   ]
  # }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}
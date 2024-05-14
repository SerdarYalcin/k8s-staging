terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.29.0"
    }
  }
}

provider "google" {
  credentials = file("/mnt/workspace/opt/gcp/gpg-k8s-staging-4184af1c35b3.json")
  project     = "gpg-k8s-staging"
  region      = "europe-west2"
}
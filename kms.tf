module "kms" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 2.3"

  project_id   = "gpg-k8s-staging"
  location     = "europe-west2"
  keyring      = "k8s-keyring"
  keys         = ["kubo"]
  set_owners_for = ["k8s-902"]
  owners = [
    "k8s-902@gpg-k8s-staging.iam.gserviceaccount.com"
  ]

  key_algorithm             = "GOOGLE_SYMMETRIC_ENCRYPTION"
  key_protection_level      = "SOFTWARE"
  key_rotation_period       = "31536000s"  # 365 days in seconds
  purpose                   = "ENCRYPT_DECRYPT"
  prevent_destroy           = true
}

resource "google_kms_key_ring" "key_ring" {
  name     = "k8s-key-ring"
  location = "europe-west2"
}

resource "google_kms_crypto_key" "symmetric_encrypt_decrypt_key" {
  name            = "k8s"
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = "31536000s" # 365 days in seconds

  purpose = "ENCRYPT_DECRYPT"

  crypto_key_config {
    algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
  }
}

resource "google_storage_bucket" "basic_bucket" {
  name          = "my-unique-xdar-001"
  location      = "US"
  force_destroy = true  # Allows the bucket to be destroyed even if it contains objects at destroy time

  # Bucket policy to make sure objects are set to private by default
  uniform_bucket_level_access = true
}


provider "google" {
  project     = "qwiklabs-gcp-01-5122de7b6e61"
  region      = "us-east4"
}
resource "google_storage_bucket" "test-bucket-for-state" {
  name        = "qwiklabs-gcp-01-5122de7b6e61"
  location    = "US"
  uniform_bucket_level_access = true
}

terraform {
  backend "gcs" {
    bucket  = "qwiklabs-gcp-01-5122de7b6e61"
    prefix  = "terraform/state"
  }
}

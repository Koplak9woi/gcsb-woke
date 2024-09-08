resource "buckets/qwiklabs-gcp-02-3bfeec684adb" {
  roles = [
    "roles/storage.objectAdmin",
    "roles/storage.legacyBucketReader",
  ]
}

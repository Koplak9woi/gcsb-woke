variable "region" {
  default = "us-west1"
}

variable "project_id" {
  description = "GCP Project used to create resources."
  default     = "qwiklabs-gcp-00-79f72a6e24df"
}

variable "image_family" {
  description = "Image used for compute VMs."
  default     = "debian-11"
}

variable "image_project" {
  description = "GCP Project where source image comes from."
  default     = "debian-cloud"
}

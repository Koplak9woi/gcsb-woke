variable "region" {
  type        = string
  description = "Region for the resource."
  default     = "us-central1"
}

variable "location" {
  type        = string
  default     = "us-central1-c"
  description = "Location represents region/zone for the resource."
}

variable "network_name" {
  default = "tf-gke-k8s"
}

variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

# variable db_disk_image {
#  description = "Disk image"
#  default     = "reddit-db-base"
#}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-appv2-base"
}

variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable node_count {
  description = "Number of VM"
  default     = 1
}

variable app_instance_name {
  description = "Name of app VM"
}

variable db_external_ip {
  default = "127.0.0.1"
}

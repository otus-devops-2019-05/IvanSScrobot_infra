terraform {
  backend "gcs" {
    bucket = "storage-bucket-is"

    prefix = "prod"
  }
}


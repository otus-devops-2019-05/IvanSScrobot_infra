terraform {
  required_version = "~>0.11.7"
}

provider "google" {
  version = "~> 2.5"
  project = "${var.project}"
  region  = "${var.region}"
}

module "app" {
  source            = "../modules/app"
  public_key_path   = "${var.public_key_path}"
  zone              = "${var.zone}"
  app_disk_image    = "${var.app_disk_image}"
  project           = "quick-cogency-244209"
  private_key_path  = "~/.ssh/ivan"
  app_instance_name = "${var.app_name}"
}

module "db" {
  source           = "../modules/db"
  public_key_path  = "${var.public_key_path}"
  zone             = "${var.zone}"
  db_disk_image    = "${var.db_disk_image}"
  project          = "quick-cogency-244209"
  private_key_path = "~/.ssh/ivan"
}

module "vpc" {
  source           = "../modules/vpc"
  source_ranges    = ["0.0.0.0/0"]
  public_key_path  = "${var.public_key_path}"
  project          = "quick-cogency-244209"
  private_key_path = "~/.ssh/ivan"
}
 # locals {
   #db_ip = "${var.db_external_ip}"
   # db_ip = "${join(",",var.db_external_ip)}"
   #echo_db_url = "echo Environment='DATABASE_URL=${local.db_ip}:27017' >> '/tmp/puma.service' "
 # }

data "template_file" "puma_file" {
  template = "${file("${path.module}/files/puma.service.tpl")}"

  vars {
    database_url = "${var.db_external_ip}:27017"
  }
}

resource "google_compute_instance" "app" {
  name         = "${var.app_instance_name}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "${var.app_disk_image}"
    }
  }

  network_interface {
    network = "default"

    access_config = {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    user        = "ivan"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "file" {
    content     ="${data.template_file.puma_file.rendered}"
    destination = "/tmp/puma.service"
  }

  provisioner "file" {
    source  = "${path.module}/files/deploy.sh"
    destination = "/tmp/deploy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/puma.service /etc/systemd/system/puma.service",
      "sudo bash /tmp/deploy.sh"
    ]
 }

}

resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}

resource "google_compute_firewall" "firewall" {
  name    = "${var.prefix}-firewall-externalssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] 
  target_tags   = ["externalssh"]
}

resource "google_compute_firewall" "webserverrule" {
  name    = "${var.prefix}-webserver"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22","80","443"]
  }

  source_ranges = ["0.0.0.0/0"] 
  target_tags   = ["webserver"]
}

resource "google_compute_address" "static" {
  name = "vm-public-address"
  project = var.project
  region = var.region
  depends_on = [ google_compute_firewall.firewall ]
}

resource "google_compute_instance" "dev" {
  name         = "${var.prefix}-vm"
  machine_type = "f1-micro"
  zone         = "${var.region}-a"
  tags         = ["externalssh","webserver"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  provisioner "remote-exec" {
    connection {
      host        = google_compute_address.static.address
      type        = "ssh"
      user        = var.user
      timeout     = "500s"
      private_key = file(var.private_key_location)
    }

    inline = [
      "mkdir newDir",
      "rmdir newDir"
    ]
  }

   provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.user}   -i ${google_compute_address.static.address}, --private-key ${var.private_key_location} playbook.yml"
  }

  depends_on = [ google_compute_firewall.firewall, google_compute_firewall.webserverrule ]

  metadata = {
    ssh-keys = "${var.user}:${file(var.public_key_location)}"
  }
}
resource "google_compute_firewall" "webserverrule" {
  name    = "${var.prefix}-webserver"
  network = "default"

  allow {
    protocol = "all"
    ports    = ["22","80","443","3389","5985","5986"]
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
  tags         = ["webserver"]

  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-2019"
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
      host        = self.default.network_interface[0].access_config[0].nat_ip
      type        = "winrm"
      port        = 5985
      https       = false
      timeout     = "500s"
      user        = "${var.admin_username}"
      password    = "${var.admin_password}"
    }

    inline = [
      "mkdir helloworld"
    ]
  }

  provisioner "local-exec" {
    command="echo ansible_host_1 ansible_host=${self.default.network_interface[0].access_config[0].nat_ip} ansible_user=${var.admin_username} ansible_password=${var.admin_password} ansible_connection=${var.connection_type} ansible_winrm_server_cert_validation=ignore ansible_port=5985 > hosts"
  }
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts  playbook.yml"
  }
  provisioner "local-exec" {
    command = "rm -rf hosts"
  }

  depends_on = [ google_compute_firewall.webserverrule ]

  metadata = {
    ssh-keys = "${var.user}:${file(var.public_key_location)}"
  }
}
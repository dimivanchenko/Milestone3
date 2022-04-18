resource "google_compute_firewall" "geoapp" {
    name    = "geoapp-firewall"
    network = "default"

    allow {
        protocol = "tcp"
        ports    = ["22", "25", "8080","5432"] 
    }
    source_ranges = ["0.0.0.0/0"]

}


resource "google_compute_instance" "geoapp-server" {
    name         = "geoapp-server"
    machine_type = "e2-medium"

    boot_disk {
        initialize_params {
            image = "ubuntu-minimal-2004-focal-v20220331"
        }
    }

    metadata = { 
        ssh-keys = "${var.ssh_user}:${data.google_storage_bucket_object_content.key_server.content}"
        user-data = file("./script.sh")
    } 

  
    network_interface {
        network = "default"
        access_config {}
    }
}


output "geoapp-ip" {
    value = google_compute_instance.geoapp-server.network_interface.0.access_config.0.nat_ip
}

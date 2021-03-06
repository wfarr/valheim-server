output "server_ip" {
  description = "The EIP of the server"
  value       = google_compute_instance.valheim_server.network_interface.0.access_config.0.nat_ip
}

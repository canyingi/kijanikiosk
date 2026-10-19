output "ip" {
  description = "IP of the server"
  value       = var.ip
}
output "ssh_command" {
  description = "SSH command for the server"
  value       = "ssh -i ${var.ssh_private_key_path} ${var.ssh_user}@${var.ip}"
}

output "server_ips" {
  description = "Server IPs keyed by role, used to build the Ansible inventory"
  value       = { for k, m in module.app_server : k => m.ip }
}
output "ssh_commands" {
  description = "SSH commands keyed by role"
  value       = { for k, m in module.app_server : k => m.ssh_command }
}

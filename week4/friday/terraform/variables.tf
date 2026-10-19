variable "servers" {
  description = "Server definitions keyed by role; vm_name is the Multipass instance name"
  type        = map(object({ vm_name = string }))
  default = {
    api      = { vm_name = "kijanikiosk-api" }
    payments = { vm_name = "kijanikiosk-payments" }
    logs     = { vm_name = "kijanikiosk-logs" }
  }
}
variable "ssh_user" {
  description = "SSH user on the VMs"
  type        = string
  default     = "ubuntu"
}
variable "ssh_private_key_path" {
  description = "Private key Terraform and Ansible both use"
  type        = string
  default     = "~/.ssh/id_ed25519"
}
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "staging"
}

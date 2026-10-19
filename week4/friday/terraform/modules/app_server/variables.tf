variable "name" {
  description = "Logical server name (api, payments, logs)"
  type        = string
}
variable "ip" {
  description = "IP address of the VM"
  type        = string
}
variable "ssh_user" {
  description = "SSH user on the VM"
  type        = string
}
variable "ssh_private_key_path" {
  description = "Path to the SSH private key"
  type        = string
}
variable "environment" {
  description = "Deployment environment"
  type        = string
}

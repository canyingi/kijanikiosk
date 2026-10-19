resource "null_resource" "server" {
  triggers = { ip = var.ip }

  connection {
    type        = "ssh"
    host        = var.ip
    user        = var.ssh_user
    private_key = file(pathexpand(var.ssh_private_key_path))
  }

  provisioner "remote-exec" {
    inline = ["echo 'Connected to ${var.name} (${var.environment})'"]
  }
}

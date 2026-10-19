terraform {
  required_version = ">= 1.10.0"
  required_providers {
    null     = { source = "hashicorp/null", version = "~> 3.2" }
    external = { source = "hashicorp/external", version = "~> 2.3" }
  }

  backend "s3" {
    bucket                      = "kijanikiosk-tfstate"
    key                         = "week4/terraform.tfstate"
    region                      = "us-east-1"
    endpoints                   = { s3 = "http://localhost:9000" }
    use_path_style              = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_lockfile                = true
  }
}

data "external" "vm_ip" {
  for_each = var.servers
  program  = ["${path.module}/get_ip.sh"]
  query    = { name = each.value.vm_name }
}

module "app_server" {
  source               = "./modules/app_server"
  for_each             = var.servers
  name                 = each.key
  ip                   = data.external.vm_ip[each.key].result.ip
  ssh_user             = var.ssh_user
  ssh_private_key_path = var.ssh_private_key_path
  environment          = var.environment
}

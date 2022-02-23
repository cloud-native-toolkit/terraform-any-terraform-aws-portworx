
locals {
  portworx_essentials = {
    enable = true
    cluster_id = var.px_cluster_id
    user_id = var.px_user_id
    osb_endpoint = var.px_osb_endpoint
  }
}

module "dev_tools_mymodule" {
  source = "./module"

  region                = var.region
  access_key            = var.access_key
  secret_key            = var.secret_key
  server_url            = var.server_url
  cluster_username      = var.cluster_username
  cluster_password      = var.cluster_password
  portworx_essentials   = local.portworx_essentials
  
}

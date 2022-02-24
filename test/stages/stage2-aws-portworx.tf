
locals {
  portworx_config = {
    cluster_id = "px-cluster-7ae83260-f2f9-4d6e-aa93-8f11c1dc0ee9"
    user_id = ""
    osb_endpoint = ""
    type = "enterprise"
    enable_encryption = false
  }
}

module "aws_portworx" {
  source = "./module"

  region                = var.region
  access_key            = var.access_key
  secret_key            = var.secret_key
  cluster_config_file   = module.dev_cluster.platform.kubeconfig
  portworx_config       = local.portworx_config
}

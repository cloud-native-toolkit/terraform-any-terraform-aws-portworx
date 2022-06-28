
# Resource Group Variables

variable "region" {
  type        = string
  description = "Region where AWS cluster is deployed"
}


variable cluster_username { 
  type        = string
  description = "The username for AWS access"
}


variable "cluster_password" {
  type        = string
  description = "The password for AWS access"
}

variable "server_url" {
  type        = string
}

variable "access_key" {
  type    = string
  default = ""
}

variable "secret_key" {
  type    = string
  default = ""
}


# variable "px_cluster_id" {
#   type        = string
# }

# variable "px_user_id" {
#   type        = string
# }

# variable "px_osb_endpoint" {
#   type        = string
# }

variable "portworx_spec" {
  type = string
  default = ""
}

variable "portworx_spec_file" {
  type = string
  description = "The path to the file that contains the yaml spec for the Portworx config. Either the `portworx_spec_file` or `portworx_spec` must be provided. The instructions for creating this configuration can be found at https://github.com/cloud-native-toolkit/terraform-azure-portworx/blob/main/PORTWORX_CONFIG.md"
  default = ""
}
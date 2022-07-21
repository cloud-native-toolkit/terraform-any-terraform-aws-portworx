variable "provision" {
    default     = true
    description = "If set to true installs Portworx on the given cluster"
}

variable "access_key" {
  type    = string
  default = ""
}

variable "secret_key" {
  type    = string
  default = ""
}

variable "region" {
  type        = string
  description = "AWS Region the cluster is deployed in"
}


# variable "portworx_config" {
#   type = object({
#     type=string,
#     cluster_id=string,
#     enable_encryption=bool,
#     user_id=string,
#     osb_endpoint=string
#   })
#   description = "Portworx configuration"

#   validation {
#     condition     = contains(["enterprise","essentials"], var.portworx_config.type)
#     error_message = "Allowed values for portworx_config.type are \"enterprise\", or \"essentials\"."
#   }
#   validation {
#     condition     = length(var.portworx_config.cluster_id) > 0
#     error_message = "Variable portworx_config.cluster_id is required."
#   }
#   validation {
#     condition     =  var.portworx_config.type == "enterprise" || (var.portworx_config.type == "essentials" && length(var.portworx_config.user_id) > 0)
#     error_message = "Variable portworx_config.user_id value is required for type \"essentials\"."
#   }
#   validation {
#     condition     = var.portworx_config.type == "enterprise" || (var.portworx_config.type == "essentials" && length(var.portworx_config.osb_endpoint) > 0)
#     error_message = "Variable portworx_config.osb_endpoint value is required for type \"essentials\"."
#   }
#   default = {
#     cluster_id = "value"
#     enable_encryption = false
#     osb_endpoint = "value"
#     type = "value"
#     user_id = "value"
#   }
# }


variable "disk_size" {
  description = "Disk size for each Portworx volume"
  default     = 1000
}

variable "kvdb_disk_size" {
  default = 450
}

variable "px_enable_monitoring" {
  type        = bool
  default     = true
  description = "Enable monitoring on PX"
}

variable "px_enable_csi" {
  type        = bool
  default     = true
  description = "Enable CSI on PX"
}


variable "cluster_config_file" {
  type        = string
  description = "Cluster config file for Kubernetes cluster."
}

#additional 
variable "portworx_spec" {
  type = string
  default = ""
}

variable "portworx_spec_file" {
  type = string
  description = "The path to the file that contains the yaml spec for the Portworx config. Either the `portworx_spec_file` or `portworx_spec` must be provided. The instructions for creating this configuration can be found at https://github.com/cloud-native-toolkit/terraform-azure-portworx/blob/main/PORTWORX_CONFIG.md"
  default = ""
}

variable "enable_encryption" {
  type = bool
  description = "Flag indicating portworx volumes should be encrypted"
  default = false
}

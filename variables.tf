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

# variable "cluster_id" {
#   type        = string
#   description = "Cluster ID"
# }

#variable "portworx_config" {
#  type = object({
#    type=string,
#    cluster_id=string,
#    enable_encryption=boolean,
#    user_id=string,
#    osb_endpoint=string
#  })
#  description = "Portworx configuration"
#
#  validation {
#    condition     = contains(["enterprise","essentials"], var.portworx_config.type)
#    error_message = "Allowed values for portworx_config.type are \"enterprise\", or \"essentials\"."
#  }
#}



variable "portworx_enterprise" {
  type        = map(string)
  description = "See PORTWORX.md on how to get the Cluster ID."
  default = {
    enable            = false
    cluster_id        = ""
    enable_encryption = true
  }
}

variable "portworx_essentials" {
  type        = map(string)
  description = "See PORTWORX-ESSENTIALS.md on how to get the Cluster ID, User ID and OSB Endpoint"
  default = {
    enable       = false
    cluster_id   = ""
    user_id      = ""
    osb_endpoint = ""
  }
}

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

#variable cluster_username {
#  type        = string
#  description = "The username for AWS access"
#}
#
#
#variable "cluster_password" {
#  type        = string
#  description = "The password for AWS access"
#}
#
#variable "server_url" {
#  type        = string
#}

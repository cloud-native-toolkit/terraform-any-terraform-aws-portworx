
variable "aws_aws_access_key_id_id" {
  type    = string
  default = ""
}

variable "aws_secret_access_key" {
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

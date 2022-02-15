
# Resource Group Variables

variable "region" {
  type        = string
  description = "Region for VLANs defined in private_vlan_number and public_vlan_number."
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


variable "px_cluster_id" {
  type        = string
}

variable "px_user_id" {
  type        = string
}

variable "osb_endpoint" {
  type        = string
}

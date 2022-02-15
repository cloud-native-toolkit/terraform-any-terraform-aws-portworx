
# Resource Group Variables

variable "region" {
  type        = string
  description = "Region for VLANs defined in private_vlan_number and public_vlan_number."
  default="us-west-2"
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


variable "px_cluster_id" {
  type        = string
}

variable "px_user_id" {
  type        = string
}

variable "px_osb_endpoint" {
  type        = string
}

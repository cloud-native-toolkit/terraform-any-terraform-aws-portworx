
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


variable "px_cluster_id" {
  type        = string
}

variable "px_user_id" {
  type        = string
}

variable "px_osb_endpoint" {
  type        = string
}

variable "cloud_provider" {
  type        = string
  description = "Cloud provider (aws or azure)"
}